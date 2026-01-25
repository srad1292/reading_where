import 'package:flutter/material.dart';

class BookTile extends StatefulWidget {
  final String title;
  final bool isRead;
  final Function onTap;

  const BookTile({super.key, required this.title, required this.isRead, required this.onTap});

  @override
  State<BookTile> createState() => _BookTileState();
}

class _BookTileState extends State<BookTile> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: widget.isRead == false ? null : const Icon(
          Icons.verified,
          color: Colors.blue,
        ),
        title: Text(widget.title),
        trailing: const Icon(
          Icons.navigate_next,
        ),
        onTap: () {
          widget.onTap();
        },
      );
  }
}
