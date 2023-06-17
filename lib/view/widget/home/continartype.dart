import 'package:farkha_app/utils/theme.dart';
import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';

class ContinarAlmost extends StatelessWidget {
  String type;
  ContinarAlmost({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.all(15),
      width: double.infinity,
      height: 100,
      decoration:
          BoxDecoration(color: cyan, borderRadius: BorderRadius.circular(50)),
      child: Column(
        children: [
          TextUtils(
            color: Colors.red,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            text: type,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [Icon(Icons.radar), Text('مستلزمات')],
              ),
              Column(
                children: [Icon(Icons.home), Text('المزرعة')],
              ),
              Column(
                children: [Icon(Icons.cached), Text('دورة')],
              ),
              Column(
                children: [Icon(Icons.help), Text('مساعدة')],
              ),
              Column(
                children: [Icon(Icons.timeline), Text('توفعات')],
              ),
            ],
          )
        ],
      ),
    );
  }
}
