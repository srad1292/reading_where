import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:reading_where/models/analytics/kpi_location.dart';

import '../components/analytics/kpi_section.dart';
import '../components/analytics/progress_display.dart';
import '../enums/book_list_type.dart';
import '../models/analytics/kpi_item.dart';
import '../models/book.dart';
import '../models/country_state.dart';
import '../service_locator.dart';
import '../services/book_location_service.dart';
import '../services/book_service.dart';

class StateAnalytics extends StatefulWidget {
  final String countryCode;
  const StateAnalytics({super.key, required this.countryCode});

  @override
  State<StateAnalytics> createState() => _StateAnalyticsState();
}

class _StateAnalyticsState extends State<StateAnalytics> {

  final BookLocationService _bookLocationService = serviceLocator.get<BookLocationService>();
  final BookService _bookService = serviceLocator.get<BookService>();

  late Future<List<CountryState>> _countryStateFuture;
  late Future<List<Book>> _savedBooksFuture;

  @override
  void initState() {
    super.initState();
    _countryStateFuture = _bookLocationService.getCountryStateList();
    _savedBooksFuture = _bookService.getSavedBooks(countryCode: widget.countryCode, excludeCountry: false, excludeUnread: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("United States Analytics"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
            future: Future.wait([
              _countryStateFuture,
              _savedBooksFuture
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              List<CountryState> countryStates = snapshot.data![0] as List<CountryState>;
              List<Book> books = snapshot.data![1] as List<Book>;

              KPILocation stateKPIs = KPILocation(location: "states");
              stateKPIs.placesAvailable = countryStates.map((e) => e.code).toList();

              for(Book book in books) {
                if(book.readDate == null) {
                  debugPrint("Found a book with no rating which should not happen");
                  continue;
                }

                stateKPIs.addBookToLocation(book, BookListType.states);
              }

              const double sectionSpace = 36;
              const double subSectionSpace = 10;

              return Column(
                children: [
                  const SizedBox(height: subSectionSpace),
                  ProgressDisplay(label: "Progress", percentage: stateKPIs.getCompletionPercentage(),),

                  const SizedBox(height: subSectionSpace),
                  KPISection(items: countryLocationSection(stateKPIs)),
                ],
              );

            }),
      ),
    );
  }

  List<KPIItem> countryLocationSection(KPILocation location) {
    return [
      KPIItem(label: "States Read", intValue: location.booksRead == 0 ? null : location.placesReadFrom.length),
      KPIItem(label: "States Pending", intValue: location.placesAvailable.length-location.placesReadFrom.length),
      KPIItem(label: "Books Read", intValue: location.booksRead),
      KPIItem(label: "Average Rating", doubleValue: location.getAverageRating()),
      KPIItem(label: "Men Read", intValue: location.booksRead == 0 ? null : location.menRead),
      KPIItem(label: "Women Read", intValue: location.booksRead == 0 ? null : location.womenRead),
      KPIItem(label: "Fiction", intValue: location.booksRead == 0 ? null : location.fictionRead),
      KPIItem(label: "Nonfiction", intValue: location.booksRead == 0 ? null : location.nonfictionRead),
    ];
  }

}
