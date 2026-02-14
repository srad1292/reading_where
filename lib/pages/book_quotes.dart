import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:reading_where/services/book_service.dart';

import '../models/book.dart';
import '../models/country.dart';
import '../models/country_state.dart';
import '../service_locator.dart';
import '../services/book_location_service.dart';
import 'book_information.dart';

class BookQuotes extends StatefulWidget {
  const BookQuotes({super.key});

  @override
  State<BookQuotes> createState() => _BookQuotesState();
}

class _BookQuotesState extends State<BookQuotes> {
  final BookService _bookService = serviceLocator.get<BookService>();
  final BookLocationService _bookLocationService = serviceLocator.get<BookLocationService>();


  late Future<List<Country>> _countryFuture;
  late Future<List<CountryState>> _countryStateFuture;
  late Future<List<Book>> _booksWithQuotesFuture;
  late Future<List<dynamic>> _combinedFuture;



  @override
  void initState() {
    super.initState();
    _booksWithQuotesFuture = _bookService.getBooksWithQuotes();
    _countryFuture = _bookLocationService.getCountryList();
    _countryStateFuture = _bookLocationService.getCountryStateList();
    _combinedFuture = Future.wait([ _countryFuture, _countryStateFuture, _booksWithQuotesFuture, ]);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: const Text("Saved Quotes"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: SingleChildScrollView(
          child: FutureBuilder(
              future: _combinedFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final countries = snapshot.data![0] as List<Country>;
                final countryStates = snapshot.data![1] as List<CountryState>;
                final books = snapshot.data![2] as List<Book>;

                final Map<String, String> countryNameMap = {
                  for (final c in countries) c.code: c.name,
                };

                final Map<String, String> stateNameMap = {
                  for (final s in countryStates) s.code: s.name,
                };


                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: books.map((book) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(context,
                                MaterialPageRoute( builder: (_) => BookInformation(book: book) ),
                              );

                              setState(() {
                                setState(() {
                                  _booksWithQuotesFuture = _bookService.getBooksWithQuotes();
                                  _combinedFuture = Future.wait([
                                    _countryFuture,
                                    _countryStateFuture,
                                    _booksWithQuotesFuture,
                                  ]);
                                });

                              });
                            },
                            child: Text(
                              book.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.lightBlue
                              ),
                            ),
                          ),
                          Text(
                            (book.stateCode ?? "").isEmpty ? countryNameMap[book.countryCode] ?? ""
                              : "${stateNameMap[book.stateCode] ?? ""}, ${(book.countryCode ?? "").toUpperCase()}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14
                            ),
                          ),
                          ...book.quotes.map((quote) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: MarkdownBody(
                              data: "\"$quote\"",
                              styleSheet: MarkdownStyleSheet(
                                textAlign: WrapAlignment.center
                              ),
                            ),
                          ))
                        ],
                      ),
                    );
                  }).toList(),
                );
              }

          ),
        ),
      ),
    );
  }

}