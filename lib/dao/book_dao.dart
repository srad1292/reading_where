import 'package:flutter/cupertino.dart';
import 'package:reading_where/models/book.dart';
import 'package:sqflite/sqflite.dart';

import '../persistence/database.dart';
import '../persistence/database_column.dart';
import '../persistence/database_table.dart';

class BookDao {
  BookDao();

  Future<List<Book>> getAllBooks({String countryCode = '', String stateCode = ''}) async {
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
}
