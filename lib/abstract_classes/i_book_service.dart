import 'dart:typed_data';

import '../models/book_search.dart';
import '../models/paginated_book.dart';

abstract class IBookService {
  Future<PaginatedBook> searchForBooks(BookSearch bookSearch);

  Future<Uint8List> fetchCoverBytes(int coverId);
}