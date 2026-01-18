import 'package:reading_where/abstract_classes/i_paginated_impl.dart';
import 'package:reading_where/models/paginated_book.dart';

import 'open_item.dart';

class OpenPagination implements IPaginatedImpl {
  final int numFound;
  final int start;
  final List<OpenItem> documents;

  OpenPagination({required this.numFound, required this.start, required this.documents});

  factory OpenPagination.fromJson(Map<String, dynamic> json) {
    return OpenPagination(
        numFound: json['numFound'] ?? 0,
        start: json['start'] ?? 0,
        documents: (json['docs'] as List<dynamic>?)
            ?.map((e) => OpenItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
            []
    );
  }

  @override
  PaginatedBook toPaginatedBook() {
    return PaginatedBook(
        total: numFound,
        start: start,
        books: documents.map((e) => e.toBook()).toList()
    );
  }


}