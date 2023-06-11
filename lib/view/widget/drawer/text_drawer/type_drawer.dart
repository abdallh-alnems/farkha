import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';

class TypeDrawer extends StatelessWidget {
  String type;
  TypeDrawer({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Text(
        type,
        style: TextStyle(fontSize: 20),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}
