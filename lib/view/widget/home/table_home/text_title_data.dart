import 'package:flutter/material.dart';

class TextDateHome extends StatelessWidget {
  final String text;
  const TextDateHome({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.redAccent,
        fontSize: 19,
      ),
    );
  }
}
