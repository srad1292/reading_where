import 'package:flutter/material.dart';
import 'package:reading_where/enums/book_list_type.dart';
import 'package:reading_where/enums/asset_type.dart';
import 'package:reading_where/pages/book_list.dart';
import 'package:reading_where/components/location_expansion_tile.dart';
import 'package:reading_where/components/navigation_tile.dart';


class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Reading Where?"),
        centerTitle: true,
      ),
      body:  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LocationExpansionTile(
                  title: "Global",
                  assetPath: 'assets/images/globe.png',
                  assetType: AssetType.png,
                  children: [
                    NavigationTile(text: "Country List", onTap: () => BookListNavigation(context, BookListType.country),),
                    NavigationTile(text: "Analytics", onTap: () => AnalyticsNavigation(),),
                  ]
              ),
              LocationExpansionTile(
                  title: "United States",
                  assetPath: 'assets/images/country_flags_svg/us.svg',
                  children: [
                    NavigationTile(text: "State List", onTap: () => BookListNavigation(context, BookListType.states),),
                    NavigationTile(text: "Analytics", onTap: () => AnalyticsNavigation(),),
                  ]
              ),
            ],
          ),
        ),
      ),
    );
  }

  void AnalyticsNavigation() {
    print("Analytics Navigation TODO");
  }

  void BookListNavigation(BuildContext context, BookListType bookListType) {
    print("Going to go to book list with type: $bookListType");
    Navigator.push(context,
      MaterialPageRoute( builder: (_) => BookList(bookListType: bookListType), ),
    );
  }
}
