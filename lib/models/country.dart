import '../enums/asset_type.dart';
import '../persistence/database_column.dart';

class Country {
  final String name;
  final String region;
  final String code;
  bool canBeReadFrom;
  AssetType flagType;

  Country({required this.code, required this.name, required this.region, this.canBeReadFrom=true, this.flagType=AssetType.png});

  Map<String, dynamic> toMap() {
    return {
      DatabaseColumn.code: code,
      DatabaseColumn.name: name,
      DatabaseColumn.region: region,
      DatabaseColumn.canBeReadFrom: canBeReadFrom ? 1 : 0,
      DatabaseColumn.flagType: flagType.name, // store enum as string
    };
  }

  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
      code: map[DatabaseColumn.code],
      name: map[DatabaseColumn.name],
      region: map[DatabaseColumn.region],
      canBeReadFrom: (map[DatabaseColumn.canBeReadFrom] ?? 0) == 1,
      flagType: AssetType.values.firstWhere(
            (e) => e.name == map[DatabaseColumn.flagType],
        orElse: () => AssetType.png,
      ),
    );
  }

}