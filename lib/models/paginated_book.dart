import 'book.dart';

class PaginatedBook {
  final int total;
  final int start;
  final List<Book> books;

  PaginatedBook({required this.total, required this.start, required this.books});
}