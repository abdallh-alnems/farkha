import 'package:farkha_app/utils/theme.dart';
import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';

class ContinarType extends StatelessWidget {
  String type;
  ContinarType({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(15),
      width: double.infinity,
      height: 150,
      decoration:
          BoxDecoration(color: cyan, borderRadius: BorderRadius.circular(50)),
      child: TextUtils(
        color: Colors.white,
        fontSize: 50,
        fontWeight: FontWeight.bold,
        text: type,
      ),
    );
  }
}
