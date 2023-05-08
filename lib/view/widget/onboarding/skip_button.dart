import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';

class SkipButton extends StatelessWidget {
  const SkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {},
        // ignore: prefer_const_constructors
        child: TextUtils(
            text: 'تخطي',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black));
  }
}
