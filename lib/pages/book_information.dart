import 'package:flutter/material.dart';

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
  DateTime? _readDate;
  int? _rating;
  bool _isRead = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();

    _countryCode = widget.book.countryCode ?? "";
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Book Title & Author ---
              Text(widget.book.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(widget.book.authorName.join(", "),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              if (widget.book.publishYear != null)
                Text("${widget.book.publishYear}"),

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
                        labelText: "Country Code",
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
                        setState(() => _countryCode = value ?? "");
                      },
                    );

                  }),

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
                  Book? result;
                  if(_changed || widget.book.localId == null) {
                    result = await _bookService.saveBook(widget.book);
                  }
                  if(!mounted) {
                    return;
                  }

                  Navigator.of(context).pop(result);

                },
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
