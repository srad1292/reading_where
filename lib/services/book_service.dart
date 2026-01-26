import 'dart:typed_data';

import 'package:reading_where/abstract_classes/i_book_service.dart';
import 'package:reading_where/dao/book_dao.dart';
import 'package:reading_where/service_locator.dart';


import '../enums/book_list_type.dart';
import '../models/book.dart';
import '../models/book_search.dart';
import '../models/paginated_book.dart';
import 'open_library_service.dart';

class BookService implements IBookService {
  late OpenLibraryService implementedService;
  late BookDao bookDao;

  List<Book> savedBooks = [];
  late BookListType bookListType;

  BookService() {
    implementedService = serviceLocator.get<OpenLibraryService>();
    bookDao = BookDao();
  }

  @override
  Future<PaginatedBook> searchForBooks(BookSearch bookSearch) {
    return implementedService.searchForBooks(bookSearch);
  }

  @override
  Future<Book> getBookInformation(Book book) {
    return implementedService.getBookInformation(book);
  }

  @override
  Future<Book> getAuthorNames(Book book) async {
    return await implementedService.getAuthorNames(book);
  }

  @override
  Future<Uint8List> fetchCoverBytes(int coverId) {
    return coverId == -1 ? Future.value(Uint8List(0)) : implementedService.fetchCoverBytes(coverId);
  }

  Future<List<Book>> getSavedBooks({String countryCode = '', String stateCode = '', bool excludeCountry = false}) async {
    return bookDao.getAllBooks(countryCode: countryCode, stateCode: stateCode, excludeCountry: excludeCountry);
  }



  Future<Book> saveBook(Book book) async {
    return bookDao.addOrUpdateBook(book);
  }

  Future<bool> deleteBook(int localId) async {
    return bookDao.deleteBook(localId: localId);
  }



  Future<List<Book>> _mockGetSavedBooks() {
    if(savedBooks.isEmpty) {
      savedBooks = _getMockBookList();
    }
    return Future.value(savedBooks);
  }

  List<Book> _getMockBookList() {
    return [
      Book(
          localId: 0,
          title: "The Doors of Perception / Heaven and Hell",
          providerKey: "/works/OL64442W",
          publishYear: 1956,
          coverId: 39648,
          coverEditionKey: "OL9238585M",
          authorKey: ["OL19767A"],
          authorName: ["Aldous Huxley"],
          countryCode: "dz",
          readDate: DateTime(2024, 2, 4)
      ),
      Book(
          localId: 1,
          title: "The marriage of Heaven and Hell",
          providerKey: "/works/OL575441W",
          publishYear: 1793,
          coverId: 118161,
          coverEditionKey: "OL1089176M",
          authorKey: ["OL41961A"],
          authorName: ["William Blake"],
          countryCode: "dz",
          readDate: DateTime(2024, 4, 14)
      ),
      Book(
        localId: 2,
        title: "Heaven and Hell",
        providerKey: "/works/OL56103W",
        publishYear: 1987,
        coverId: 4120991,
        coverEditionKey: "OL2388510M",
        authorKey: ["OL31209A"],
        authorName: ["John Jakes"],
        countryCode: "dz",
      ),
      Book(
          localId: 3,
          title: "Heaven and hell",
          providerKey: "/works/OL11733156W",
          publishYear: 2007,
          coverId: 13189413,
          coverEditionKey: "OL37791695M",
          authorKey: ["OL4983363A"],
          authorName: ["Don Felder"],
          countryCode: "ao",
          readDate: DateTime(2024, 4, 14)),
      Book(
        localId: 4,
        title: "Heaven and hell",
        providerKey: "/works/OL20705835W",
        publishYear: 2020,
        coverId: 9383131,
        coverEditionKey: "OL27998067M",
        authorKey: ["OL7959877A"],
        authorName: ["Bart D. Ehrman"],
        countryCode: "ao",
      ),
      Book(
          localId: 5,
          title: "Heaven and Hell",
          providerKey: "/works/OL64410W",
          publishYear: 1956,
          coverId: 12628641,
          coverEditionKey: "OL7281995M",
          authorKey: ["OL19767A"],
          authorName: ["Aldous Huxley"],
          countryCode: "ao",
          readDate: DateTime(2012, 4, 14)
      ),
      Book(
        localId: 6,
        title: "Silver screen fiend",
        providerKey: "/works/OL19991330W",
        publishYear: 2015,
        coverId: 9566268,
        coverEditionKey: "OL27171443M",
        authorKey: ["OL7220992A"],
        authorName: ["Patton Oswalt"],
        countryCode: "us",
        stateCode: "ca",
        readDate: DateTime(2012, 4, 14),
        rating: 5
      ),
      Book(
          localId: 7,
          title: "James",
          providerKey: "/works/OL36506504W",
          publishYear: 2024,
          coverId: 15094964,
          coverEditionKey: "OL50721432M",
          authorKey: ["OL7220992A"],
          authorName: ["Percival L. Everett"],
          countryCode: "us",
          stateCode: "mo",
          readDate: DateTime(2012, 4, 14),
          rating: 4
      )
    ];
  }





}