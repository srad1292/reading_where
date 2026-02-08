import 'package:flutter/material.dart';
import 'package:reading_where/models/book.dart';

class BookTile extends StatefulWidget {
  final Book book;
  final Function onTap;

  const BookTile({super.key, required this.book, required this.onTap});

  @override
  State<BookTile> createState() => _BookTileState();
}

class _BookTileState extends State<BookTile> {
  @override
  Widget build(BuildContext context) {
    String year = "";
    if (widget.book.publishYear != null) {
      year = " (${widget.book.publishYear})";
    }
    return ListTile(
        leading: widget.book.readDate == null ? null : const Icon(
          Icons.verified,
          color: Colors.green,
        ),
        title: Text("${widget.book.title}$year", style: Theme.of(context).textTheme.titleMedium),
        subtitle: widget.book.authorName.isEmpty ? null : Text(widget.book.authorName.join(", "), style: Theme.of(context).textTheme.titleSmall),
        trailing: const Icon(
          Icons.navigate_next,
        ),
        onTap: () {
          widget.onTap();
        },
      );
  }
}
