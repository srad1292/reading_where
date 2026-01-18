import 'package:flutter/material.dart';
import 'package:reading_where/enums/book_list_type.dart';
import 'package:reading_where/components/book_tile.dart';
import 'package:reading_where/pages/book_information.dart';
import 'package:reading_where/pages/book_list_filter_form.dart';

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

              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ExpansionTile(
                  leading: Image.asset(
                    'assets/images/globe.png',
                    width: 44,
                  ),
                  title: Text("Angola"),
                  children: [
                    BookTile(title: "Test")
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    return widget.bookListType == BookListType.country ? "Global" : "United States";
  }
}
