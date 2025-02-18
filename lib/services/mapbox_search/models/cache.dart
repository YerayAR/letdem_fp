import 'dart:convert';

import 'package:letdem/services/mapbox_search/models/model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE places (
            id TEXT PRIMARY KEY,
            data TEXT
          )
        ''');
      },
    );
  }

  Future<void> savePlace(MapBoxPlace place) async {
    final db = await database;
    final jsonString = jsonEncode(place.toJson());
    await db.insert(
      'places',
      {'id': place.mapboxId, 'data': jsonString},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MapBoxPlace>> getPlaces() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('places');
    return maps
        .map((map) => MapBoxPlace.fromJson(jsonDecode(map['data'])))
        .toList();
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('places');
  }
}
