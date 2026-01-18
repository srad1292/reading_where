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
  final limit = 10;
  int page = 1;
  int pages = 3;
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
    searched = true;
    collapseForm = true;
    books = _getSampleBookListForUIWork();
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

              Expanded(child: bookListDisplay()),


            ],
          ),
        ),
      ),
    );
  }

  List<Widget> formSectionDisplay() {
    return collapseForm ? _collapsedFormDisplay() : _fullFormDisplay();
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
        this.page = page;
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
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return NavigationTile(
          text: book.title,
          subtitle: Text(book.authorName.join(", ")),
          onTap: () => BookInformationNavigation(book),
        );
      },
    );
  }

  void BookInformationNavigation(Book book) {
    print("Going to go to book info for: ${book.toString()}");
    Navigator.push(context,
      MaterialPageRoute( builder: (_) => BookInformation(book: book), ),
    );
  }
  


  List<Book> _getSampleBookListForUIWork() {
    List<Book> allBooks = [
      Book(title: "The Doors of Perception / Heaven and Hell",publishYear: 1956,coverId: 39648,coverEditionKey: "OL9238585M",authorKey: ["OL19767A"],authorName: ["Aldous Huxley"]),
      Book(title: "The marriage of Heaven and Hell",publishYear: 1793,coverId: 118161,coverEditionKey: "OL1089176M",authorKey: ["OL41961A"],authorName: ["William Blake"]),
      Book(title: "Heaven and Hell",publishYear: 1987,coverId: 4120991,coverEditionKey: "OL2388510M",authorKey: ["OL31209A"],authorName: ["John Jakes"]),
      Book(title: "Heaven and hell",publishYear: 2007,coverId: 13189413,coverEditionKey: "OL37791695M",authorKey: ["OL4983363A"],authorName: ["Don Felder"]),
      Book(title: "Heaven and hell",publishYear: 2020,coverId: 9383131,coverEditionKey: "OL27998067M",authorKey: ["OL7959877A"],authorName: ["Bart D. Ehrman"]),
      Book(title: "Heaven and Hell",publishYear: 1956,coverId: 12628641,coverEditionKey: "OL7281995M",authorKey: ["OL19767A"],authorName: ["Aldous Huxley"]),
      Book(title: "Heaven and Hell",publishYear: 2021,coverId: null,coverEditionKey: "",authorKey: ["OL9175710A"],authorName: ["Emanuel Swedenborg"]),
      Book(title: "Heaven and hell",publishYear: 2002,coverId: 732602,coverEditionKey: "OL8556015M",authorKey: ["OL3017083A","OL409922A"],authorName: ["Susan G. Sizemore","Jody Lynn Nye"]),
      Book(title: "Heaven and Hell",publishYear: 2018,coverId: 11336609,coverEditionKey: "OL32710050M",authorKey: ["OL9175710A"],authorName: ["Emanuel Swedenborg"]),
      Book(title: "Egyptian Heaven and Hell",publishYear: 2014,coverId: null,coverEditionKey: "",authorKey: ["OL116405A"],authorName: ["E. A. Wallis Budge"]),
      Book(title: "Egyptian Heaven and Hell",publishYear: 2014,coverId: null,coverEditionKey: "",authorKey: ["OL116405A"],authorName: ["E. A. Wallis Budge"]),
      Book(title: "Heaven and Hell",publishYear: 2005,coverId: null,coverEditionKey: "",authorKey: ["OL9766745A"],authorName: ["Emma Ray Garrett"]),
      Book(title: "Heaven and hell",publishYear: 1993,coverId: null,coverEditionKey: "",authorKey: ["OL2039062A"],authorName: ["Suzanne Clauser"]),
      Book(title: "Heaven and Hell",publishYear: 2012,coverId: null,coverEditionKey: "",authorKey: ["OL9768075A"],authorName: ["Ken Mink"]),
      Book(title: "The Marriage of Heaven and Hell",publishYear: 2016,coverId: 11255722,coverEditionKey: "OL32620501M",authorKey: ["OL6087028A"],authorName: ["William Blake"]),
      Book(title: "Heaven and Hell",publishYear: 2021,coverId: null,coverEditionKey: "",authorKey: ["OL10092393A"],authorName: ["Naomi Kusahara"]),
      Book(title: "Heaven and Hell",publishYear: 2013,coverId: null,coverEditionKey: "",authorKey: ["OL9175710A"],authorName: ["Emanuel Swedenborg"]),
      Book(title: "Heaven and Hell",publishYear: 2014,coverId: null,coverEditionKey: "",authorKey: ["OL1438274A"],authorName: ["Christopher D. Hudson"]),
      Book(title: "Visions of Heaven and Hell",publishYear: 1977,coverId: null,coverEditionKey: "",authorKey: ["OL580047A"],authorName: ["Richard Cavendish"]),
      Book(title: "Heaven and Hell Eyewitness",publishYear: 2023,coverId: null,coverEditionKey: "",authorKey: ["OL2643113A"],authorName: ["Steven Pike"]),
      Book(title: "Heaven and Hell",publishYear: 2005,coverId: null,coverEditionKey: "",authorKey: ["OL3133475A"],authorName: ["Mistress Nimue"]),
      Book(title: "Heaven and Hell",publishYear: 2011,coverId: null,coverEditionKey: "",authorKey: ["OL6812769A"],authorName: ["John Jakes"]),
      Book(title: "Heaven and Hell",publishYear: 1958,coverId: 9116621,coverEditionKey: "OL27674885M",authorKey: ["OL24981A"],authorName: ["Emanuel Swedenborg"]),
      Book(title: "Heaven and hell",publishYear: 2007,coverId: null,coverEditionKey: "",authorKey: ["OL1481193A"],authorName: ["Brian R. Keller"]),
      Book(title: "Heaven and Hell",publishYear: 2014,coverId: null,coverEditionKey: "",authorKey: ["OL1438274A"],authorName: ["Christopher D. Hudson"]),
      Book(title: "HEAVEN and HELL",publishYear: 2014,coverId: null,coverEditionKey: "",authorKey: ["OL7782863A","OL7782864A"],authorName: ["Gene Keith","Tuelah Keith"]),
      Book(title: "Heaven and Hell",publishYear: 1980,coverId: null,coverEditionKey: "",authorKey: ["OL5805345A"],authorName: ["Barry Carman"]),
      Book(title: "Heaven and Hell Illustrated",publishYear: 2021,coverId: null,coverEditionKey: "",authorKey: ["OL9175710A"],authorName: ["Emanuel Swedenborg"]),
      Book(title: "Egyptian Heaven and Hell",publishYear: 2014,coverId: null,coverEditionKey: "",authorKey: ["OL116405A"],authorName: ["E. A. Wallis Budge"]),
      Book(title: "Heaven and Hell",publishYear: 2018,coverId: null,coverEditionKey: "",authorKey: ["OL8179908A","OL223067A"],authorName: ["Toriko Takarabe","Phyllis Birnbaum"]),
      Book(title: "Heaven and Hell",publishYear: 2002,coverId: 4774208,coverEditionKey: "OL8278853M",authorKey: ["OL2915017A"],authorName: ["Edward A. Donnelly"]),
      Book(title: "Heaven and Hell",publishYear: 2020,coverId: null,coverEditionKey: "",authorKey: ["OL10283236A"],authorName: ["Allan Kardec"]),
      Book(title: "Heaven and hell",publishYear: 2011,coverId: 13026958,coverEditionKey: "OL42874097M",authorKey: ["OL3021623A"],authorName: ["Kailin Gow"]),
      Book(title: "Heaven and Hell",publishYear: 2023,coverId: null,coverEditionKey: "",authorKey: ["OL10184696A"],authorName: ["Kim Mullican"]),
      Book(title: "Heaven and Hell",publishYear: 2013,coverId: null,coverEditionKey: "",authorKey: ["OL3838144A"],authorName: ["Carl Douglass"]),
      Book(title: "Heaven and Hell",publishYear: 2010,coverId: null,coverEditionKey: "",authorKey: ["OL2973178A"],authorName: ["Jim Daddio"]),
      Book(title: "Heaven and Hell",publishYear: 2016,coverId: null,coverEditionKey: "",authorKey: ["OL10283236A","OL10012412A"],authorName: ["Allan Kardec","United States Spiritist Council"]),
      Book(title: "Heaven and Hell",publishYear: 1987,coverId: null,coverEditionKey: "",authorKey: ["OL6812769A"],authorName: ["John Jakes"]),
      Book(title: "Medieval visions of heaven and hell",publishYear: 1993,coverId: 1562359,coverEditionKey: "OL1740122M",authorKey: ["OL840031A"],authorName: ["Eileen Gardiner"]),
      Book(title: "Between Heaven and Hell",publishYear: 2020,coverId: null,coverEditionKey: "",authorKey: ["OL11783202A"],authorName: ["Brandon M. Davis"]),
      Book(title: "Harlem between heaven and hell",publishYear: 2002,coverId: 1551151,coverEditionKey: "OL3553980M",authorKey: ["OL1476538A"],authorName: ["Monique M. Taylor"]),
      Book(title: "Egyptian Heaven and Hell",publishYear: 2014,coverId: null,coverEditionKey: "",authorKey: ["OL116405A"],authorName: ["E. A. Wallis Budge"]),
      Book(title: "Egyptian Heaven and Hell",publishYear: 2014,coverId: null,coverEditionKey: "",authorKey: ["OL116405A"],authorName: ["E. A. Wallis Budge"]),
      Book(title: "The Egyptian heaven and hell",publishYear: 1905,coverId: 4618627,coverEditionKey: "OL22456820M",authorKey: ["OL116405A"],authorName: ["E. A. Wallis Budge"]),
      Book(title: "Heaven and hell",publishYear: 1990,coverId: 12595981,coverEditionKey: "OL2227706M",authorKey: ["OL1013659A"],authorName: ["Arthur Altman"]),
      Book(title: "Heaven and hell",publishYear: 1974,coverId: 7153452,coverEditionKey: "OL5048035M",authorKey: ["OL1959503A"],authorName: ["Joan D. Berbrich"]),
      Book(title: "Heaven and hell",publishYear: 1990,coverId: 13049818,coverEditionKey: "OL1891337M",authorKey: ["OL69979A"],authorName: ["Jill Briscoe spiritual arts"]),
      Book(title: "Heaven and Hell",publishYear: 2000,coverId: 8224750,coverEditionKey: "OL11955467M",authorKey: ["OL3154753A"],authorName: ["Alex Buchanan"]),
      Book(title: "Heaven And Hell",publishYear: 2006,coverId: 2854329,coverEditionKey: "OL11893146M",authorKey: ["OL79719A"],authorName: ["Henry Ward Beecher"]),
      Book(title: "Heaven and hell",publishYear: 1980,coverId: null,coverEditionKey: "",authorKey: ["OL4507533A"],authorName: ["British Broadcasting Corporation. Radiovision."]),
      Book(title: "Heaven and Hell",publishYear: 2019,coverId: null,coverEditionKey: "",authorKey: ["OL9559190A"],authorName: ["Dragon"]),
      Book(title: "Heaven and Hell",publishYear: 2018,coverId: null,coverEditionKey: "",authorKey: ["OL10283236A"],authorName: ["Allan Kardec"]),
      Book(title: "Heaven and Hell",publishYear: 2012,coverId: null,coverEditionKey: "",authorKey: ["OL6812769A"],authorName: ["John Jakes"]),
      Book(title: "Heaven and Hell",publishYear: 2018,coverId: null,coverEditionKey: "",authorKey: ["OL68333A"],authorName: ["John Milton"]),
      Book(title: "Heaven and Hell",publishYear: 2011,coverId: null,coverEditionKey: "",authorKey: ["OL68333A","OL29303A"],authorName: ["John Milton","Dante Alighieri"]),
      Book(title: "Heaven and Hell",publishYear: 2004,coverId: 14474191,coverEditionKey: "OL9499536M",authorKey: ["OL10283236A"],authorName: ["Allan Kardec"]),
      Book(title: "Heaven and Hell",publishYear: 2020,coverId: null,coverEditionKey: "",authorKey: ["OL11364669A"],authorName: ["Sunil Sachwani"]),
      Book(title: "Heaven and Hell",publishYear: 2022,coverId: null,coverEditionKey: "",authorKey: ["OL442470A"],authorName: ["David Webber"]),
      Book(title: "Heaven and Hell",publishYear: 2013,coverId: null,coverEditionKey: "",authorKey: ["OL13688802A"],authorName: ["Edward Gene Butterfield"]),
      Book(title: "Heaven and Hell",publishYear: 2018,coverId: null,coverEditionKey: "",authorKey: ["OL13725549A"],authorName: ["Joao Ponces de"]),
      Book(title: "Heaven and Hell",publishYear: 2018,coverId: null,coverEditionKey: "",authorKey: ["OL14316479A","OL7395729A"],authorName: ["Hilarion Henares","Tatay Jobo Elizes"]),
      Book(title: "Heaven and Hell",publishYear: 2011,coverId: null,coverEditionKey: "",authorKey: ["OL13613026A"],authorName: ["Kristen Ashley"]),
      Book(title: "Heaven and Hell",publishYear: 2018,coverId: null,coverEditionKey: "",authorKey: ["OL8273248A"],authorName: ["Michael C. Doyle"]),
      Book(title: "Heaven and Hell",publishYear: 2012,coverId: null,coverEditionKey: "",authorKey: ["OL3055176A"],authorName: ["Karl Renz"]),
      Book(title: "Heaven and Hell",publishYear: 2025,coverId: null,coverEditionKey: "",authorKey: ["OL15002508A","OL9350908A"],authorName: ["Jón Kalman Stefánsson","Philip Roughton"]),
      Book(title: "Heaven and hell",publishYear: 1878,coverId: 6067124,coverEditionKey: "OL23421713M",authorKey: ["OL6651029A"],authorName: ["Woodward, C. A. Mrs"]),
      Book(title: "Heaven and Hell",publishYear: 2015,coverId: null,coverEditionKey: "",authorKey: ["OL7711422A"],authorName: ["Suzanne D Williams"]),
      Book(title: "Heaven and Hell",publishYear: 2025,coverId: null,coverEditionKey: "",authorKey: ["OL7772912A"],authorName: ["Gawain Barker"]),
      Book(title: "Heaven and Hell",publishYear: 1999,coverId: null,coverEditionKey: "",authorKey: ["OL31209A"],authorName: ["John Jakes"]),
      Book(title: "Heavens And Hells",publishYear: 2005,coverId: 1832066,coverEditionKey: "OL8506513M",authorKey: ["OL541561A"],authorName: ["G. de Purucker"]),
      Book(title: "Heaven and hell",publishYear: 1927,coverId: null,coverEditionKey: "",authorKey: ["OL5569748A"],authorName: ["E. M. Bateman"]),
      Book(title: "Heaven and Hell.",publishYear: 1970,coverId: null,coverEditionKey: "",authorKey: [],authorName: []),
      Book(title: "Marriage of Heaven and Hell",publishYear: 1885,coverId: null,coverEditionKey: "",authorKey: ["OL6087028A"],authorName: ["William Blake"]),
      Book(title: "Heaven and Hell",publishYear: 2020,coverId: null,coverEditionKey: "",authorKey: ["OL202384A"],authorName: ["Robert Smith"]),
      Book(title: "Heaven and hell",publishYear: 2004,coverId: 12652105,coverEditionKey: "OL37736644M",authorKey: ["OL10334770A"],authorName: ["Norbert C. Becker"]),
      Book(title: "Heaven and Hell",publishYear: 1986,coverId: null,coverEditionKey: "",authorKey: ["OL10383756A"],authorName: ["Spellmount Ltd. Publishers Staff"]),
      Book(title: "Heaven and Hell",publishYear: 2013,coverId: null,coverEditionKey: "",authorKey: ["OL14281847A"],authorName: ["Robert Sendrey"]),
      Book(title: "Heaven and Hell",publishYear: 2021,coverId: null,coverEditionKey: "",authorKey: ["OL8885770A","OL9616552A","OL12972329A"],authorName: ["Johanna Leigh","Claudia Rodriguez","Brett MacEachern"]),
      Book(title: "Heaven and Hell",publishYear: 2012,coverId: null,coverEditionKey: "",authorKey: ["OL233228A"],authorName: ["Wayne A. Grudem"]),
      Book(title: "Marriage of Heaven and Hell",publishYear: 2014,coverId: null,coverEditionKey: "",authorKey: ["OL6087028A"],authorName: ["William Blake"]),
      Book(title: "Voices from heaven and hell",publishYear: 1955,coverId: 7223611,coverEditionKey: "OL6179640M",authorKey: ["OL1814534A"],authorName: ["Jacob Marcellus Kik"]),
      Book(title: "Visions of heaven and hell",publishYear: 1902,coverId: null,coverEditionKey: "",authorKey: ["OL942284A"],authorName: ["Amos H. Gottschall"]),
      Book(title: "Heaven and Hell on Earth",publishYear: 2015,coverId: null,coverEditionKey: "",authorKey: ["OL9351772A"],authorName: ["Cherita Ford"]),
      Book(title: "Trapped between heaven and hell",publishYear: 2018,coverId: 13990522,coverEditionKey: "OL26944926M",authorKey: ["OL7531123A"],authorName: ["M. Skye"]),
      Book(title: "Heaven and hell",publishYear: 1956,coverId: null,coverEditionKey: "",authorKey: ["OL4738491A"],authorName: ["John Sutherland Bonnell"]),
      Book(title: "Heaven and Hell",publishYear: 1968,coverId: null,coverEditionKey: "",authorKey: ["OL225709A"],authorName: ["Stephen S. Smalley"]),
      Book(title: "Classic sermons on Heaven and Hell",publishYear: 1994,coverId: 1569193,coverEditionKey: "OL1080273M",authorKey: ["OL21140A"],authorName: ["Warren W. Wiersbe"]),
      Book(title: "Heaven and Hell in Western art",publishYear: 1968,coverId: 14977128,coverEditionKey: "OL14986905M",authorKey: ["OL443121A"],authorName: ["Robert Hughes"]),
      Book(title: "Zen Heaven and Hell",publishYear: 2024,coverId: null,coverEditionKey: "",authorKey: ["OL7382927A"],authorName: ["Tai Sheridan"]),
      Book(title: "Heaven and Hell",publishYear: 2008,coverId: null,coverEditionKey: "",authorKey: ["OL2973883A"],authorName: ["Felder"]),
      Book(title: "Heaven and hell",publishYear: 1986,coverId: null,coverEditionKey: "",authorKey: ["OL457674A"],authorName: ["Peter Toon"]),
      Book(title: "Heaven and Hell",publishYear: 2011,coverId: null,coverEditionKey: "",authorKey: ["OL14271162A"],authorName: ["Jerome Goodwin"]),
      Book(title: "The Marriage of Heaven and Hell",publishYear: 1981,coverId: 2327804,coverEditionKey: "OL10127584M",authorKey: ["OL41961A"],authorName: ["William Blake"]),
      Book(title: "Egyptian Heaven and Hell",publishYear: 2014,coverId: null,coverEditionKey: "",authorKey: ["OL116405A"],authorName: ["E. A. Wallis Budge"]),
      Book(title: "Amid Heaven and Hell",publishYear: 2019,coverId: null,coverEditionKey: "",authorKey: ["OL7730341A"],authorName: ["Oliver Frances"]),
      Book(title: "The Babylonian Conception of Heaven and Hell",publishYear: 2009,coverId: 11224886,coverEditionKey: "OL32584475M",authorKey: ["OL6032798A"],authorName: ["Alfred Jeremias"]),
      Book(title: "Heaven and Hell Illustrated Edition",publishYear: 2021,coverId: null,coverEditionKey: "",authorKey: ["OL9175710A"],authorName: ["Emanuel Swedenborg"]),
      Book(title: "Heaven and Hell in Buddhist Perspective",publishYear: 1973,coverId: 14671672,coverEditionKey: "OL13180433M",authorKey: ["OL3194446A"],authorName: ["Bimala Charan Law"]),
      Book(title: "Heaven and Hell in Western art",publishYear: 1968,coverId: null,coverEditionKey: "",authorKey: ["OL443121A"],authorName: ["Robert Hughes"]),
      Book(title: "Heaven and hell in western art",publishYear: 1968,coverId: null,coverEditionKey: "",authorKey: ["OL443121A"],authorName: ["Robert Hughes"])
    ];
    int start = (page-1) * limit;
    if(start >= allBooks.length-1) {
      start = 0;
    }
    int end = start+limit >= allBooks.length ? allBooks.length-1 : start+limit;

    return allBooks.sublist(start, end);
  }

}
