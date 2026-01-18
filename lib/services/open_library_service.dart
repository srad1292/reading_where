import 'dart:convert';

import 'package:reading_where/abstract_classes/i_book_service.dart';
import 'package:reading_where/models/book_search.dart';
import 'package:reading_where/models/paginated_book.dart';

import '../models/open_library/open_pagination.dart';
import 'package:http/http.dart' as http;


class OpenLibraryService implements IBookService {


  OpenLibraryService();

  @override
  Future<PaginatedBook> searchForBooks(BookSearch bookSearch) async {
    const String baseUrl = "openlibrary.org";

    // Build query parameters dynamically
    final queryParams = <String, String>{
      "page": bookSearch.page.toString(),
      "limit": bookSearch.limit.toString(),
      "language": "eng",
    };

    // Add only non-empty fields
    if (bookSearch.author.isNotEmpty) {
      queryParams["author"] = bookSearch.author;
    }
    if (bookSearch.title.isNotEmpty) {
      queryParams["title"] = bookSearch.title;
    }
    if (bookSearch.subject.isNotEmpty) {
      queryParams["subject"] = bookSearch.subject;
    }

    // Build the final URI
    final uri = Uri.https(baseUrl, "/search.json", queryParams);

    // Make the request
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Failed to load books");
    }

    final json = jsonDecode(response.body);
    OpenPagination openPagination = OpenPagination.fromJson(json);
    return openPagination.toPaginatedBook();
  }



}