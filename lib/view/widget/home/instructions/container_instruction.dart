import 'package:farkha_app/utils/theme.dart';
import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';

class ContainerInstruction extends StatelessWidget {
  const ContainerInstruction({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 60,
        color: scaColor,
        child: TextUtils(
          text: 'اوزان',
          fontWeight: FontWeight.w200,
          fontSize: 24,
          color: Colors.cyan,
        ),
      ),
    );
  }
}
