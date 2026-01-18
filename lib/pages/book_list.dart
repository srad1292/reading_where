import 'package:flutter/material.dart';
import 'package:reading_where/enums/book_list_type.dart';
import 'package:reading_where/components/book_tile.dart';
import 'package:reading_where/pages/book_information.dart';
import 'package:reading_where/pages/book_list_filter_form.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_getAppBarTitle()),
        centerTitle: true,
          actions: [
            PopupMenuButton(
              onSelected: (value) {
                switch (value) {
                  case 'filter':
                    Navigator.push(context,
                      MaterialPageRoute(builder: (_) => BookListFilterForm()),
                    );
                    break;
                  case 'add':
                    Navigator.push(context,
                      MaterialPageRoute(builder: (_) => BookLookup()),
                    );
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
      body:  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ..._getGroupedCountryWidgets(),
            ],
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    return widget.bookListType == BookListType.country ? "Global" : "United States";
  }

  List<Widget> _getCountryWidgets() {
    return _getCountryList().map((e) => LocationExpansionTile(
        title: e.name,
        assetType: e.flagType,
        assetPath: e.flagType == AssetType.svg ?
          'assets/images/country_flags_svg/${e.code}.svg' :
          'assets/images/country_flags_png/${e.code}.png',
        children: [
          BookTile(title: "Test", isRead: e.name.startsWith("C"))
        ]
    ),).toList();
  }

  List<Widget> _getGroupedCountryWidgets() {
    final allBooks = _getAllBooks();
    final booksByCountry = _groupBooksByCountry(allBooks);
    final countries = _getCountryList();

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



  List<Country> _getCountryList() {
    return [
      Country(code: "af", name: "Afghanistan", region: "Asia"),
      Country(code: "al", name: "Albania", region: "Europe"),
      Country(code: "dz", name: "Algeria", region: "Africa"),
      Country(code: "ad", name: "Andorra", region: "Europe"),
      Country(code: "ao", name: "Angola", region: "Africa"),
      Country(code: "ag", name: "Antigua and Barbuda", region: "North America"),
      Country(code: "ar", name: "Argentina", region: "South America"),
      Country(code: "am", name: "Armenia", region: "Asia"),
      Country(code: "au", name: "Australia", region: "Oceania"),
      Country(code: "at", name: "Austria", region: "Europe"),
      Country(code: "az", name: "Azerbaijan", region: "Asia"),
      Country(code: "bs", name: "Bahamas", region: "North America"),
      Country(code: "bh", name: "Bahrain", region: "Asia"),
      Country(code: "bd", name: "Bangladesh", region: "Asia"),
      Country(code: "bb", name: "Barbados", region: "North America"),
      Country(code: "by", name: "Belarus", region: "Europe", flagType: AssetType.png),
      Country(code: "be", name: "Belgium", region: "Europe"),
      Country(code: "bz", name: "Belize", region: "North America"),
      Country(code: "bj", name: "Benin", region: "Africa"),
      Country(code: "bt", name: "Bhutan", region: "Asia"),
      Country(code: "bo", name: "Bolivia", region: "South America"),
      Country(code: "ba", name: "Bosnia and Herzegovina", region: "Europe"),
      Country(code: "bw", name: "Botswana", region: "Africa"),
      Country(code: "br", name: "Brazil", region: "South America", flagType: AssetType.png),
      Country(code: "bn", name: "Brunei", region: "Asia"),
      Country(code: "bg", name: "Bulgaria", region: "Europe"),
      Country(code: "bf", name: "Burkina Faso", region: "Africa"),
      Country(code: "bi", name: "Burundi", region: "Africa"),
      Country(code: "kh", name: "Cambodia", region: "Asia"),
      Country(code: "cm", name: "Cameroon", region: "Africa"),
      Country(code: "ca", name: "Canada", region: "North America"),
      Country(code: "cv", name: "Cape Verde", region: "Africa"),
      Country(code: "cf", name: "Central African Republic", region: "Africa"),
      Country(code: "td", name: "Chad", region: "Africa"),
      Country(code: "cl", name: "Chile", region: "South America"),
      Country(code: "cn", name: "China", region: "Asia"),
      Country(code: "co", name: "Colombia", region: "South America"),
      Country(code: "km", name: "Comoros", region: "Africa"),
      Country(code: "cr", name: "Costa Rica", region: "North America"),
      Country(code: "hr", name: "Croatia", region: "Europe"),
      Country(code: "cu", name: "Cuba", region: "North America"),
      Country(code: "cy", name: "Cyprus", region: "Europe"),
      Country(code: "cz", name: "Czech Republic", region: "Europe"),
      Country(code: "cd", name: "Democratic Republic of the Congo", region: "Africa"),
      Country(code: "dk", name: "Denmark", region: "Europe"),
      Country(code: "dj", name: "Djibouti", region: "Africa"),
      Country(code: "dm", name: "Dominica", region: "North America"),
      Country(code: "do", name: "Dominican Republic", region: "North America"),
      Country(code: "ec", name: "Ecuador", region: "South America"),
      Country(code: "eg", name: "Egypt", region: "Africa"),
      Country(code: "sv", name: "El Salvador", region: "North America"),
      Country(code: "gb-eng", name: "England", region: "Europe"),
      Country(code: "gq", name: "Equatorial Guinea", region: "Africa"),
      Country(code: "er", name: "Eritrea", region: "Africa"),
      Country(code: "ee", name: "Estonia", region: "Europe"),
      Country(code: "sz", name: "Eswatini", region: "Africa"),
      Country(code: "et", name: "Ethiopia", region: "Africa"),
      Country(code: "fj", name: "Fiji", region: "Oceania"),
      Country(code: "fi", name: "Finland", region: "Europe"),
      Country(code: "fr", name: "France", region: "Europe"),
      Country(code: "ga", name: "Gabon", region: "Africa"),
      Country(code: "gm", name: "Gambia", region: "Africa"),
      Country(code: "ge", name: "Georgia", region: "Europe"),
      Country(code: "de", name: "Germany", region: "Europe"),
      Country(code: "gh", name: "Ghana", region: "Africa"),
      Country(code: "gr", name: "Greece", region: "Europe"),
      Country(code: "gd", name: "Grenada", region: "North America"),
      Country(code: "gt", name: "Guatemala", region: "North America"),
      Country(code: "gn", name: "Guinea", region: "Africa"),
      Country(code: "gw", name: "Guinea-Bissau", region: "Africa"),
      Country(code: "gy", name: "Guyana", region: "South America"),
      Country(code: "ht", name: "Haiti", region: "North America"),
      Country(code: "hn", name: "Honduras", region: "North America"),
      Country(code: "hu", name: "Hungary", region: "Europe"),
      Country(code: "is", name: "Iceland", region: "Europe"),
      Country(code: "in", name: "India", region: "Asia"),
      Country(code: "id", name: "Indonesia", region: "Asia"),
      Country(code: "ir", name: "Iran", region: "Asia"),
      Country(code: "iq", name: "Iraq", region: "Asia"),
      Country(code: "ie", name: "Ireland", region: "Europe"),
      Country(code: "il", name: "Israel", region: "Asia"),
      Country(code: "it", name: "Italy", region: "Europe"),
      Country(code: "ci", name: "Ivory Coast", region: "Africa"),
      Country(code: "jm", name: "Jamaica", region: "North America"),
      Country(code: "jp", name: "Japan", region: "Asia"),
      Country(code: "jo", name: "Jordan", region: "Asia"),
      Country(code: "kz", name: "Kazakhstan", region: "Asia"),
      Country(code: "ke", name: "Kenya", region: "Africa"),
      Country(code: "ki", name: "Kiribati", region: "Oceania"),
      Country(code: "xk", name: "Kosovo", region: "Europe"),
      Country(code: "kw", name: "Kuwait", region: "Asia"),
      Country(code: "kg", name: "Kyrgyzstan", region: "Asia"),
      Country(code: "la", name: "Laos", region: "Asia"),
      Country(code: "lv", name: "Latvia", region: "Europe"),
      Country(code: "lb", name: "Lebanon", region: "Asia"),
      Country(code: "ls", name: "Lesotho", region: "Africa"),
      Country(code: "lr", name: "Liberia", region: "Africa"),
      Country(code: "ly", name: "Libya", region: "Africa"),
      Country(code: "li", name: "Liechtenstein", region: "Europe"),
      Country(code: "lt", name: "Lithuania", region: "Europe"),
      Country(code: "lu", name: "Luxembourg", region: "Europe"),
      Country(code: "mg", name: "Madagascar", region: "Africa"),
      Country(code: "mw", name: "Malawi", region: "Africa"),
      Country(code: "my", name: "Malaysia", region: "Asia"),
      Country(code: "mv", name: "Maldives", region: "Asia"),
      Country(code: "ml", name: "Mali", region: "Africa"),
      Country(code: "mt", name: "Malta", region: "Europe"),
      Country(code: "mh", name: "Marshall Islands", region: "Oceania"),
      Country(code: "mr", name: "Mauritania", region: "Africa"),
      Country(code: "mu", name: "Mauritius", region: "Africa"),
      Country(code: "mx", name: "Mexico", region: "North America"),
      Country(code: "fm", name: "Micronesia", region: "Oceania"),
      Country(code: "md", name: "Moldova", region: "Europe"),
      Country(code: "mc", name: "Monaco", region: "Europe"),
      Country(code: "mn", name: "Mongolia", region: "Asia"),
      Country(code: "me", name: "Montenegro", region: "Europe"),
      Country(code: "ma", name: "Morocco", region: "Africa"),
      Country(code: "mz", name: "Mozambique", region: "Africa"),
      Country(code: "mm", name: "Myanmar (Burma)", region: "Asia"),
      Country(code: "na", name: "Namibia", region: "Africa"),
      Country(code: "nr", name: "Nauru", region: "Oceania"),
      Country(code: "np", name: "Nepal", region: "Asia"),
      Country(code: "nl", name: "Netherlands", region: "Europe"),
      Country(code: "nz", name: "New Zealand", region: "Oceania"),
      Country(code: "ni", name: "Nicaragua", region: "North America"),
      Country(code: "ne", name: "Niger", region: "Africa"),
      Country(code: "ng", name: "Nigeria", region: "Africa"),
      Country(code: "kp", name: "North Korea", region: "Asia"),
      Country(code: "mk", name: "North Macedonia", region: "Europe"),
      Country(code: "gb-nir", name: "Northern Ireland", region: "Europe"),
      Country(code: "no", name: "Norway", region: "Europe"),
      Country(code: "om", name: "Oman", region: "Asia"),
      Country(code: "pk", name: "Pakistan", region: "Asia"),
      Country(code: "pw", name: "Palau", region: "Oceania"),
      Country(code: "ps", name: "Palestine", region: "Asia"),
      Country(code: "pa", name: "Panama", region: "North America"),
      Country(code: "pg", name: "Papua New Guinea", region: "Oceania"),
      Country(code: "py", name: "Paraguay", region: "South America"),
      Country(code: "pe", name: "Peru", region: "South America"),
      Country(code: "ph", name: "Philippines", region: "Asia"),
      Country(code: "pl", name: "Poland", region: "Europe"),
      Country(code: "pt", name: "Portugal", region: "Europe"),
      Country(code: "qa", name: "Qatar", region: "Asia"),
      Country(code: "cg", name: "Republic of the Congo", region: "Africa"),
      Country(code: "ro", name: "Romania", region: "Europe"),
      Country(code: "ru", name: "Russia", region: "Europe"),
      Country(code: "rw", name: "Rwanda", region: "Africa"),
      Country(code: "st", name: "São Tomé and Príncipe", region: "Africa"),
      Country(code: "kn", name: "Saint Kitts and Nevis", region: "North America"),
      Country(code: "lc", name: "Saint Lucia", region: "North America"),
      Country(code: "vc", name: "Saint Vincent and the Grenadines", region: "North America"),
      Country(code: "ws", name: "Samoa", region: "Oceania"),
      Country(code: "sm", name: "San Marino", region: "Europe"),
      Country(code: "sa", name: "Saudi Arabia", region: "Asia"),
      Country(code: "gb-sct", name: "Scotland", region: "Europe", flagType: AssetType.png),
      Country(code: "sn", name: "Senegal", region: "Africa"),
      Country(code: "rs", name: "Serbia", region: "Europe"),
      Country(code: "sc", name: "Seychelles", region: "Africa"),
      Country(code: "sl", name: "Sierra Leone", region: "Africa"),
      Country(code: "sg", name: "Singapore", region: "Asia"),
      Country(code: "sk", name: "Slovakia", region: "Europe"),
      Country(code: "si", name: "Slovenia", region: "Europe"),
      Country(code: "sb", name: "Solomon Islands", region: "Oceania"),
      Country(code: "so", name: "Somalia", region: "Africa"),
      Country(code: "za", name: "South Africa", region: "Africa"),
      Country(code: "kr", name: "South Korea", region: "Asia"),
      Country(code: "ss", name: "South Sudan", region: "Africa"),
      Country(code: "es", name: "Spain", region: "Europe"),
      Country(code: "lk", name: "Sri Lanka", region: "Asia"),
      Country(code: "sd", name: "Sudan", region: "Africa"),
      Country(code: "sr", name: "Suriname", region: "South America"),
      Country(code: "se", name: "Sweden", region: "Europe"),
      Country(code: "ch", name: "Switzerland", region: "Europe"),
      Country(code: "sy", name: "Syria", region: "Asia"),
      Country(code: "tw", name: "Taiwan", region: "Asia"),
      Country(code: "tj", name: "Tajikistan", region: "Asia"),
      Country(code: "tz", name: "Tanzania", region: "Africa"),
      Country(code: "th", name: "Thailand", region: "Asia"),
      Country(code: "tl", name: "Timor-Leste", region: "Asia"),
      Country(code: "tg", name: "Togo", region: "Africa"),
      Country(code: "to", name: "Tonga", region: "Oceania"),
      Country(code: "tt", name: "Trinidad and Tobago", region: "North America"),
      Country(code: "tn", name: "Tunisia", region: "Africa"),
      Country(code: "tr", name: "Turkey", region: "Europe"),
      Country(code: "tm", name: "Turkmenistan", region: "Asia"),
      Country(code: "tv", name: "Tuvalu", region: "Oceania"),
      Country(code: "ug", name: "Uganda", region: "Africa"),
      Country(code: "ua", name: "Ukraine", region: "Europe"),
      Country(code: "ae", name: "United Arab Emirates", region: "Asia"),
      Country(code: "us", name: "United States", region: "North America"),
      Country(code: "uy", name: "Uruguay", region: "South America"),
      Country(code: "uz", name: "Uzbekistan", region: "Asia"),
      Country(code: "vu", name: "Vanuatu", region: "Oceania"),
      Country(code: "va", name: "Vatican City", region: "Europe"),
      Country(code: "ve", name: "Venezuela", region: "South America"),
      Country(code: "vn", name: "Vietnam", region: "Asia"),
      Country(code: "gb-wls", name: "Wales", region: "Europe"),
      Country(code: "ye", name: "Yemen", region: "Asia"),
      Country(code: "zm", name: "Zambia", region: "Africa"),
      Country(code: "zw", name: "Zimbabwe", region: "Africa")
    ];
  }

  List<Book> _getAllBooks() {
    List<Book> allBooks = [
      Book(title: "The Doors of Perception / Heaven and Hell",
          publishYear: 1956,
          coverId: 39648,
          coverEditionKey: "OL9238585M",
          authorKey: ["OL19767A"],
          authorName: ["Aldous Huxley"],
          countryCode: "dz",
          readDate: DateTime(2024, 2, 4)
      ),
      Book(title: "The marriage of Heaven and Hell",
          publishYear: 1793,
          coverId: 118161,
          coverEditionKey: "OL1089176M",
          authorKey: ["OL41961A"],
          authorName: ["William Blake"],
          countryCode: "dz",
          readDate: DateTime(2024, 4, 14)
      ),
      Book(title: "Heaven and Hell",
          publishYear: 1987,
          coverId: 4120991,
          coverEditionKey: "OL2388510M",
          authorKey: ["OL31209A"],
          authorName: ["John Jakes"],
          countryCode: "dz",
      ),
      Book(title: "Heaven and hell",
          publishYear: 2007,
          coverId: 13189413,
          coverEditionKey: "OL37791695M",
          authorKey: ["OL4983363A"],
          authorName: ["Don Felder"],
          countryCode: "ao",
          readDate: DateTime(2024, 4, 14)),
      Book(title: "Heaven and hell",
          publishYear: 2020,
          coverId: 9383131,
          coverEditionKey: "OL27998067M",
          authorKey: ["OL7959877A"],
          authorName: ["Bart D. Ehrman"],
          countryCode: "ao",
      ),
      Book(title: "Heaven and Hell",
          publishYear: 1956,
          coverId: 12628641,
          coverEditionKey: "OL7281995M",
          authorKey: ["OL19767A"],
          authorName: ["Aldous Huxley"],
          countryCode: "ao",
          readDate: DateTime(2012, 4, 14))
    ];
    return allBooks;
  }
}
