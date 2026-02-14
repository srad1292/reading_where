import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:reading_where/models/country_state.dart';

import '../enums/book_list_type.dart';
import '../models/book.dart';
import '../models/country.dart';
import '../service_locator.dart';
import '../services/book_location_service.dart';
import '../services/book_service.dart';

class EditBookInformation extends StatefulWidget {
  final Book book;
  const EditBookInformation({super.key, required this.book});

  @override
  State<EditBookInformation> createState() => _EditBookInformationState();
}

class _EditBookInformationState extends State<EditBookInformation> {

  final BookService _bookService = serviceLocator.get<BookService>();

  final List<TextEditingController> _authorControllers = [];
  final List<TextEditingController> _quoteControllers = [];

  late TextEditingController _descriptionController;
  late String _author;
  late String _description;
  bool _changed = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    for (var controller in _authorControllers) { controller.dispose();}
    for (var controller in _quoteControllers) { controller.dispose();}

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _description = widget.book.description ?? "";
    _descriptionController = TextEditingController(text: _description);
    _descriptionController.addListener(inputChangeListener);
    if(widget.book.authorName.isNotEmpty) {
      for (String author in widget.book.authorName) {
        TextEditingController authorController = TextEditingController(text: author);
        authorController.addListener(inputChangeListener);
        _authorControllers.add(authorController);
      }

    }

    if(widget.book.quotes.isNotEmpty) {
      for (String quote in widget.book.quotes) {
        _createQuoteController(quote: quote);
      }

    }
  }

  inputChangeListener() {
    _changed = true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () { FocusScope.of(context).unfocus(); },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Edit Book"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Book Title & Author ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: getBookBasicInfo(),
                    ),

                  ],
                ),


                const SizedBox(height: 24),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  minLines: 3,
                  maxLines: 12,
                ),

                const SizedBox(height: 24),

                ..._getAuthorInputs(),

                Text("Quotes"),
                const SizedBox(height: 10),

                ..._getQuoteInputs(),

                ElevatedButton(
                  onPressed: () {
                    _createQuoteController();
                    setState(() {

                    });
                  },
                  child: const Text("Add Quote +"),
                ),

                const SizedBox(height: 24),

                // Save button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _saveBookPressed();

                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getAuthorInputs() {
    List<Widget> response = [];
    for(int i = 0; i < _authorControllers.length; i++) {
      response.add(
        TextField(
          controller: _authorControllers[i],
          decoration: InputDecoration(
            labelText: "Author ${i + 1}",
            border: const OutlineInputBorder(),
          ),
        )
      );

      response.add(const SizedBox(height: 24));
    }

    return response;
  }

  void _createQuoteController({String quote = ""}) {
    TextEditingController quoteController = TextEditingController(text: quote);
    quoteController.addListener(inputChangeListener);
    _quoteControllers.add(quoteController);
  }

  List<Widget> _getQuoteInputs() {
    List<Widget> response = [];
    for(int i = 0; i < _quoteControllers.length; i++) {
      response.add(
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quoteControllers[i],
                  decoration: InputDecoration(
                    labelText: "Quote ${i + 1}",
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                    shape: BoxShape.circle
                  ),
                  child: IconButton(
                    onPressed: () {
                      _quoteControllers[i].dispose();
                      _quoteControllers.removeAt(i);
                      setState(() {
                        _changed = true;
                      });
                    },
                    icon: const Icon(
                      Icons.remove,
                      color: Colors.red
                    )
                  ),
                ),
              ),
            ],
          )
      );

      response.add(const SizedBox(height: 24));
    }

    return response;
  }


  Widget getBookBasicInfo() {
    String authors = widget.book.authorName.join(", ") ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          widget.book.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          softWrap: true,

        ),

        Text(
          authors,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          softWrap: true,
        ),

        if (widget.book.publishYear != null)
          Text("${widget.book.publishYear}"),


      ],
    );
  }

  Future _saveBookPressed() async {
    if(!_changed) {
      Navigator.of(context).pop(false);
      return;
    }

    widget.book.description = _descriptionController.text;

    List<String> updatedAuthors = [];
    List<String> updatedAuthorKeys = [];

    for(int i = 0; i < _authorControllers.length; i++) {
      if(_authorControllers[i].text.trim().isNotEmpty) {
        updatedAuthors.add(_authorControllers[i].text.trim());
        updatedAuthorKeys.add(widget.book.authorKey[i]);
      }
    }

    debugPrint("Author name + key before changes");
    for(int i = 0; i < widget.book.authorName.length; i++) {
      debugPrint("${widget.book.authorName[i]} -- ${widget.book.authorKey[i]}");
    }

    widget.book.authorName = updatedAuthors;
    widget.book.authorKey = updatedAuthorKeys;

    List<String> quotes = [];
    for(int i = 0; i < _quoteControllers.length; i++) {
      if(_quoteControllers[i].text.trim().isNotEmpty) {
        quotes.add(_quoteControllers[i].text.trim());
      }
    }

    widget.book.quotes = quotes;


    debugPrint("Author name + key after changes");
    for(int i = 0; i < widget.book.authorName.length; i++) {
      debugPrint("${widget.book.authorName[i]} -- ${widget.book.authorKey[i]}");
    }

    if(_changed && widget.book.localId != null) {
      await _bookService.saveBook(widget.book);
    }
    if(!mounted) {
      return;
    }

    Navigator.of(context).pop(true);

  }



}
