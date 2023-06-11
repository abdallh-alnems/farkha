import 'package:flutter/material.dart';

class TitleDrawer extends StatelessWidget {
  final String title;
  const TitleDrawer({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      child: Text(
        title,
        style: TextStyle(fontSize: 17),
      ),
    );
  }
}
