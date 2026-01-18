import '../enums/asset_type.dart';

class Country {
  final String name;
  final String region;
  final String code;
  bool canBeReadFrom;
  AssetType flagType;

  Country({required this.code, required this.name, required this.region, this.canBeReadFrom=true, this.flagType=AssetType.png});
}