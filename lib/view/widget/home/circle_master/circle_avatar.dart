import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CircleAvatarHome extends StatelessWidget {
  String type;
  CircleAvatarHome({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.amber,
      child: Text(
        type,
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
      ),
    );
  }
}
