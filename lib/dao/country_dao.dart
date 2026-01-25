import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import '../models/country.dart';
import '../persistence/database.dart';
import '../persistence/database_column.dart';
import '../persistence/database_table.dart';

class CountryDao {
  CountryDao();

  Future<List<Country>> getAllCountries() async {
    try {
      Database db = await DBProvider.db.database;
      List<Map<String, dynamic>> dbData = await db.query(
        DatabaseTable.country,
        orderBy: "${DatabaseColumn.name} ASC",
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
}
