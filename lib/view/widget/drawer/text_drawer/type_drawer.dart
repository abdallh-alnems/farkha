import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TypeDrawer extends StatelessWidget {
  String type;
  TypeDrawer({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Text(
        type,
        style: const TextStyle(fontSize: 20),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}
