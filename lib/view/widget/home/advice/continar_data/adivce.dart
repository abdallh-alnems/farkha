import 'package:flutter/material.dart';

class Advice extends StatelessWidget {
  final String text;
  final IconData icon;
  const Advice({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon),
        ),
        Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 10),
        )
      ],
    );
  }
}
