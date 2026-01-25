class Book {
  final String title;
  final List<String> authorKey;
  final List<String> authorName;
  final String providerKey;
  final String? coverEditionKey;
  final int? coverId;
  final int? publishYear;
  int? localId;

  String? description;
  String? countryCode;
  DateTime? readDate;
  int? rating;

  Book({
    required this.title,
    required this.authorKey,
    required this.authorName,
    required this.providerKey,
    this.coverEditionKey,
    this.coverId,
    this.publishYear,
    this.countryCode,
    this.rating,
    this.readDate,
    this.localId,
    this.description
  });

  @override
  String toString() {
    return 'Book{title: $title, authorKey: ${authorKey.join(", ")}, authorName: ${authorName.join(", ")}, coverEditionKey: $coverEditionKey, coverId: $coverId, publishYear: $publishYear}';
  }
}