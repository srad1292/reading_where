import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
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
      "fields": "title,author_name,author_key,cover_i,cover_edition_key,first_publish_year,key"
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

    final decoded = utf8.decode(response.bodyBytes);
    debugPrint(decoded);
    final json = jsonDecode(decoded);
    OpenPagination openPagination = OpenPagination.fromJson(json);
    return openPagination.toPaginatedBook();
  }

  @override
  Future<Book> getAuthorNames(Book book) async {
    try {
      if(book.localId != null) {
        debugPrint("Already have a description so just use it");
        return book;
      }

      final keysToFetch = <String>[];
      final latinNames = <String>[];
      for (int i = 0; i < book.authorName.length; i++) {
        final name = book.authorName[i];
        if (!isMostlyLatin(name)) {
          debugPrint("${book.authorName[i]} should be retrieved");
          keysToFetch.add(book.authorKey[i]);
        } else {
          debugPrint("${book.authorName[i]} good to go");
          latinNames.add(book.authorName[i]);
        }
      }


      final limitedKeys = keysToFetch.take(3);

      if(limitedKeys.isEmpty) {
        debugPrint("No need to get any author details");
        return book;
      }

      final futures = limitedKeys.map((key) async {
        final url = "https://openlibrary.org/authors/$key.json";
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final decoded = utf8.decode(response.bodyBytes);
          final json = jsonDecode(decoded);
          return json;
        }

        return null;
      });

      final results = await Future.wait(futures);

      final englishNames = results
          .whereType<Map<String, dynamic>>()
          .map((json) => json['personal_name'] ?? json['name'] ?? (json['alternate_names'] as List?)?.first ?? "")
          .where((name) => name.isNotEmpty)
          .cast<String>()
          .map((e) => normalizeAuthorName(e))
          .toList();

      englishNames.addAll(latinNames);
      book.authorName = englishNames;
      return book;
    } catch(e, st) {
      debugPrint("Get author information threw: ${e.toString()}");
      debugPrint(st.toString());
      return book;
    }
  }

  bool isMostlyLatin(String s) {
    final latin = RegExp(r'^[\u0000-\u024F\u1E00-\u1EFF\s\.\-\,]+$');
    return latin.hasMatch(s);
  }

  String normalizeAuthorName(String name) {
    final parts = name.split(',');

    // "Last, First"
    if (parts.length == 2) {
      final last = parts[0].trim();
      final first = parts[1].trim();
      return "$first $last";
    }

    // Anything else: leave untouched
    return name.trim();
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
    try {
      if((book.description ?? "").isNotEmpty) {
        debugPrint("Already have a description so just use it");
        return book;
      }
      final url = "https://openlibrary.org/${book.providerKey}.json";
      debugPrint("Getting book info using url: $url");
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final json = jsonDecode(decoded);
        OpenItem item = OpenItem.fromJson(json);
        book.description = item.description;
        return book;
      }
      else {
        debugPrint("Failed to load book: ${response.statusCode}");
        return book;
      }
    } catch(e) {
      debugPrint("Get book information threw: ${e.toString()}");
      return book;
    }

  }



}