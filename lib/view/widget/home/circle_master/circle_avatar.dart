import 'package:farkha_app/utils/theme.dart';
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
      backgroundColor: cyan,
      child: Text(
        type,
        style: TextStyle(
            fontSize: 25, fontWeight: FontWeight.w400, color: Colors.black),
      ),
    );
  }
}
