import 'package:reading_where/dao/country_state_dao.dart';
import 'package:reading_where/models/country_state.dart';
import 'package:reading_where/models/country.dart';
import 'package:reading_where/persistence/seed_data.dart';

import '../dao/country_dao.dart';

class BookLocationService {

  late CountryDao countryDao;
  late CountryStateDao countryStateDao;

  BookLocationService() {
    countryDao = CountryDao();
    countryStateDao = CountryStateDao();
  }

  Future<List<Country>> getCountryList({bool excludeUnavailable = true}) async {
    return countryDao.getAllCountries(excludeUnavailable: excludeUnavailable);
  }

  Future<List<CountryState>> getCountryStateList() async {
    return countryStateDao.getAllCountryStates();
  }

  Future<Country> updateCountry(Country country) async {
    return countryDao.updateCountry(country);
  }



  Future<List<Country>> _mockGetCountryList() {
    return Future.value(
        SeedData.getCountryData()
    );
  }

  Future<List<CountryState>> _mockGetCountryStates() {
    return Future.value(SeedData.getCountryStateData());
  }



}