import 'package:reading_where/abstract_classes/i_item_impl.dart';
import 'package:reading_where/models/book.dart';

class OpenItem implements IItemImpl {
  final String title;
  final List<String> authorKey;
  final List<String> authorName;
  final String key;
  final String? description;
  final String? coverEditionKey;
  final int? coverI;
  final int? firstPublishYear;

  OpenItem({
    required this.title,
    required this.authorKey,
    required this.authorName,
    required this.key,
    this.description,
    this.coverEditionKey,
    this.coverI,
    this.firstPublishYear,
  });

  factory OpenItem.fromJson(Map<String, dynamic> json) {
    return OpenItem(
      title: json['title'] ?? '',
      authorKey: (json['author_key'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      authorName: (json['author_name'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      key: json['key'] ?? '',
      coverEditionKey: json['cover_edition_key'],
      coverI: json['cover_i'],
      firstPublishYear: json['first_publish_year'],
      description: json['description'] ?? '',
    );
  }

  @override
  Book toBook() {
    return Book(
      title: title,
      authorKey: authorKey,
      authorName: authorName,
      coverEditionKey: coverEditionKey,
      providerKey: key,
      coverId: coverI,
      publishYear: firstPublishYear,
      description: description
    );
  }
}
