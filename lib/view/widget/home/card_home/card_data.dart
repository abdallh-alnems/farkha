// ignore_for_file: file_names

import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class CardViewData extends StatelessWidget {
  final String type;
  final String price1;
  final String price2;
  final String price3;
  final String price4;
  String date1 = DateFormat('MM/dd').format(DateTime.now());
  String date2 = DateFormat('MM/dd')
      .format(DateTime.now().subtract(const Duration(days: 1)));
  String date3 = DateFormat('MM/dd')
      .format(DateTime.now().subtract(const Duration(days: 2)));
  String date4 = DateFormat('MM/dd')
      .format(DateTime.now().subtract(const Duration(days: 3)));
  CardViewData(
      {super.key,
      required this.type,
      required this.price1,
      required this.price2,
      required this.price3,
      required this.price4});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          color: Colors.red,
        ),
        width: double.infinity,
        height: 160,
        padding: const EdgeInsets.only(bottom: 5, right: 10, left: 15, top: 8),
        child: Column(
          children: [
            TextUtils(
              text: type,
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date4,
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  date3,
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  date2,
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  date1,
                  style: const TextStyle(fontSize: 18),
                ),
                const TextUtils(
                    text: ':  تحديث يوم',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)
              ],
            ),
            const Divider(
              color: Colors.black,
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price4,
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  price3,
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  price2,
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  price1,
                  style: const TextStyle(fontSize: 18),
                ),
                const TextUtils(
                  text: "       :  التنفيذ",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )
              ],
            )
          ],
        ));
  }
}
