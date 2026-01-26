import 'dart:convert';

import '../persistence/database_column.dart';
import '../utility/decode_helper.dart';

class Book {
  final String title;
  final List<String> authorKey;
  List<String> authorName;
  final String providerKey;
  final String? coverEditionKey;
  final int? coverId;
  final int? publishYear;
  int? localId;

  String? description;
  String? countryCode;
  String? stateCode;
  DateTime? readDate;
  int? rating;
  bool? excludeFromCountryList;
  String? authorGender;
  String? category;

  Book({
    required this.title,
    required this.authorKey,
    required this.authorName,
    required this.providerKey,
    this.coverEditionKey,
    this.coverId,
    this.publishYear,
    this.countryCode,
    this.stateCode,
    this.rating,
    this.readDate,
    this.localId,
    this.description,
    this.excludeFromCountryList,
    this.authorGender,
    this.category,
  });

  @override
  String toString() {
    return 'Book{title: $title, authorKey: ${authorKey.join(", ")}, authorName: ${authorName.join(", ")}, coverEditionKey: $coverEditionKey, coverId: $coverId, publishYear: $publishYear}';
  }

  Map<String, dynamic> toJson() {
    return {
      DatabaseColumn.localId: localId,
      DatabaseColumn.title: title,
      DatabaseColumn.authorKey: authorKey,
      DatabaseColumn.authorName: authorName,
      DatabaseColumn.providerKey: providerKey,
      DatabaseColumn.coverEditionKey: coverEditionKey,
      DatabaseColumn.coverId: coverId,
      DatabaseColumn.publishYear: publishYear,
      DatabaseColumn.description: description,
      DatabaseColumn.countryCode: countryCode,
      DatabaseColumn.stateCode: stateCode,
      DatabaseColumn.readDate: readDate?.toIso8601String(),
      DatabaseColumn.rating: rating,
      DatabaseColumn.excludeFromCountryList: excludeFromCountryList,
      DatabaseColumn.authorGender: authorGender,
      DatabaseColumn.category: category,

    };
  }

  factory Book.fromJson(Map<String, dynamic> map) {
    return Book(
      title: map[DatabaseColumn.title],
      authorKey: (map[DatabaseColumn.authorKey] as List).cast<String>(),
      authorName: (map[DatabaseColumn.authorName] as List).cast<String>(),
      providerKey: map[DatabaseColumn.providerKey],
      coverEditionKey: map[DatabaseColumn.coverEditionKey],
      coverId: map[DatabaseColumn.coverId],
      publishYear: map[DatabaseColumn.publishYear],
      description: map[DatabaseColumn.description],
      countryCode: map[DatabaseColumn.countryCode],
      stateCode: map[DatabaseColumn.stateCode],
      readDate: map[DatabaseColumn.readDate] != null
          ? DateTime.tryParse(map[DatabaseColumn.readDate])
          : null,
      rating: map[DatabaseColumn.rating],
      localId: map[DatabaseColumn.localId],
      excludeFromCountryList: map[DatabaseColumn.excludeFromCountryList] as bool?,
      authorGender: map[DatabaseColumn.authorGender],
      category: map[DatabaseColumn.category],

    );
  }


  Map<String, dynamic> toMap() {
    return {
      DatabaseColumn.localId: localId,
      DatabaseColumn.title: title,
      DatabaseColumn.authorKey: jsonEncode(authorKey),
      DatabaseColumn.authorName: jsonEncode(authorName),
      DatabaseColumn.providerKey: providerKey,
      DatabaseColumn.coverEditionKey: coverEditionKey,
      DatabaseColumn.coverId: coverId,
      DatabaseColumn.publishYear: publishYear,
      DatabaseColumn.description: description,
      DatabaseColumn.countryCode: countryCode,
      DatabaseColumn.stateCode: stateCode,
      DatabaseColumn.readDate: readDate?.toIso8601String(),
      DatabaseColumn.rating: rating,
      DatabaseColumn.excludeFromCountryList: excludeFromCountryList == true ? 1 : 0,
      DatabaseColumn.authorGender: authorGender,
      DatabaseColumn.category: category,

    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      title: map[DatabaseColumn.title],
      authorKey: DecodeHelper.decodeListString(map[DatabaseColumn.authorKey]),
      authorName: DecodeHelper.decodeListString(map[DatabaseColumn.authorName]),
      providerKey: map[DatabaseColumn.providerKey],
      coverEditionKey: map[DatabaseColumn.coverEditionKey],
      coverId: map[DatabaseColumn.coverId],
      publishYear: map[DatabaseColumn.publishYear],
      description: map[DatabaseColumn.description],
      countryCode: map[DatabaseColumn.countryCode],
      stateCode: map[DatabaseColumn.stateCode],
      readDate: map[DatabaseColumn.readDate] != null
          ? DateTime.tryParse(map[DatabaseColumn.readDate])
          : null,
        rating: map[DatabaseColumn.rating],
      localId: map[DatabaseColumn.localId],
      excludeFromCountryList: (map[DatabaseColumn.excludeFromCountryList] ?? 0) == 1,
      authorGender: map[DatabaseColumn.authorGender],
      category: map[DatabaseColumn.category],

    );
  }



}