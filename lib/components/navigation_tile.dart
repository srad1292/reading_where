import 'package:flutter/material.dart';

class NavigationTile extends StatelessWidget {
  final String text;
  final bool largeTitle;
  final Function onTap;
  final Widget? subtitle;

  const NavigationTile({super.key, required this.text, this.largeTitle = true, required this.onTap, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text, style: largeTitle ?
        Theme.of(context).textTheme.titleLarge : Theme.of(context).textTheme.titleMedium),
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
