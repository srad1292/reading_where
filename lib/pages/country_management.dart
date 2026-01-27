import 'package:flutter/material.dart';
import 'package:reading_where/components/error_dialog.dart';
import 'package:reading_where/service_locator.dart';
import 'package:reading_where/services/book_location_service.dart';

import '../models/country.dart';

class CountryManagement extends StatefulWidget {
  const CountryManagement({super.key});

  @override
  State<CountryManagement> createState() => _CountryManagementState();
}

class _CountryManagementState extends State<CountryManagement> {
  final BookLocationService _bookLocationService = serviceLocator.get<BookLocationService>();
  late Future<List<Country>> _countryFuture;

  @override
  void initState() {
    super.initState();
    _countryFuture = _bookLocationService.getCountryList(excludeUnavailable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Country Availability"),
          centerTitle: true,
      ),
      body:  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: _countryFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              List<Country> countries = snapshot.data!;

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: countries.map((country) {
                  return Row(
                    children: [
                      Checkbox(
                          value: country.canBeReadFrom,
                          onChanged: (value) async {
                            bool previousValue = country.canBeReadFrom;
                            try {
                              bool newValue = value ?? false;
                              country.canBeReadFrom = newValue;
                              _bookLocationService.updateCountry(country);
                              setState(() {
                                country.canBeReadFrom = newValue;
                              });
                            } catch(e) {
                              await showErrorDialog(context: context, body: "Failed to update status");
                              setState(() {
                                country.canBeReadFrom = previousValue;
                              });
                            }
                          }
                      ),
                      Text(country.name)
                    ],
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
