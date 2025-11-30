import 'package:flutter/material.dart';

class TableHeaderCell extends StatelessWidget {
  final String text;
  final int flex;

  const TableHeaderCell({super.key, required this.text, this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
