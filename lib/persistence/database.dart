import 'dart:async';
import 'package:path/path.dart';
import 'package:reading_where/persistence/seed_data.dart';
import 'package:sqflite/sqflite.dart';

import 'database_column.dart';
import 'database_table.dart';

const int dbVersion = 2;

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  late Database _database;
  bool instanceMade = false;

  Future<Database> get database async {
    if(instanceMade) {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  initDB() async {
    String path = join(await getDatabasesPath(), 'sradford_reading_where_database.db');
    return await openDatabase(path,
      version: dbVersion,
      onOpen: (db) {},
      onCreate: _createCallback,
      onUpgrade: _upgradeCallback
    );
  }

  void _createCallback(Database db, int version) async {
    await db.execute(_getCountrySchema());
    await db.execute(_getCountryStateSchema());
    await db.execute(_getBookSchema());

    await _seedCountries(db);
    await _seedCountryStates(db);
  }

  String _getCountrySchema() {
    return "CREATE TABLE ${DatabaseTable.country} ("
        "${DatabaseColumn.code} TEXT PRIMARY KEY,"
        "${DatabaseColumn.name} TEXT,"
        "${DatabaseColumn.region} TEXT,"
        "${DatabaseColumn.canBeReadFrom} INTEGER,"
        "${DatabaseColumn.flagType} TEXT" // Enum string
        ");";
  }

  String _getCountryStateSchema() {
    return "CREATE TABLE ${DatabaseTable.countryState} ("
        "${DatabaseColumn.code} TEXT PRIMARY KEY,"
        "${DatabaseColumn.name} TEXT,"
        "${DatabaseColumn.countryCode} TEXT"
        ");";
  }

  String _getBookSchema() {
    return "CREATE TABLE ${DatabaseTable.book} ("
        "${DatabaseColumn.localId} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${DatabaseColumn.title} TEXT,"
        "${DatabaseColumn.authorKey} TEXT,"          // JSON string
        "${DatabaseColumn.authorName} TEXT,"        // JSON string
        "${DatabaseColumn.providerKey} TEXT,"
        "${DatabaseColumn.coverEditionKey} TEXT,"
        "${DatabaseColumn.coverId} INTEGER,"
        "${DatabaseColumn.publishYear} INTEGER,"
        "${DatabaseColumn.description} TEXT,"
        "${DatabaseColumn.countryCode} TEXT,"
        "${DatabaseColumn.stateCode} TEXT,"
        "${DatabaseColumn.readDate} TEXT,"          // ISO8601 string
        "${DatabaseColumn.rating} INTEGER"
        ");";
  }

  Future<void> _seedCountries(Database db) async {
    final countries = SeedData.getCountryData();

    final batch = db.batch();

    for (final country in countries) {
      batch.insert(
        DatabaseTable.country,
        country.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> _seedCountryStates(Database db) async {
    final states = SeedData.getCountryStateData();

    final batch = db.batch();

    for (final cs in states) {
      batch.insert(
        DatabaseTable.countryState,
        cs.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  void _upgradeCallback(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute( "ALTER TABLE ${DatabaseTable.book} ADD COLUMN ${DatabaseColumn.excludeFromCountryList} INTEGER DEFAULT 0");
      await db.execute( "ALTER TABLE ${DatabaseTable.book} ADD COLUMN ${DatabaseColumn.authorGender} TEXT");
      await db.execute( "ALTER TABLE ${DatabaseTable.book} ADD COLUMN ${DatabaseColumn.category} TEXT");

    }
  }






}