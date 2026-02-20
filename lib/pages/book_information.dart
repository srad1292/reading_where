import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:reading_where/models/country_state.dart';
import 'package:reading_where/pages/edit_book_information.dart';

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
  late String _authorGender;
  late String _category;
  DateTime? _readDate;
  int? _rating;
  bool _isRead = false;
  bool _changed = false;
  bool _showFullDescription = false;
  bool _showStateSelect = false;
  bool? _excludeFromCountryList;
  String? _description;

  late Future<Book> _bookInfoFuture;
  late Future<Uint8List> _bookCoverFuture;
  late Future<Book> _authorNameFuture;

  @override
  void initState() {
    super.initState();

    _bookInfoFuture = _bookService.getBookInformation(widget.book);
    _bookCoverFuture = _bookService.fetchCoverBytes(widget.book.coverId ?? -1);
    _authorNameFuture = _bookService.getAuthorNames(widget.book);

    if (_bookService.bookListType == BookListType.states) {
      _countryCode = "us";
    } else {
      _countryCode = widget.book.countryCode ?? "";
    }

    _showStateSelect = _countryCode == "us";
    _stateCode = widget.book.stateCode ?? "";
    _authorGender = widget.book.authorGender ?? "";
    _category = widget.book.category ?? "";
    _readDate = widget.book.readDate;
    _rating = widget.book.rating;
    _excludeFromCountryList = widget.book.excludeFromCountryList ?? false;

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
      setState(() {
        _readDate = picked;
        _isRead = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Book Information"),
        centerTitle: true,
        actions: _getBookInformationActions(),
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


              bookDescriptionWidget(),

              if(widget.book.quotes.isNotEmpty)
                _quoteDisplay(),


              const Text(
                "Details",
                style: TextStyle(
                    fontWeight: FontWeight.bold
                ),
              ),

              SizedBox(height: 12),

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
                      menuMaxHeight: 600,
                      items: countries
                          .map((country) => DropdownMenuItem(
                            value: country.code,
                            child: Text(country.name),
                          ))
                          .toList(),
                      onChanged: (value) {
                        _changed = true;

                        setState(() {
                          if(value != 'us') {
                            _stateCode = "";
                          }
                          _countryCode = value ?? "";
                          _showStateSelect = value == "us";
                        });
                      },
                    );

                  }),

              const SizedBox(height: 24),

              if(_showStateSelect)
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
                        setState(() {
                          _stateCode = value ?? "";
                          _changed = true;
                        });
                      },
                    );

                  }),

              if(_showStateSelect)
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

              DropdownButtonFormField<String>(
                value: _category.isEmpty ? null : _category,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                items: _bookService.categoryOptions.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value ?? "";
                    _changed = true;
                  });
                },
              ),

              const SizedBox(height: 24),

              // --- Read Date Picker ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Read Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
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
                            setState(() {
                              _readDate = null;
                              _isRead = false;
                              _changed = true;
                            });
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
                    const Text("Rating", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: _getRatingButtons()
                          ),
                        ),
                        if ((_rating ?? 0) > 0)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _rating = null;
                                _changed = true;
                              });
                            },
                          ),

                      ],
                    )
                  ],
                ),

              if(_showStateSelect && _isRead)
                const SizedBox(height: 24),

              if(_showStateSelect)
                Row(
                  children: [
                    Checkbox(
                        value: _excludeFromCountryList,
                        onChanged: (value) {
                          setState(() {
                            _changed = true;
                            _excludeFromCountryList = value;
                          });
                        }
                    ),
                    const Text("Exclude From Country List?")
                  ],
                ),


              const SizedBox(height: 24),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if(!_changed) {
                        Navigator.of(context).pop(false);
                        return;
                      }

                      if(_isRead) {
                        widget.book.readDate = _readDate;
                        widget.book.rating = _rating;
                        widget.book.excludeFromCountryList = _excludeFromCountryList;
                      } else {
                        widget.book.readDate = null;
                        widget.book.rating = null;
                        widget.book.excludeFromCountryList = false;
                      }
                      if((widget.book.description ?? "").isEmpty) {
                        widget.book.description = _description;
                      }
                      widget.book.countryCode = _countryCode;
                      widget.book.stateCode = _stateCode;
                      widget.book.authorGender = _authorGender;
                      widget.book.category = _category;
                      Book? result;
                      if(_changed || widget.book.localId == null) {
                        debugPrint("Saving book");
                        debugPrint(widget.book.toString());
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
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getRatingButtons() {
    List<Widget> result = [];
    double iconSize = 36;
    for(int index = 0; index < 5; index++) {
      result.add(
        IconButton(
          onPressed: () {
            _changed = true;
            setState(() => _rating = index+1);
          },
          icon: (_rating ?? 0) > index ?
            Icon(Icons.star, size: iconSize, color: Theme.of(context).colorScheme.primary) :
            Icon(Icons.star_border, size: iconSize, color: Colors.blueGrey)),
        );
    }
    return result;
  }

  List<Widget> _getBookInformationActions() {
    return [
      PopupMenuButton(
        onSelected: (value) async {
          switch (value) {
            case 'edit':
              bool? updated = await Navigator.push(context,
               MaterialPageRoute(
                   builder: (_) => EditBookInformation(book: widget.book)),
              );
              if(updated == true && mounted) {
                setState(() {
                  _bookInfoFuture = _bookService.getBookInformation(widget.book);
                });
              }
              break;
            case 'delete':
              final confirmed = await showDeleteConfirmation(context);
              if (confirmed) {
                bool deleted = await deleteBook();
                if(deleted && mounted) {
                  Navigator.of(context).pop(true);
                }
              };
          }
        },
        itemBuilder: (context) =>
        [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          if(widget.book.localId != null)
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    ];
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
        FutureBuilder(
          future: _authorNameFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            String authors = snapshot.data?.authorName.join(",") ?? "";
            const maxLength = 120;
            String visibleAuthors = authors.length < maxLength ? authors : "${authors.substring(0, min(maxLength, authors.length))}...";

            return Text(
              visibleAuthors,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              softWrap: true,
            );
          }

        ),
        if (widget.book.publishYear != null)
          Text("${widget.book.publishYear}"),


      ],
    );
  }

  Widget bookDescriptionWidget() {
    return FutureBuilder(
        future: _bookInfoFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          String description = snapshot.data?.description ?? "";
          _description = description;
          const maxLength = 180;
          bool showDescriptionExpansion = description.length > maxLength;
          String visibleDescription = !showDescriptionExpansion || _showFullDescription ? description : "${description.substring(0, min(maxLength, description.length))}...";
          return Padding(
            padding: EdgeInsets.only(bottom: description.isEmpty ? 1 : 24),
            child: Column(
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
            ),
          );
        }
    );
  }

  Widget _quoteDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quotes",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        ...widget.book.quotes.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: MarkdownBody(data: "\"$e\""),
        )),
        SizedBox(height: 24)
      ],
    );
  }




}
