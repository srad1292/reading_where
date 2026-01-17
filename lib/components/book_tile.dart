import 'package:flutter/material.dart';

class BookTile extends StatefulWidget {
  final String title;

  const BookTile({super.key, required this.title});

  @override
  State<BookTile> createState() => _BookTileState();
}

class _BookTileState extends State<BookTile> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Checkbox(
          value: _isChecked,
          onChanged: (bool? value) {
            setState(() {
              _isChecked = value ?? false;
            });
          },
        ),
        title: Text(widget.title),
        trailing: const Icon(
          Icons.navigate_next,
        ),
        onTap: () {
          print("Book tile tapped");
        },
      );
  }
}
