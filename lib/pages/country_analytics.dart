import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:reading_where/components/analytics/kpi_display.dart';
import 'package:reading_where/enums/book_category.dart';

import '../components/analytics/kpi_section.dart';
import '../enums/gender.dart';
import '../models/analytics/kpi_item.dart';
import '../models/book.dart';
import '../models/country.dart';
import '../service_locator.dart';
import '../services/book_location_service.dart';
import '../services/book_service.dart';

class CountryAnalytics extends StatefulWidget {
  const CountryAnalytics({super.key});

  @override
  State<CountryAnalytics> createState() => _CountryAnalyticsState();
}

class _CountryAnalyticsState extends State<CountryAnalytics> {

  final BookLocationService _bookLocationService = serviceLocator.get<BookLocationService>();
  final BookService _bookService = serviceLocator.get<BookService>();

  late Future<List<Country>> _countryFuture;
  late Future<List<Book>> _savedBooksFuture;

  @override
  void initState() {
    super.initState();
    _countryFuture = _bookLocationService.getCountryList();
    _savedBooksFuture = _bookService.getSavedBooks(excludeCountry: true, excludeUnread: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Country Analytics"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: Future.wait([
            _countryFuture,
            _savedBooksFuture
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            List<Country> countries = snapshot.data![0] as List<Country>;
            List<Book> books = snapshot.data![1] as List<Book>;

            List<String> countriesReadFrom = [];

            int maleRead = 0;
            int femaleRead = 0;

            int fictionCount = 0;
            int nonFictionCount = 0;

            int totalRating = 0;
            int ratedCount = 0;
            double averageRating = 0;

            for(Book book in books) {
              if(book.readDate == null) {
                debugPrint("Found a book with no rating which should not happen");
                continue;
              }

              String countryCode = book.countryCode ?? "";
              if(countryCode.isNotEmpty) {
                countriesReadFrom.add(countryCode);
              }

              if(book.category == BookCategory.fiction) {
                fictionCount++;
              } else if(book.category == BookCategory.nonFiction) {
                nonFictionCount++;
              }

              if(book.authorGender == Gender.male || book.authorGender == Gender.both) {
                maleRead++;
              }
              if(book.authorGender == Gender.female || book.authorGender == Gender.both) {
                femaleRead++;
              }

              if(book.rating != null) {
                int rating = book.rating!;
                ratedCount++;
                totalRating += rating;
              }
            }

            if(ratedCount > 0) {
              averageRating = totalRating / ratedCount;
            }

            countriesReadFrom = countriesReadFrom.toSet().toList();

            List<KPIItem> kpis = [
              KPIItem(label: "Countries Read", intValue: countriesReadFrom.length),
              KPIItem(label: "Books Read", intValue: books.length),
              KPIItem(label: "Average Rating", doubleValue: averageRating)
            ];

            return Column(
              children: [
                KPISection(items: kpis),
              ],
            );
          }),
      ),
    );
  }

}
