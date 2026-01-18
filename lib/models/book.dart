class Book {
  final String title;
  final List<String> authorKey;
  final List<String> authorName;
  final String? coverEditionKey;
  final int? coverId;
  final int? publishYear;

  String? countryCode;
  DateTime? readDate;
  int? rating;

  Book({
    required this.title,
    required this.authorKey,
    required this.authorName,
    this.coverEditionKey,
    this.coverId,
    this.publishYear,
    this.countryCode,
    this.rating,
    this.readDate,
  });

  @override
  String toString() {
    return 'Book{title: $title, authorKey: ${authorKey.join(", ")}, authorName: ${authorName.join(", ")}, coverEditionKey: $coverEditionKey, coverId: $coverId, publishYear: $publishYear}';
  }
}