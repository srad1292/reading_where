import 'dart:typed_data';

import 'package:reading_where/abstract_classes/i_book_service.dart';
import 'package:reading_where/service_locator.dart';

import '../models/book_search.dart';
import '../models/paginated_book.dart';
import 'open_library_service.dart';

class BookService implements IBookService {

  late OpenLibraryService implementedService;

  BookService() {
    implementedService = serviceLocator.get<OpenLibraryService>();
  }

  @override
  Future<PaginatedBook> searchForBooks(BookSearch bookSearch) {
    return implementedService.searchForBooks(bookSearch);
  }

  @override
  Future<Uint8List> fetchCoverBytes(int coverId) {
    return implementedService.fetchCoverBytes(coverId);
  }


}