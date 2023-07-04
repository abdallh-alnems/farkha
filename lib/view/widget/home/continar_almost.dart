import 'package:farkha_app/utils/theme.dart';
import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContinarAlmost extends StatelessWidget {
  ContinarAlmost({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.snackbar(
          '',
          '',
          titleText: Text(
            '',
            style: TextStyle(fontSize: 0),
            textAlign: TextAlign.center,
          ),
          messageText: Text(
            'قريبا',
            style: TextStyle(fontSize: 23),
            textAlign: TextAlign.center,
          ),
        );
      },
      child: Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(right: 15, left: 15, top: 15, bottom: 25),
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
            color: mainColor, borderRadius: BorderRadius.circular(50)),
        child: Column(
          children: [
            TextUtils(
              color: Colors.red,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              text: 'قريبا',
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
                  children: [Icon(Icons.timeline), Text('توقعات')],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
