import 'package:flutter/material.dart';

class NavigationTile extends StatelessWidget {
  final String text;
  final Function onTap;

  const NavigationTile({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text),
      trailing: const Icon(
        Icons.navigate_next,
      ),
      onTap: () {
        onTap();
      },
    );
  }
}
