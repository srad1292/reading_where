import 'package:flutter/cupertino.dart';
import 'package:reading_where/enums/book_list_type.dart';

import '../../enums/book_category.dart';
import '../../enums/gender.dart';
import '../book.dart';

class KPILocation {

  String location;
  late List<String> placesReadFrom;
  late List<String> placesAvailable;
  int booksRead;
  int booksRated;
  int totalRating;
  int menRead;
  int womenRead;
  int fictionRead;
  int nonfictionRead;

  KPILocation({ required this.location, this.booksRead = 0, this.booksRated = 0,
    this.totalRating = 0, this.menRead = 0, this.womenRead = 0,
    this.fictionRead = 0, this.nonfictionRead = 0,
  }) {
    placesReadFrom = [];
    placesAvailable = [];
  }

  double? getAverageRating() {
    if(booksRated > 0) {
      return totalRating / booksRated;
    }

    return null;
  }

  double getCompletionPercentage() {
    int numberAvailable = placesAvailable.length;
    int numberRead = placesReadFrom.length;
    if(numberAvailable > 0) {
      return numberRead / numberAvailable;
    }

    return 0.0;
  }

  void setListsToDistinct() {
    placesReadFrom = placesReadFrom.toSet().toList();
    placesAvailable = placesAvailable.toSet().toList();
  }

  void addBookToLocation(Book book, BookListType locationType) {
    if(book.readDate == null) {
      debugPrint("Found a book with no rating which should not happen");
      return;
    }

    booksRead++;

    if(locationType == BookListType.country) {
      String countryCode = book.countryCode ?? "";
      if(countryCode.isNotEmpty) {
        placesReadFrom.add(countryCode);
        setListsToDistinct();
      }
    } else if(locationType == BookListType.states) {
      String stateCode = book.stateCode ?? "";
      if(stateCode.isNotEmpty) {
        placesReadFrom.add(stateCode);
        setListsToDistinct();
      }
    }


    if(book.category == BookCategory.fiction) {
      fictionRead++;
    } else if(book.category == BookCategory.nonFiction) {
      nonfictionRead++;
    }

    if(book.authorGender == Gender.male || book.authorGender == Gender.both) {
      menRead++;
    }
    if(book.authorGender == Gender.female || book.authorGender == Gender.both) {
      womenRead++;
    }

    if(book.rating != null) {
      int rating = book.rating!;
      booksRated++;
      totalRating += rating;
    }
  }


}