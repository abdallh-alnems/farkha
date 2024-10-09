import 'package:flutter/material.dart';

class TitleDrawer extends StatelessWidget {
  final String title;
  const TitleDrawer({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 17),
      ),
    );
  }
}
