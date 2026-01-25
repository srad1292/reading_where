import '../persistence/database_column.dart';

class CountryState {
  final String code;
  final String name;
  final String countryCode;

  CountryState({required this.code, required this.name, required this.countryCode});

  Map<String, dynamic> toMap() {
    return {
      DatabaseColumn.code: code,
      DatabaseColumn.name: name,
      DatabaseColumn.countryCode: countryCode,
    };
  }

  factory CountryState.fromMap(Map<String, dynamic> map) {
    return CountryState(
      code: map[DatabaseColumn.code],
      name: map[DatabaseColumn.name],
      countryCode: map[DatabaseColumn.countryCode],
    );
  }

}