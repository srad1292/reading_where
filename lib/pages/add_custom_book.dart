import 'package:flutter/material.dart';
import 'package:reading_where/services/book_location_service.dart';
import '../models/book.dart';
import '../models/country.dart';
import '../service_locator.dart';
import '../services/book_service.dart';

class AddCustomBook extends StatefulWidget {
  const AddCustomBook({super.key});

  @override
  State<AddCustomBook> createState() => _AddCustomBookState();
}

class _AddCustomBookState extends State<AddCustomBook> {

  final BookService _bookService = serviceLocator.get<BookService>();
  final BookLocationService _bookLocationService = serviceLocator.get<BookLocationService>();


  late String _title;
  late TextEditingController _titleController;
  late String _description;
  late TextEditingController _descriptionController;

  final List<TextEditingController> _authorControllers = [];
  int? publishYear;
  String _countryCode = "";
  String _authorGender = "";

  late Book book;
  bool _changed = false;



  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    for (var controller in _authorControllers) { controller.dispose();}

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    book = Book(title: "", authorKey: [], providerKey: "", authorName: [], description: "");

    _title = book.title;
    _titleController = TextEditingController(text: _title);
    _titleController.addListener(inputChangeListener);

    _description = book.description ?? "";
    _descriptionController = TextEditingController(text: _description);
    _descriptionController.addListener(inputChangeListener);
    if(book.authorName.isNotEmpty) {
      for (String author in book.authorName) {
        TextEditingController authorController = TextEditingController(text: author);
        authorController.addListener(inputChangeListener);
        _authorControllers.add(authorController);
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
          title: const Text("Create Book"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
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

                FutureBuilder<List<Country>>(
                    future: _bookLocationService.getCountryList(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final countries = snapshot.data!;
                      return DropdownButtonFormField<String>(
                        value: _countryCode.isEmpty ? null : _countryCode,
                        decoration: const InputDecoration(
                          labelText: "Country",
                          border: OutlineInputBorder(),
                        ),
                        menuMaxHeight: 600,
                        items: countries
                            .map((country) => DropdownMenuItem(
                          value: country.code,
                          child: Text(country.name),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _countryCode = value ?? "";
                          });
                        },
                      );

                    }),

                const SizedBox(height: 24),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Publication Year",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(publishYear == null ? "Not Selected" : "$publishYear")
                        ),
                        TextButton(
                          onPressed: () async {
                            final year = await pickYear(context);
                            if (year != null) {
                              setState(() => publishYear = year);
                            }
                          },
                          child: const Text("Pick Year"),
                        ),
                        if(publishYear != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                publishYear = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                ..._getAuthorInputs(),

                ElevatedButton(
                  onPressed: () {
                    _createAuthorController();
                    setState(() {

                    });
                  },
                  child: const Text("Add Author +"),
                ),

                const SizedBox(height: 24),

                DropdownButtonFormField<String>(
                  value: _authorGender.isEmpty ? null : _authorGender,
                  decoration: const InputDecoration(
                    labelText: "Author Gender",
                    border: OutlineInputBorder(),
                  ),
                  items: _bookService.genderOptions.map((gender) => DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _authorGender = value ?? "";
                      _changed = true;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Save button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: _titleController.text.trim().isEmpty || _countryCode.isEmpty ? null : () async {
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

  Future<int?> pickYear(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime(DateTime.now().year+1),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDatePickerMode: DatePickerMode.year, // ← this is the key
    );

    return date?.year;
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

  void _createAuthorController({String author = ""}) {
    TextEditingController authorController = TextEditingController(text: author);
    authorController.addListener(inputChangeListener);
    _authorControllers.add(authorController);
  }


  Future _saveBookPressed() async {
    if(!_changed) {
      Navigator.of(context).pop(false);
      return;
    }

    book.title = _titleController.text;
    book.description = _descriptionController.text;
    book.countryCode = _countryCode;
    book.publishYear = publishYear;
    book.authorGender = _authorGender;

    List<String> updatedAuthors = [];
    List<String> updatedAuthorKeys = [];

    for(int i = 0; i < _authorControllers.length; i++) {
      if(_authorControllers[i].text.trim().isNotEmpty) {
        updatedAuthors.add(_authorControllers[i].text.trim());
        updatedAuthorKeys.add("");
      }
    }

    book.authorName = updatedAuthors;
    book.authorKey = updatedAuthorKeys;

    await _bookService.saveBook(book);

    if(!mounted) {
      return;
    }

    Navigator.of(context).pop(book);

  }



}
