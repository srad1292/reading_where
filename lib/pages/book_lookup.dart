import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reading_where/components/navigation_tile.dart';
import 'package:reading_where/models/book.dart';
import 'package:reading_where/models/paginated_book.dart';
import 'package:reading_where/pages/book_information.dart';
import 'package:reading_where/service_locator.dart';
import 'package:reading_where/services/book_service.dart';

import '../models/book_search.dart';


class BookLookup extends StatefulWidget {
  const BookLookup({super.key});

  @override
  State<BookLookup> createState() => _BookLookupState();
}

class _BookLookupState extends State<BookLookup> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bookService = serviceLocator.get<BookService>();
  final titleLimit = 100;
  final limit = 10;
  int page = 1;
  int pages = 0;
  bool searched = false;
  bool searching = false;
  List<Book> books = [];
  bool collapseForm = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _titleController.addListener(_onInputChanged);
    _authorController.addListener(_onInputChanged);
    _subjectController.addListener(_onInputChanged);

    // While setting up UI
    // searched = true;
    // collapseForm = true;
    // books = _getSampleBookListForUIWork();
  }

  void _onInputChanged() {
    setState(() {}); // rebuild so the button updates
  }

  bool get isSearchDisabled {
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final subject = _subjectController.text.trim();

    final allEmpty = title.isEmpty && author.isEmpty && subject.isEmpty;

    return allEmpty || searching;
  }


  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () { FocusScope.of(context).unfocus(); },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Book Search"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...formSectionDisplay(),


              if(isPortrait || collapseForm)
                Expanded(child: bookListDisplay()),

              if(searched)
                paginator(),

            ],
          ),
        ),
      ),
    );
  }

  Widget paginator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: (page == 1 || searching) ? null : () {
            _performSearch(page-1);
          },
          icon: const Icon(Icons.chevron_left)
        ),
        IconButton(
          onPressed: (page >= pages || searching) ? null : () {
            _performSearch(page+1);
          },
          icon: const Icon(Icons.chevron_right))
      ],
    );
  }

  List<Widget> formSectionDisplay() {
    return collapseForm ? _collapsedFormDisplay() : _getFullFormDisplay();
  }

  List<Widget> _collapsedFormDisplay() {
    return [
      Center(
        child: GestureDetector(
          child: const Text(
            "Show Form +",
            style: TextStyle(color: Colors.blue)
          ),
          onTap: () {
            setState(() {
              collapseForm=false;
            });
          },
        )
      ),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _getFullFormDisplay() {
    return MediaQuery.of(context).orientation == Orientation.portrait ? _fullFormDisplayPortrait() : _fullFormDisplayLandscape();
  }

  List<Widget> _fullFormDisplayPortrait() {
    return _fullFormDisplay();
  }

  List<Widget> _fullFormDisplayLandscape() {
    return [
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _fullFormDisplay(),
          ),
        )
      ),
    ];
  }

  List<Widget> _fullFormDisplay() {
    return [
      TextField(
        controller: _titleController,
        decoration: const InputDecoration(
          labelText: "Title",
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),

      TextField(
        controller: _authorController,
        decoration: const InputDecoration(
          labelText: "Author",
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),

      TextField(
        controller: _subjectController,
        decoration: const InputDecoration(
          labelText: "Subject",
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 24),

      ElevatedButton(
        onPressed: isSearchDisabled ? null : () async { await _performSearch(1); },
        child: const Text("Submit Search"),
      ),
    ];
  }

  Future<void> _performSearch(int page) async {
    FocusScope.of(context).unfocus(); // Close keyboard if open
    setState(() => searching = true);

    try {
      debugPrint("Title: ${_titleController.text}");
      debugPrint("Author: ${_authorController.text}");
      debugPrint("Subject: ${_subjectController.text}");
      final results = await _bookService.searchForBooks(
        BookSearch(
          page: page,
          limit: limit,
          title: _titleController.text.trim(),
          author: _authorController.text.trim(),
          subject: _subjectController.text.trim(),
        ),
      );

      if(results.books.isNotEmpty) {
        debugPrint(results.books.first.toString());
      }

      setState(() {
        books = results.books;
        searched = true;
        this.page = results.books.isNotEmpty ? page : 1;
        pages = results.books.isNotEmpty ? (results.total / limit).ceil() : 0;
        collapseForm = results.books.isNotEmpty;
      });


    } finally {
      setState(() => searching = false);
    }
  }

  Widget bookListDisplay() {
    if (!searched) {
      return const SizedBox.shrink();
    }

    if (books.isEmpty) {
      return noDataBookList();
    }

    return populatedBookList();
  }
  
  Widget noDataBookList() {
    return Center(child: Text("No Results"));
  }

  Widget populatedBookList() {
    debugPrint("Book List Page: $page");
    if(books.isNotEmpty) {
      debugPrint("Book List First: ${books.first.toString()}");
    }
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        int titleEnd = min(titleLimit, book.title.length);
        String title = book.title.substring(0, titleEnd);
        if(title.length < book.title.length) {
          title = "$title...";
        }

        String year = book.publishYear == null ? "" : " (${book.publishYear})";

        title = "$title$year";

        String subtitle = book.authorName.join(", ");
        int subtitleEnd = min(titleLimit, subtitle.length);
        String trimmedSubtitle = subtitle.substring(0, subtitleEnd);
        if(trimmedSubtitle.length < subtitle.length) {
          trimmedSubtitle = "$trimmedSubtitle...";
        }

        return NavigationTile(
          text: title,
          largeTitle: false,
          subtitle: Text(
            trimmedSubtitle,
            style: Theme.of(context).textTheme.titleSmall
          ),
          onTap: () => bookInformationNavigation(book),
        );
      },
    );
  }

  void bookInformationNavigation(Book book) async {
    bool? savedBook = await Navigator.push(context,
      MaterialPageRoute( builder: (_) => BookInformation(book: book) ),
    );

    if(savedBook == true) {
      if(!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    }
  }


  Future<void> _mockPerformSearch(int page) async {
    FocusScope.of(context).unfocus(); // Close keyboard if open
    setState(() => searching = true);
    this.page = page;

    try {
      List<Book> pageOfBooks = _getSampleBookListForUIWork();
      if(pageOfBooks.isNotEmpty) {
        debugPrint(books.first.toString());
      }

      setState(() {
        books = pageOfBooks;
        searched = true;
        this.page = page;
        collapseForm = pageOfBooks.isNotEmpty;
      });
    } finally {
      setState(() => searching = false);
    }
  }


  List<Book> _getSampleBookListForUIWork() {
    List<Book> allBooks = [
      Book(title: "The Doors of Perception / Heaven and Hell", providerKey: "/works/OL64442W", publishYear: 1956,coverId: 39648,coverEditionKey: "OL9238585M",authorKey: ["OL19767A"],authorName: ["Aldous Huxley"]),
      Book(title: "The marriage of Heaven and Hell", providerKey: "/works/OL575441W", publishYear: 1793,coverId: 118161,coverEditionKey: "OL1089176M",authorKey: ["OL41961A"],authorName: ["William Blake"]),
      Book(title: "Heaven and Hell", providerKey: "/works/OL27183905W", publishYear: 1987,coverId: 4120991,coverEditionKey: "OL2388510M",authorKey: ["OL31209A"],authorName: ["John Jakes"]),
      Book(title: "Heaven and hell",providerKey: "/works/OL27183905W", publishYear: 2007,coverId: 13189413,coverEditionKey: "OL37791695M",authorKey: ["OL4983363A"],authorName: ["Don Felder"]),
      Book(title: "Heaven and hell",providerKey: "/works/OL27183905W", publishYear: 2020,coverId: 9383131,coverEditionKey: "OL27998067M",authorKey: ["OL7959877A"],authorName: ["Bart D. Ehrman"]),
      Book(title: "Heaven and Hell",providerKey: "/works/OL27183905W", publishYear: 1956,coverId: 12628641,coverEditionKey: "OL7281995M",authorKey: ["OL19767A"],authorName: ["Aldous Huxley"]),
      Book(title: "The Doors of Perception / Heaven and Hell", providerKey: "/works/OL64442W", publishYear: 1956,coverId: 39648,coverEditionKey: "OL9238585M",authorKey: ["OL19767A"],authorName: ["Aldous Huxley"]),
      Book(title: "Heaven and Hell",providerKey: "/works/OL27183905W", publishYear: 2021,coverId: null,coverEditionKey: "",authorKey: ["OL9175710A"],authorName: ["Emanuel Swedenborg"]),
      Book(title: "Heaven and Hell",providerKey: "/works/OL27183905W", publishYear: 2018,coverId: 11336609,coverEditionKey: "OL32710050M",authorKey: ["OL9175710A"],authorName: ["Emanuel Swedenborg"]),
      Book(title: "Heaven and Hell", providerKey: "/works/OL27183905W", publishYear: 1987,coverId: 4120991,coverEditionKey: "OL2388510M",authorKey: ["OL31209A"],authorName: ["John Jakes"]),
      Book(title: "Heaven and Hell", providerKey: "/works/OL27183905W", publishYear: 1987,coverId: 4120991,coverEditionKey: "OL2388510M",authorKey: ["OL31209A"],authorName: ["John Jakes"]),
      Book(title: "Heaven and hell",providerKey: "/works/OL27183905W", publishYear: 2007,coverId: 13189413,coverEditionKey: "OL37791695M",authorKey: ["OL4983363A"],authorName: ["Don Felder"]),
      Book(title: "Heaven and Hell",providerKey: "/works/OL27183905W", publishYear: 2021,coverId: null,coverEditionKey: "",authorKey: ["OL9175710A"],authorName: ["Emanuel Swedenborg"]),
      Book(title: "Heaven and hell",providerKey: "/works/OL27183905W", publishYear: 2002,coverId: 732602,coverEditionKey: "OL8556015M",authorKey: ["OL3017083A","OL409922A"],authorName: ["Susan G. Sizemore","Jody Lynn Nye"]),
      Book(title: "Heaven and hell",providerKey: "/works/OL27183905W", publishYear: 2020,coverId: 9383131,coverEditionKey: "OL27998067M",authorKey: ["OL7959877A"],authorName: ["Bart D. Ehrman"]),
      Book(title: "The marriage of Heaven and Hell", providerKey: "/works/OL575441W", publishYear: 1793,coverId: 118161,coverEditionKey: "OL1089176M",authorKey: ["OL41961A"],authorName: ["William Blake"]),
      Book(title: "Heaven and Hell",providerKey: "/works/OL27183905W", publishYear: 1956,coverId: 12628641,coverEditionKey: "OL7281995M",authorKey: ["OL19767A"],authorName: ["Aldous Huxley"]),
      Book(title: "Heaven and hell",providerKey: "/works/OL27183905W", publishYear: 2002,coverId: 732602,coverEditionKey: "OL8556015M",authorKey: ["OL3017083A","OL409922A"],authorName: ["Susan G. Sizemore","Jody Lynn Nye"]),
      Book(title: "The marriage of Heaven and Hell", providerKey: "/works/OL575441W", publishYear: 1793,coverId: 118161,coverEditionKey: "OL1089176M",authorKey: ["OL41961A"],authorName: ["William Blake"]),
      Book(title: "Heaven and Hell",providerKey: "/works/OL27183905W", publishYear: 2018,coverId: 11336609,coverEditionKey: "OL32710050M",authorKey: ["OL9175710A"],authorName: ["Emanuel Swedenborg"]),
      Book(title: "The Doors of Perception / Heaven and Hell", providerKey: "/works/OL64442W", publishYear: 1956,coverId: 39648,coverEditionKey: "OL9238585M",authorKey: ["OL19767A"],authorName: ["Aldous Huxley"]),
      Book(title: "Heaven and hell",providerKey: "/works/OL27183905W", publishYear: 2007,coverId: 13189413,coverEditionKey: "OL37791695M",authorKey: ["OL4983363A"],authorName: ["Don Felder"]),
      Book(title: "Heaven and hell",providerKey: "/works/OL27183905W", publishYear: 2020,coverId: 9383131,coverEditionKey: "OL27998067M",authorKey: ["OL7959877A"],authorName: ["Bart D. Ehrman"]),
      Book(title: "Heaven and Hell",providerKey: "/works/OL27183905W", publishYear: 1956,coverId: 12628641,coverEditionKey: "OL7281995M",authorKey: ["OL19767A"],authorName: ["Aldous Huxley"]),
      Book(title: "Heaven and Hell",providerKey: "/works/OL27183905W", publishYear: 2021,coverId: null,coverEditionKey: "",authorKey: ["OL9175710A"],authorName: ["Emanuel Swedenborg"]),
      Book(title: "Heaven and hell",providerKey: "/works/OL27183905W", publishYear: 2002,coverId: 732602,coverEditionKey: "OL8556015M",authorKey: ["OL3017083A","OL409922A"],authorName: ["Susan G. Sizemore","Jody Lynn Nye"]),
      Book(title: "Heaven and Hell",providerKey: "/works/OL27183905W", publishYear: 2018,coverId: 11336609,coverEditionKey: "OL32710050M",authorKey: ["OL9175710A"],authorName: ["Emanuel Swedenborg"]),
      Book(title: "The Doors of Perception / Heaven and Hell", providerKey: "/works/OL64442W", publishYear: 1956,coverId: 39648,coverEditionKey: "OL9238585M",authorKey: ["OL19767A"],authorName: ["Aldous Huxley"]),
      Book(title: "The marriage of Heaven and Hell", providerKey: "/works/OL575441W", publishYear: 1793,coverId: 118161,coverEditionKey: "OL1089176M",authorKey: ["OL41961A"],authorName: ["William Blake"]),
      Book(title: "Heaven and Hell", providerKey: "/works/OL27183905W", publishYear: 1987,coverId: 4120991,coverEditionKey: "OL2388510M",authorKey: ["OL31209A"],authorName: ["John Jakes"]),
      Book(title: "Heaven and hell",providerKey: "/works/OL27183905W", publishYear: 2007,coverId: 13189413,coverEditionKey: "OL37791695M",authorKey: ["OL4983363A"],authorName: ["Don Felder"]),
      Book(title: "Heaven and hell",providerKey: "/works/OL27183905W", publishYear: 2020,coverId: 9383131,coverEditionKey: "OL27998067M",authorKey: ["OL7959877A"],authorName: ["Bart D. Ehrman"]),
      Book(title: "Heaven and Hell",providerKey: "/works/OL27183905W", publishYear: 1956,coverId: 12628641,coverEditionKey: "OL7281995M",authorKey: ["OL19767A"],authorName: ["Aldous Huxley"]),
      Book(title: "Heaven and Hell",providerKey: "/works/OL27183905W", publishYear: 2021,coverId: null,coverEditionKey: "",authorKey: ["OL9175710A"],authorName: ["Emanuel Swedenborg"]),
      Book(title: "Heaven and hell",providerKey: "/works/OL27183905W", publishYear: 2002,coverId: 732602,coverEditionKey: "OL8556015M",authorKey: ["OL3017083A","OL409922A"],authorName: ["Susan G. Sizemore","Jody Lynn Nye"]),
      Book(title: "Heaven and Hell",providerKey: "/works/OL27183905W", publishYear: 2018,coverId: 11336609,coverEditionKey: "OL32710050M",authorKey: ["OL9175710A"],authorName: ["Emanuel Swedenborg"]),
      Book(title: "The Doors of Perception / Heaven and Hell", providerKey: "/works/OL64442W", publishYear: 1956,coverId: 39648,coverEditionKey: "OL9238585M",authorKey: ["OL19767A"],authorName: ["Aldous Huxley"]),
      Book(title: "The marriage of Heaven and Hell", providerKey: "/works/OL575441W", publishYear: 1793,coverId: 118161,coverEditionKey: "OL1089176M",authorKey: ["OL41961A"],authorName: ["William Blake"]),
      Book(title: "Heaven and Hell", providerKey: "/works/OL27183905W", publishYear: 1987,coverId: 4120991,coverEditionKey: "OL2388510M",authorKey: ["OL31209A"],authorName: ["John Jakes"]),
      Book(title: "Heaven and hell",providerKey: "/works/OL27183905W", publishYear: 2007,coverId: 13189413,coverEditionKey: "OL37791695M",authorKey: ["OL4983363A"],authorName: ["Don Felder"]),
      Book(title: "Heaven and hell",providerKey: "/works/OL27183905W", publishYear: 2020,coverId: 9383131,coverEditionKey: "OL27998067M",authorKey: ["OL7959877A"],authorName: ["Bart D. Ehrman"]),
      Book(title: "Heaven and Hell",providerKey: "/works/OL27183905W", publishYear: 1956,coverId: 12628641,coverEditionKey: "OL7281995M",authorKey: ["OL19767A"],authorName: ["Aldous Huxley"]),
      Book(title: "Heaven and Hell",providerKey: "/works/OL27183905W", publishYear: 2021,coverId: null,coverEditionKey: "",authorKey: ["OL9175710A"],authorName: ["Emanuel Swedenborg"]),
      Book(title: "Heaven and hell",providerKey: "/works/OL27183905W", publishYear: 2002,coverId: 732602,coverEditionKey: "OL8556015M",authorKey: ["OL3017083A","OL409922A"],authorName: ["Susan G. Sizemore","Jody Lynn Nye"]),
      Book(title: "Heaven and Hell",providerKey: "/works/OL27183905W", publishYear: 2018,coverId: 11336609,coverEditionKey: "OL32710050M",authorKey: ["OL9175710A"],authorName: ["Emanuel Swedenborg"]),
      Book(title: "The Doors of Perception / Heaven and Hell", providerKey: "/works/OL64442W", publishYear: 1956,coverId: 39648,coverEditionKey: "OL9238585M",authorKey: ["OL19767A"],authorName: ["Aldous Huxley"]),
      Book(title: "The marriage of Heaven and Hell", providerKey: "/works/OL575441W", publishYear: 1793,coverId: 118161,coverEditionKey: "OL1089176M",authorKey: ["OL41961A"],authorName: ["William Blake"]),
      Book(title: "Heaven and Hell", providerKey: "/works/OL27183905W", publishYear: 1987,coverId: 4120991,coverEditionKey: "OL2388510M",authorKey: ["OL31209A"],authorName: ["John Jakes"]),
      Book(title: "Heaven and hell",providerKey: "/works/OL27183905W", publishYear: 2007,coverId: 13189413,coverEditionKey: "OL37791695M",authorKey: ["OL4983363A"],authorName: ["Don Felder"]),
      Book(title: "Heaven and hell",providerKey: "/works/OL27183905W", publishYear: 2020,coverId: 9383131,coverEditionKey: "OL27998067M",authorKey: ["OL7959877A"],authorName: ["Bart D. Ehrman"]),
      Book(title: "Heaven and Hell",providerKey: "/works/OL27183905W", publishYear: 1956,coverId: 12628641,coverEditionKey: "OL7281995M",authorKey: ["OL19767A"],authorName: ["Aldous Huxley"]),
      Book(title: "Heaven and Hell",providerKey: "/works/OL27183905W", publishYear: 2021,coverId: null,coverEditionKey: "",authorKey: ["OL9175710A"],authorName: ["Emanuel Swedenborg"]),
      Book(title: "Heaven and hell",providerKey: "/works/OL27183905W", publishYear: 2002,coverId: 732602,coverEditionKey: "OL8556015M",authorKey: ["OL3017083A","OL409922A"],authorName: ["Susan G. Sizemore","Jody Lynn Nye"]),
      Book(title: "Heaven and Hell",providerKey: "/works/OL27183905W", publishYear: 2018,coverId: 11336609,coverEditionKey: "OL32710050M",authorKey: ["OL9175710A"],authorName: ["Emanuel Swedenborg"]),
    ];
    pages = (allBooks.length / limit).ceil();

    int start = (page-1) * limit;
    if(start >= allBooks.length-1) {
      start = 0;
    }
    int end = start+limit >= allBooks.length ? allBooks.length-1 : start+limit;
    debugPrint("Start: $start -- End: $end");
    return allBooks.sublist(start, end);
  }

}
