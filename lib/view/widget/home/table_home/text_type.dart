import 'package:flutter/material.dart';


// ignore: must_be_immutable
class TextType extends StatelessWidget {
  String type;
  TextType({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Text(
      type,
      style: const TextStyle(
        fontSize: 14,
      ),
      textAlign: TextAlign.center,
    );
  }
}
