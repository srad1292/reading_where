import 'package:flutter/material.dart';
import 'package:reading_where/enums/book_list_type.dart';
import 'package:reading_where/components/book_tile.dart';
import 'package:reading_where/models/country_state.dart';
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
  late Future<List<CountryState>> _countryStateFuture;
  late Future<List<Book>> _savedBooksFuture;


  @override
  void initState() {
    super.initState();
    _countryFuture = _bookLocationService.getCountryList();
    _countryStateFuture = _bookLocationService.getCountryStateList();
    _savedBooksFuture = _bookService.getSavedBooks(excludeCountry: widget.bookListType == BookListType.country);
    _bookService.bookListType = widget.bookListType;

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
        final booksByCountry = _groupBooksByCountry(books);
        final booksByState = _groupBooksByState(books);
        int readLocations = 0;
        int totalLocations = 0;
        if(widget.bookListType == BookListType.country) {
          totalLocations = countries.length;
          readLocations = countries.where((country) {
            final books = booksByCountry[country.code] ?? [];
            return books.any((b) => b.readDate != null);
          }).length;
        } else {
          totalLocations = countryStates.length;
          readLocations = countryStates.where((cs) {
            final books = booksByState[cs.code] ?? [];
            return books.any((b) => b.readDate != null);
          }).length;
        }


        return Scaffold(
          appBar: AppBar(
              backgroundColor: Theme
                  .of(context)
                  .colorScheme
                  .inversePrimary,
              title: Text(_getAppBarTitle(readLocations, totalLocations)),
              centerTitle: true,
              actions: [
                PopupMenuButton(
                  onSelected: (value) async {
                    switch (value) {
                      case 'filter':
                        Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => BookListFilterForm()),
                        );
                        break;
                      case 'add':
                        bool? savedBook = await Navigator.push(context,
                          MaterialPageRoute(builder: (_) => BookLookup()),
                        );

                        if (savedBook == true) {
                          setState(() {
                            _savedBooksFuture = _bookService.getSavedBooks(excludeCountry: widget.bookListType == BookListType.country);
                          });
                        }
                        break;
                    }
                  },
                  itemBuilder: (context) =>
                  [
                    PopupMenuItem(value: 'filter', child: Text('Filter')),
                    PopupMenuItem(value: 'add', child: Text('Add Book')),
                  ],
                ),
              ]

          ),
          body: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 12.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.bookListType == BookListType.country ?
                    _getGroupedCountryWidgets(countries, booksByCountry) :
                    _getStateBookWidgets(countryStates, booksByState)
                ),
              )
          ),
        );
      }
    );
  }

  String _getAppBarTitle(readLocations, totalLocations) {
    String locationType = widget.bookListType == BookListType.country ? "Global" : "United States";
    return "$locationType ($readLocations/$totalLocations)";
  }

  List<Widget> _getGroupedCountryWidgets(List<Country> countries, var booksByCountry) {

    // 1. Get unique regions and sort them
    final regions = countries
        .map((e) => e.region)
        .toSet()
        .toList()
      ..sort();


    return regions.map((region) {
      final regionCountries = countries
          .where((c) => c.region == region)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      final totalCountries = regionCountries.length;
      final readCountries = regionCountries.where((country) {
        final books = booksByCountry[country.code] ?? [];
        return books.any((b) => b.readDate != null);
      }).length;




      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: ExpansionTile(
              title: Text(
                "$region  ($readCountries / $totalCountries)",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                ...regionCountries.map((country) {
                  final books = booksByCountry[country.code] ?? [];
                  final hasReadBooks = books.any((b) => b.readDate != null);

                  return LocationExpansionTile(
                    title: country.name,
                    readFrom: hasReadBooks,
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
                        : books.map<BookTile>((book) {
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

  List<Widget> _getStateBookWidgets(List<CountryState> states, var booksByState) {
      return states.map((countryState) {
          final books = booksByState[countryState.code] ?? [];
          final hasReadBooks = books.any((b) => b.readDate != null);

          return LocationExpansionTile(
            title: countryState.name,
            readFrom: hasReadBooks,
            assetType: AssetType.png,
            assetPath: 'assets/images/state_flags/${countryState.code}.png',
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
                : books.map<BookTile>((book) {
              return BookTile(
                title: book.title,
                isRead: book.readDate != null,
                onTap: () => goToBookInformation(book),
              );
            }).toList(),
          );
    }).toList();
  }

  void goToBookInformation(Book book) async {
    bool? savedBook = await Navigator.push(context,
      MaterialPageRoute( builder: (_) => BookInformation(book: book) ),
    );

    if(savedBook == true) {
      setState(() {
        _savedBooksFuture = _bookService.getSavedBooks(excludeCountry: widget.bookListType == BookListType.country);
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

  Map<String, List<Book>> _groupBooksByState(List<Book> books) {
    final map = <String, List<Book>>{};

    for (final book in books) {
      if((book.stateCode ?? "").isNotEmpty) {
        map.putIfAbsent(book.stateCode!, () => []);
        map[book.stateCode]!.add(book);
      }
    }

    return map;
  }






}
