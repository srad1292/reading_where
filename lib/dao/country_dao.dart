import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import '../models/country.dart';
import '../persistence/database.dart';
import '../persistence/database_column.dart';
import '../persistence/database_table.dart';

class CountryDao {
  CountryDao();

  Future<List<Country>> getAllCountries({bool excludeUnavailable = true}) async {
    try {
      Database db = await DBProvider.db.database;

      final whereClauses = <String>[];
      final whereArgs = <dynamic>[];
      if (excludeUnavailable == true) {
        whereClauses.add("${DatabaseColumn.canBeReadFrom} = ?");
        whereArgs.add(1);
      }

      List<Map<String, dynamic>> dbData = await db.query(
        DatabaseTable.country,
        orderBy: "${DatabaseColumn.name} ASC",
        where: whereClauses.isEmpty ? null : whereClauses.join(" AND "),
        whereArgs: whereClauses.isEmpty ? null : whereArgs,
      );
      List<Country> countries = [];
      if (dbData.isNotEmpty) {
        countries = List.generate(dbData.length, (index) {
          return Country.fromMap(dbData[index]);
        });
      }
      return countries;
    } catch (e) {
      debugPrint("Error in get all countries");
      debugPrint(e.toString());
      return [];
    }
  }

  Future<Country> updateCountry(Country country) async {
    try {
      Database db = await DBProvider.db.database;

      await db.update(
        DatabaseTable.country,
        {
          DatabaseColumn.canBeReadFrom: country.canBeReadFrom,
        },
        where: "${DatabaseColumn.code} = ?",
        whereArgs: [country.code],
      );

      return country;
    } catch (e) {
      debugPrint("Error in update country");
      debugPrint(e.toString());
      rethrow;
    }
  }

}
