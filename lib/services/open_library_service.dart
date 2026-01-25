import 'dart:convert';
import 'dart:typed_data';

import 'package:reading_where/abstract_classes/i_book_service.dart';
import 'package:reading_where/models/book.dart';
import 'package:reading_where/models/book_search.dart';
import 'package:reading_where/models/open_library/open_item.dart';
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
      "fields": "title,author_name,author_key,cover_i,cover_edition_key,first_publish_year,isbn"
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


  @override
  Future<Uint8List> fetchCoverBytes(int coverId) async {
    final url = "https://covers.openlibrary.org/b/id/$coverId-M.jpg";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    else {
      throw Exception("Failed to load image");
    }
  }

  @override
  Future<Book> getBookInformation(Book book) async {
    final url = "https://openlibrary.org/works/OL45804W.json/${book.providerKey}-M.jpg";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      OpenItem item = OpenItem.fromJson(json);
      book.description = item.description;
      return book;
    }
    else {
      throw Exception("Failed to load image");
    }
  }



}