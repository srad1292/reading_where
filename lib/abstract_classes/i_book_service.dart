import 'dart:typed_data';

import '../models/book.dart';
import '../models/book_search.dart';
import '../models/paginated_book.dart';

abstract class IBookService {
  Future<PaginatedBook> searchForBooks(BookSearch bookSearch);

  Future<Uint8List> fetchCoverBytes(int coverId);

  Future<Book> getBookInformation(Book book);

  Future<Book> getAuthorNames(Book book);
}