import 'package:flutter/cupertino.dart';
import 'package:reading_where/models/book.dart';
import 'package:sqflite/sqflite.dart';

import '../models/import_result.dart';
import '../persistence/database.dart';
import '../persistence/database_column.dart';
import '../persistence/database_table.dart';

class BookDao {
  BookDao();

  Future<Book> addOrUpdateBook(Book book) async {
    try {
      Database db = await (DBProvider.db.database);
      int insertedId = await db.insert(
          DatabaseTable.book,
          book.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace
      );
      book.localId = insertedId;
      return book;

    } on Exception catch (e) {
      debugPrint("Error adding or replacing book");
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<ImportResult> insertManyBooks(List<Book> books) async {
    try {
      final db = await DBProvider.db.database;

      final batch = db.batch();

      for (final book in books) {
        batch.insert(
          DatabaseTable.book,
          book.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      var results = await batch.commit(noResult: false);
      int inserted = 0;
      int skipped = 0;
      for (final result in results) {
        if (result is int) { inserted++; }
        else { skipped++; }
      }
      return ImportResult(success: true, inserted: inserted, skipped: skipped);
    } on Exception catch (e) {
      debugPrint("Error importing books into db: ${e.toString()}");
      return ImportResult(success: false, inserted: 0, skipped: 0);

    }
  }


  Future<List<Book>> getAllBooks({String countryCode = '', String stateCode = '', bool excludeCountry = false, bool excludeUnread = false}) async {
    try {
      Database db = await DBProvider.db.database;
      final whereClauses = <String>[];
      final whereArgs = <dynamic>[];
      if (countryCode.isNotEmpty) {
        whereClauses.add("${DatabaseColumn.countryCode} = ?");
        whereArgs.add(countryCode);
      }
      if (stateCode.isNotEmpty) {
        whereClauses.add("${DatabaseColumn.stateCode} = ?");
        whereArgs.add(stateCode);
      }
      if (excludeCountry == true) {
        whereClauses.add("${DatabaseColumn.excludeFromCountryList} = ?");
        whereArgs.add(0);
      }
      if (excludeUnread == true) {
        whereClauses.add("${DatabaseColumn.readDate} is not null");
      }

      final dbData = await db.query(
        DatabaseTable.book,
        where: whereClauses.isEmpty ? null : whereClauses.join(" AND "),
        whereArgs: whereClauses.isEmpty ? null : whereArgs,
      );
      List<Book> books = [];
      if (dbData.isNotEmpty) {
        books = List.generate(dbData.length, (index) {
          return Book.fromMap(dbData[index]);
        });
      }
      return books;
    } catch (e) {
      debugPrint("Error in get all books");
      debugPrint(e.toString());
      return [];
    }
  }

  Future<List<Book>> getBooksWithQuotes() async {
    try {
      Database db = await DBProvider.db.database;
      final whereClauses = <String>[];
      whereClauses.add("${DatabaseColumn.readDate} is not null");
      whereClauses.add("${DatabaseColumn.quotes} is not null");
      whereClauses.add("${DatabaseColumn.quotes} != '[]'");


      final dbData = await db.query(
        DatabaseTable.book,
        where: whereClauses.isEmpty ? null : whereClauses.join(" AND "),
        orderBy: "${DatabaseColumn.readDate} ASC"
      );
      List<Book> books = [];
      if (dbData.isNotEmpty) {
        books = List.generate(dbData.length, (index) {
          return Book.fromMap(dbData[index]);
        });
      }
      return books;
    } catch (e) {
      debugPrint("Error in get books with quotes");
      debugPrint(e.toString());
      return [];
    }
  }


  Future<bool> deleteBook({required int localId}) async {
    if(localId <= 0) {
      return true;
    }

    Database db = await DBProvider.db.database;
    try {
      int deletedCount = await db.delete(DatabaseTable.book, where: "${DatabaseColumn.localId} = ?", whereArgs: [localId]);

      if (deletedCount > 0) {
        debugPrint("Count of deleted books: $deletedCount");
      }

      return true;
    } on Exception catch (e) {
      debugPrint("Error deleting book with id: $localId");
      debugPrint(e.toString());
      return false;
    }

  }
}
