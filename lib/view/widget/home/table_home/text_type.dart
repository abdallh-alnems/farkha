import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class TextType extends StatelessWidget {
  String type;
  TextType({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Text(
      type,
      style: TextStyle(
        fontSize: 14,
      ),
      textAlign: TextAlign.center,
    );
  }
}
