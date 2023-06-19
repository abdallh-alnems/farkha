import 'package:flutter/material.dart';

class TextDate extends StatelessWidget {
  final String text;
  const TextDate({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.redAccent,
        fontSize: 19,
      ),
    );
  }
}
