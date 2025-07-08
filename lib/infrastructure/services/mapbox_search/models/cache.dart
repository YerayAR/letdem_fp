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
    if (_database != null) {
      print('[DB] Returning existing database instance.');
      return _database!;
    }
    print('[DB] Initializing new database.');
    _database = await _initDatabase();
    return _database!;
  }

  Future deleteAllPlaces() async {
    print('[DB] Deleting all places...');
    final db = await database;
    final deletedCount = await db.delete('places');
    print('[DB] Deleted $deletedCount places.');
  }

  Future deletePlace(String id) async {
    print('[DB] Deleting place with ID: $id');
    final db = await database;
    final deletedCount =
        await db.delete('places', where: 'id = ?', whereArgs: [id]);
    print('[DB] Deleted $deletedCount rows for ID: $id');
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'mapbox_places.db');
    print('[DB] Opening database at path: $path');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        print('[DB] Creating new table...');
        await db.execute('''
          CREATE TABLE places (
            id TEXT PRIMARY KEY,
            data TEXT,
            timestamp INTEGER
          )
        ''');
        print('[DB] Table created.');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print(
            '[DB] Upgrading database from version $oldVersion to $newVersion');
        if (oldVersion < 2) {
          print('[DB] Adding "timestamp" column...');
          await db.execute('ALTER TABLE places ADD COLUMN timestamp INTEGER');
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          print('[DB] Setting timestamp for existing records: $timestamp');
          await db.execute('UPDATE places SET timestamp = $timestamp');
        }
      },
    );
  }

  Future<void> savePlace(HerePlace place) async {
    final db = await database;
    final jsonString = jsonEncode(place.toJson());
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    print('[DB] Saving place with ID: ${place.id}');
    print('[DB] JSON: $jsonString');
    print('[DB] Timestamp: $timestamp');

    await db.transaction((txn) async {
      print('[DB] Inserting place inside transaction...');
      await txn.insert(
        'places',
        {
          'id': place.id,
          'data': jsonString,
          'timestamp': timestamp,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('[DB] Inserted/Updated place: ${place.id}');

      final countResult = await txn.rawQuery('SELECT COUNT(*) FROM places');
      final count = Sqflite.firstIntValue(countResult);
      print('[DB] Current place count: $count');

      if (count != null && count > 5) {
        final toDelete = count - 5;
        print('[DB] Deleting $toDelete oldest place(s)...');
        final deleted = await txn.rawDelete('''
          DELETE FROM places WHERE id IN (
            SELECT id FROM places ORDER BY timestamp ASC LIMIT $toDelete
          )
        ''');
        print('[DB] Deleted $deleted oldest places.');
      }
    });
  }

  Future<List<HerePlace>> getPlaces() async {
    final db = await database;

    print('[DB] Retrieving places ordered by most recent...');
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'places',
        orderBy: 'timestamp DESC',
        limit: 5,
      );

      print('[DB] Retrieved ${maps.length} places.');
      final places = maps.map((map) {
        print('[DB] Decoding place ID: ${map['data']}');
        return HerePlace.fromJson(jsonDecode(map['data']));
      }).toList();

      return places;
    } catch (e, st) {
      print('[DB] Error retrieving places: $st');
      print('[DB] Error getting places: $e');
      return [];
    }
  }

  Future<void> clearAll() async {
    print('[DB] Clearing all data from places table...');
    final db = await database;
    final deleted = await db.delete('places');
    print('[DB] Cleared $deleted rows from places table.');
  }
}
