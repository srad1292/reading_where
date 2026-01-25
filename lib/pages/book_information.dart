import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:reading_where/models/country_state.dart';

import '../enums/book_list_type.dart';
import '../models/book.dart';
import '../models/country.dart';
import '../service_locator.dart';
import '../services/book_location_service.dart';
import '../services/book_service.dart';

class BookInformation extends StatefulWidget {
  final Book book;
  const BookInformation({super.key, required this.book});

  @override
  State<BookInformation> createState() => _BookInformationState();
}

class _BookInformationState extends State<BookInformation> {

  final BookLocationService _bookLocationService = serviceLocator.get<BookLocationService>();
  final BookService _bookService = serviceLocator.get<BookService>();

  late String _countryCode;
  late String _stateCode;
  DateTime? _readDate;
  int? _rating;
  bool _isRead = false;
  bool _changed = false;
  bool _showFullDescription = false;

  late Future<Book> _bookInfoFuture;
  late Future<Uint8List> _bookCoverFuture;

  @override
  void initState() {
    super.initState();

    _bookInfoFuture = _bookService.getBookInformation(widget.book);
    _bookCoverFuture = _bookService.fetchCoverBytes(widget.book.coverId ?? -1);

    if (_bookService.bookListType == BookListType.states) {
      _countryCode = "us";
    } else {
      _countryCode = widget.book.countryCode ?? "";
    }
    _stateCode = widget.book.stateCode ?? "";
    _readDate = widget.book.readDate;
    _rating = widget.book.rating;

    _isRead = _readDate != null; // derive initial state
  }

  Future<void> _pickReadDate() async {
    final now = DateTime.now();
    final initial = _readDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (picked != null) {
      _changed = true;
      setState(() => _readDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Book Information"),
        centerTitle: true,
        actions: widget.book.localId == null ? null : [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDeleteConfirmation(context);
              if (confirmed) {
                bool deleted = await deleteBook();
                if(deleted && mounted) {
                  Navigator.of(context).pop(true);
                }
              }
            },
          ),
        ],

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
                  getCoverImage(),
                  SizedBox(width: 10),
                  Expanded(
                    child: getBookBasicInfo(),
                  ),
                ],
              ),


              const SizedBox(height: 24),

              // --- Country Code ---
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
                      items: countries
                          .map((country) => DropdownMenuItem(
                            value: country.code,
                            child: Text(country.name),
                          ))
                          .toList(),
                      onChanged: (value) {
                        _changed = true;
                        if(value != 'us') {
                          _stateCode = "";
                        }
                        setState(() => _countryCode = value ?? "");
                      },
                    );

                  }),

              const SizedBox(height: 24),

              if(_countryCode == 'us')
                FutureBuilder<List<CountryState>>(
                  future: _bookLocationService.getCountryStateList(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final states = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: _stateCode.isEmpty ? null : _stateCode,
                      decoration: const InputDecoration(
                        labelText: "State",
                        border: OutlineInputBorder(),
                      ),
                      items: states
                          .map((countryState) => DropdownMenuItem(
                        value: countryState.code,
                        child: Text(countryState.name),
                      ))
                          .toList(),
                      onChanged: (value) {
                        _changed = true;
                        setState(() => _stateCode = value ?? "");
                      },
                    );

                  }),

              if(_countryCode == 'us')
                const SizedBox(height: 24),

              // --- Read Switch ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Read?", style: TextStyle(fontSize: 16)),
                  Switch(
                    value: _isRead,
                    onChanged: (value) {
                      setState(() {
                        _isRead = value;
                        _changed = true;
                        if (!value) {
                          _readDate = null;
                          _rating = null;
                        }
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // --- Read Date Picker ---
              if (_isRead)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Read Date", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _readDate == null
                                ? "No date selected"
                                : "${_readDate!.year}-${_readDate!.month.toString().padLeft(2, '0')}-${_readDate!.day.toString().padLeft(2, '0')}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        TextButton(
                          onPressed: _pickReadDate,
                          child: const Text("Pick Date"),
                        ),
                        if (_readDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _readDate = null);
                            },
                          ),
                      ],
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // --- Rating ---
              if (_isRead)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Rating", style: TextStyle(fontSize: 16)),
                    Slider(
                      value: (_rating ?? 0).toDouble(),
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: "${_rating ?? 0}",
                      onChanged: (value) {
                        _changed = true;
                        setState(() => _rating = value.toInt());
                      },
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () async {
                  if(_isRead) {
                    widget.book.readDate = _readDate;
                    widget.book.rating = _rating;
                  } else {
                    widget.book.readDate = null;
                    widget.book.rating = null;
                  }
                  widget.book.countryCode = _countryCode;
                  widget.book.stateCode = _stateCode;
                  Book? result;
                  if(_changed || widget.book.localId == null) {
                    result = await _bookService.saveBook(widget.book);
                  }
                  if(!mounted) {
                    return;
                  }

                  Navigator.of(context).pop(result != null);

                },
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must choose an option
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Book"),
          content: const Text("Are you sure you want to delete this book? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    ) ?? false; // default to false if dialog is dismissed
  }

  Future<bool> deleteBook() async {
    return await _bookService.deleteBook(widget.book.localId!);
  }


  Widget getCoverImage() {
    return FutureBuilder(
        future: _bookCoverFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if(snapshot.data!.isEmpty) {
            return Image.asset(
              "assets/images/no_image.png",
              width: 44,
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              snapshot.data!,
              width: 120,
              height: 180,
              fit: BoxFit.cover,
            ),
          );
        }
    );
  }

  Widget getBookBasicInfo() {
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
          widget.book.authorName.join(", "),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          softWrap: true,
        ),
        if (widget.book.publishYear != null)
          Text("${widget.book.publishYear}"),
        FutureBuilder(
          future: _bookInfoFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            String description = snapshot.data?.description ?? "";
            const maxLength = 180;
            bool showDescriptionExpansion = description.length > maxLength;
            String visibleDescription = !showDescriptionExpansion || _showFullDescription ? description : "${description.substring(0, min(maxLength, description.length))}...";
            return Column(
              children: [
                Text(visibleDescription, softWrap: true,),
                if(showDescriptionExpansion)
                  GestureDetector(
                    child: Text(
                      _showFullDescription ? "Show Less -" : "Show More +",
                      style: const TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      setState(() {
                        _showFullDescription = !_showFullDescription;
                      });
                    },
                  )
              ]
            );
          }
        ),
      ],
    );
  }


}
