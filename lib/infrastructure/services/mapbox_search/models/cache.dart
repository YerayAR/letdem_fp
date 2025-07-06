import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'service.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future deleteAllPlaces() async {
    final db = await database;
    await db.delete('places');
  }

  Future deletePlace(String id) async {
    final db = await database;
    await db.delete('places', where: 'id = ?', whereArgs: [id]);
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'mapbox_places.db');
    return await openDatabase(
      path,
      version: 2, // Increment version to handle schema change
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE places (
            id TEXT PRIMARY KEY,
            data TEXT,
            timestamp INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add timestamp column to existing table
          await db.execute('ALTER TABLE places ADD COLUMN timestamp INTEGER');
          // Update existing records with current timestamp
          await db.execute(
              'UPDATE places SET timestamp = ${DateTime.now().millisecondsSinceEpoch}');
        }
      },
    );
  }

  Future<void> savePlace(HerePlace place) async {
    final db = await database;

    // Start a transaction for atomic operations
    await db.transaction((txn) async {
      // Insert the new place with timestamp
      final jsonString = jsonEncode(place.toJson());
      await txn.insert(
        'places',
        {
          'id': place.id,
          'data': jsonString,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Get count of places
      final count = Sqflite.firstIntValue(
          await txn.rawQuery('SELECT COUNT(*) FROM places'));

      // If we have more than 5 places, delete the oldest one(s)
      if (count != null && count > 5) {
        // This query finds the oldest records by timestamp and deletes them
        await txn.rawDelete('''
          DELETE FROM places WHERE id IN (
            SELECT id FROM places ORDER BY timestamp ASC LIMIT ${count - 5}
          )
        ''');
      }
    });
  }

  Future<List<HerePlace>> getPlaces() async {
    final db = await database;

    try {
      // Query with order by timestamp descending (most recent first)
      final List<Map<String, dynamic>> maps = await db.query(
        'places',
        orderBy: 'timestamp DESC',
        limit: 5,
      );

      return maps
          .map((map) => HerePlace.fromJson(jsonDecode(map['data'])))
          .toList();
    } catch (e) {
      print('Error getting places: $e');
      return [];
    }
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('places');
  }
}
