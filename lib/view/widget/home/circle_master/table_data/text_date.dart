import 'package:flutter/material.dart';

class TextDateMaster extends StatelessWidget {
  final String text;
  const TextDateMaster({super.key, required this.text});

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
