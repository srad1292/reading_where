import 'package:flutter/material.dart';
import 'package:reading_where/enums/book_list_type.dart';
import 'package:reading_where/components/book_tile.dart';
import 'package:reading_where/pages/book_information.dart';
import 'package:reading_where/pages/book_list_filter_form.dart';
import 'package:reading_where/service_locator.dart';
import 'package:reading_where/services/book_location_service.dart';
import 'package:reading_where/services/book_service.dart';

import '../components/location_expansion_tile.dart';
import '../enums/asset_type.dart';
import '../models/book.dart';
import '../models/country.dart';
import 'book_lookup.dart';

class BookList extends StatefulWidget {
  final BookListType bookListType;

  const BookList({super.key, required this.bookListType});

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {

  final BookLocationService _bookLocationService = serviceLocator.get<BookLocationService>();
  final BookService _bookService = serviceLocator.get<BookService>();

  late Future<List<Country>> _countryFuture;
  late Future<List<Book>> _savedBooksFuture;

  @override
  void initState() {
    super.initState();
    _countryFuture = _bookLocationService.getCountryList();
    _savedBooksFuture = _bookService.getSavedBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_getAppBarTitle()),
        centerTitle: true,
          actions: [
            PopupMenuButton(
              onSelected: (value) async {
                switch (value) {
                  case 'filter':
                    Navigator.push(context,
                      MaterialPageRoute(builder: (_) => BookListFilterForm()),
                    );
                    break;
                  case 'add':
                    Book? savedBook = await Navigator.push(context,
                      MaterialPageRoute( builder: (_) => BookLookup() ),
                    );

                    if(savedBook != null) {
                      setState(() {
                        _savedBooksFuture = _bookService.getSavedBooks();
                      });
                    }
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'filter', child: Text('Filter')),
                PopupMenuItem(value: 'add', child: Text('Add Book')),
              ],
            ),
          ]

      ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: FutureBuilder(
            future: Future.wait([
              _countryFuture,
              _savedBooksFuture
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final countries = snapshot.data![0] as List<Country>;
              final books = snapshot.data![1] as List<Book>;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _getGroupedCountryWidgets(countries, books),
                ),
              );
            },
          ),
        )

    );
  }

  String _getAppBarTitle() {
    return widget.bookListType == BookListType.country ? "Global" : "United States";
  }

  // List<Widget> _getCountryWidgets() {
  //   return _getCountryList().map((e) => LocationExpansionTile(
  //       title: e.name,
  //       assetType: e.flagType,
  //       assetPath: e.flagType == AssetType.svg ?
  //         'assets/images/country_flags_svg/${e.code}.svg' :
  //         'assets/images/country_flags_png/${e.code}.png',
  //       children: [
  //         BookTile(title: "Test", isRead: e.name.startsWith("C"))
  //       ]
  //   ),).toList();
  // }

  List<Widget> _getGroupedCountryWidgets(List<Country> countries, List<Book> savedBooks) {
    final booksByCountry = _groupBooksByCountry(savedBooks);

    // 1. Get unique regions and sort them
    final regions = countries
        .map((e) => e.region)
        .toSet()
        .toList()
      ..sort();

    // 2. Build widgets grouped by region
    return regions.map((region) {
      // Countries in this region
      final regionCountries = countries
          .where((c) => c.region == region)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: ExpansionTile(
              title: Text(
                region,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                ...regionCountries.map((country) {
                  final books = booksByCountry[country.code] ?? [];

                  return LocationExpansionTile(
                    title: country.name,
                    assetType: country.flagType,
                    assetPath: country.flagType == AssetType.svg
                        ? 'assets/images/country_flags_svg/${country.code}.svg'
                        : 'assets/images/country_flags_png/${country.code}.png',
                    children: books.isEmpty
                        ? [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "No books yet",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      )
                    ]
                        : books.map((book) {
                      return BookTile(
                        title: book.title,
                        isRead: book.readDate != null,
                        onTap: () => goToBookInformation(book),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  void goToBookInformation(Book book) async {
    Book? savedBook = await Navigator.push(context,
      MaterialPageRoute( builder: (_) => BookInformation(book: book) ),
    );

    if(savedBook != null) {
      setState(() {
        _savedBooksFuture = _bookService.getSavedBooks();
      });
    }
  }


  Map<String, List<Book>> _groupBooksByCountry(List<Book> books) {
    final map = <String, List<Book>>{};

    for (final book in books) {
      if((book.countryCode ?? "").isNotEmpty) {
        map.putIfAbsent(book.countryCode!, () => []);
        map[book.countryCode]!.add(book);
      }
    }

    return map;
  }






}
