import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:reading_where/models/analytics/kpi_location.dart';

import '../components/analytics/kpi_section.dart';
import '../models/analytics/kpi_item.dart';
import '../models/book.dart';
import '../models/country.dart';
import '../service_locator.dart';
import '../services/book_location_service.dart';
import '../services/book_service.dart';
import 'package:collection/collection.dart';

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
        title: const Text("Global Analytics"),
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

            Map<String, KPILocation> regionAnalytics = new Map<String,KPILocation>();
            List<String> regions = countries.map((e) => e.region).toSet().toList()..sort();
            for(String region in regions) {
              regionAnalytics.putIfAbsent(region, () => KPILocation(location: region));
            }

            for(Country country in countries) {
              String region = country.region;
              if(region.isNotEmpty && regionAnalytics.containsKey(region)) {
                regionAnalytics[region]?.placesAvailable.add(country.code);
              }
            }

            KPILocation globalKPIs = KPILocation(location: "global");
            globalKPIs.placesAvailable = countries.map((e) => e.code).toList();

            for(Book book in books) {
              if(book.readDate == null) {
                debugPrint("Found a book with no rating which should not happen");
                continue;
              }

              globalKPIs.addBookToLocation(book);
              String countryCode = book.countryCode ?? "";
              if(countryCode.isNotEmpty) {
                Country? country = countries.firstWhereOrNull((element) => element.code == countryCode);
                String region = country?.region ?? "";
                if(region.isNotEmpty && regionAnalytics.containsKey(region)) {
                  regionAnalytics[region]?.addBookToLocation(book);
                }
              }
            }

            const double sectionSpace = 36;

            return Column(
              children: [
                KPISection(items: countryLocationSection(globalKPIs)),
                const SizedBox(height: sectionSpace),

                ...regions.map((region) => [
                  Text(region, style: TextStyle(fontSize: 24),),
                  const SizedBox(height: 10),
                  KPISection(items: countryLocationSection(regionAnalytics[region]!)),
                  const SizedBox(height: sectionSpace),
                ]).expand((widgetList) => widgetList),
              ],
            );

          }),
      ),
    );
  }

  List<KPIItem> countryLocationSection(KPILocation location) {
    return [
      KPIItem(label: "Countries Read", intValue: location.booksRead == 0 ? null : location.placesReadFrom.length),
      KPIItem(label: "Countries Pending", intValue: location.placesAvailable.length-location.placesReadFrom.length),
      KPIItem(label: "Books Read", intValue: location.booksRead),
      KPIItem(label: "Average Rating", doubleValue: location.getAverageRating()),
      KPIItem(label: "Men Read", intValue: location.booksRead == 0 ? null : location.menRead),
      KPIItem(label: "Women Read", intValue: location.booksRead == 0 ? null : location.womenRead),
      KPIItem(label: "Fiction", intValue: location.booksRead == 0 ? null : location.fictionRead),
      KPIItem(label: "Nonfiction", intValue: location.booksRead == 0 ? null : location.nonfictionRead),
    ];
  }

}
