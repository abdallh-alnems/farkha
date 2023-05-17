// ignore_for_file: file_names

import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';

class CardItem extends StatelessWidget {
  final String type;

  const CardItem({super.key, required this.type});



  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.red,
        ),
        width: double.infinity,
        height: 150,
        padding: const EdgeInsets.all(11),
        child: Column(
          children: [
            TextUtils(
              text: type,
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('7/5'),
                Text('8/5'),
                Text('9/5'),
                Text('10/5'),
                TextUtils(
                    text: ':  تحديث يوم',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)
              ],
            ),
            const Divider(
              color: Colors.black,
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('100'),
                Text('100'),
                Text('100'),
                Text('100'),
                TextUtils(
                  text: "        :  التنفيذ",
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )
              ],
            )
          ],
        ));
  }
}
