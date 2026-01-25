import 'package:flutter/material.dart';

class NavigationTile extends StatelessWidget {
  final String text;
  final Function onTap;
  final Widget? subtitle;

  const NavigationTile({super.key, required this.text, required this.onTap, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text, style: Theme.of(context).textTheme.titleLarge),
      subtitle: subtitle,
      trailing: const Icon(
        Icons.navigate_next,
      ),
      onTap: () {
        onTap();
      },
    );
  }
}
