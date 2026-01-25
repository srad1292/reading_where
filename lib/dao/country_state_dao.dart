import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import '../models/country_state.dart';
import '../persistence/database.dart';
import '../persistence/database_column.dart';
import '../persistence/database_table.dart';

class CountryStateDao {
  CountryStateDao();

  Future<List<CountryState>> getAllCountryStates() async {
    try {
      Database db = await DBProvider.db.database;
      List<Map<String, dynamic>> dbData = await db.query(
        DatabaseTable.countryState,
        orderBy: "${DatabaseColumn.name} ASC",
      );
      List<CountryState> states = [];
      if (dbData.isNotEmpty) {
        states = List.generate(dbData.length, (index) {
          return CountryState.fromMap(dbData[index]);
        });
      }
      return states;
    } catch (e) {
      debugPrint("Error in get all country states");
      debugPrint(e.toString());
      return [];
    }
  }
}
