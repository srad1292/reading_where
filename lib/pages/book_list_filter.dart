import 'package:flutter/material.dart';

import '../components/book_tile.dart';
import '../models/book.dart';
import '../models/country.dart';
import '../models/country_state.dart';
import '../service_locator.dart';
import '../services/book_location_service.dart';
import '../services/book_service.dart';
import 'book_information.dart';

class BookListFilter extends StatefulWidget {
  const BookListFilter({super.key});

  @override
  State<BookListFilter> createState() => _BookListFilterState();
}

class _BookListFilterState extends State<BookListFilter> {
  final BookLocationService _bookLocationService = serviceLocator.get<BookLocationService>();
  final BookService _bookService = serviceLocator.get<BookService>();

  late Future<List<Country>> _countryFuture;
  late Future<List<CountryState>> _countryStateFuture;
  late Future<List<Book>> _savedBooksFuture;

  TextEditingController _searchController = TextEditingController(text: '');


  @override
  void initState() {
    super.initState();
    _countryFuture = _bookLocationService.getCountryList();
    _countryStateFuture = _bookLocationService.getCountryStateList();
    _savedBooksFuture = _bookService.getSavedBooks(sortByName: true);
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([
          _countryFuture,
          _countryStateFuture,
          _savedBooksFuture
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final countries = snapshot.data![0] as List<Country>;
          final countryStates = snapshot.data![1] as List<CountryState>;
          final books = snapshot.data![2] as List<Book>;
          String searchText = _searchController.text.toLowerCase();
          List<Book> filteredBooks = books.where((book) {
            return book.title.toLowerCase().contains(searchText) ||
              book.authorName.any((authorName) => authorName.toLowerCase().contains(searchText));
          }).toList();

          return Scaffold(
            appBar: AppBar(
                backgroundColor: Theme
                    .of(context)
                    .colorScheme
                    .inversePrimary,
                title: Text("Search Your Books"),
                centerTitle: true,
            ),
            body: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: "Search",
                          border: UnderlineInputBorder()
                        ),
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _getBookListWidgets(countries, countryStates, filteredBooks)
                      ),
                    ],
                  ),
                )
            ),
          );
        }
    );
  }

  List<Widget> _getBookListWidgets(List<Country> countries, List<CountryState> states, List<Book> books) {
    return books.map<BookTile>((book) {
        return BookTile(
          book: book,
          onTap: () => goToBookInformation(book),
        );
    }).toList();
  }

  void goToBookInformation(Book book) async {
    bool? savedBook = await Navigator.push(context,
      MaterialPageRoute( builder: (_) => BookInformation(book: book) ),
    );

    if(savedBook == true) {
      setState(() {
        _savedBooksFuture = _bookService.getSavedBooks(sortByName: true);
      });
    }
  }
}
