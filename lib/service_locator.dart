import 'package:get_it/get_it.dart';
import 'package:reading_where/services/book_location_service.dart';
import 'package:reading_where/services/book_service.dart';
import 'package:reading_where/services/open_library_service.dart';

GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  serviceLocator.registerLazySingleton(() => OpenLibraryService());
  serviceLocator.registerLazySingleton(() => BookService());
  serviceLocator.registerLazySingleton(() => BookLocationService());
}