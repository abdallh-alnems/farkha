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
      radius: 40,
      backgroundColor: scaColor,
      child: Text(
        type,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white),
      ),
    );
  }
}
