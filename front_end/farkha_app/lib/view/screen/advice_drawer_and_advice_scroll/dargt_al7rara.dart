// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:farkha_app/view/widget/drawer/arrow_back/arrow_back.dart';
import 'package:farkha_app/view/widget/drawer/text_drawer/type_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import '../../widget/ad/banner/ad_all_banner.dart';

class DartgetAl7rara extends StatelessWidget {
  const DartgetAl7rara({super.key});

  @override
  Widget build(BuildContext context) {
    List<TableRow> rows = [];
    List<String> variable = [
      '',
      '35',
      '33',
      '33',
      '32',
      '31',
      '30',
      '30',
      '30',
      '29',
      '29',
      '29',
      '28',
      '28',
      '27',
      '27',
      '27',
      '26',
      '26',
      '25',
      '25',
      '25',
      '24',
      '24',
      '24',
      '23',
      '23',
      '23',
      '22',
      '22',
      '22',
      '22',
      '22',
      '21',
      '21',
      '21',
      '21',
      '20',
      '20',
      '20',
      '20',
      '20',
      '20',
      '20',
      '20',
      '20',
      '20',
    ];
    TableRow _tpye = const TableRow(children: <Widget>[
      Padding(
        padding: EdgeInsets.all(13),
        child: Text(
          'درجة الحرارة مئويه',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(13),
        child: Text(
          'العمر باليوم',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      )
    ]);

    for (int i = 1; i <= 45; i++,) {
      String temperature = variable[i];

      TableRow row = TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.all(13),
            child: Text(
              temperature,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Text(
              '$i',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
      rows.add(row);
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const ArrowBack(),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    const Text(
                      'علامات ارتفاع درجة الحرارة داخل الحظيرة',
                      style: TextStyle(fontSize: 16),
                      textDirection: TextDirection.rtl,
                    ),
                    TypeDrawer(
                      type:
                          "  تلاحظ تباعد الدجاج عن بعضه بصوره غير طبيعية مع فتح جناحيه عن جسمه وبعض الدجاج يمد رقبته للأمام على الأرض ",
                    ),
                    const Text(
                      'علامات انخفاض درجة الحرارة داخل المزرعه',
                      style: TextStyle(fontSize: 16),
                      textDirection: TextDirection.rtl,
                    ),
                    TypeDrawer(
                      type:
                          'الشعور بالبرودة خمول وكسل الدجاج وعدم إقباله على الأكل والشرب و تجمعه في جماعات بجوار الجدران أو تحت الحضانات ليحاول تدفئة نفسه',
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text('الجدول التالي يمثل درجات الحراره باليوم'),
              SizedBox(
                width: double.infinity,
                child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder.all(),
                    children: <TableRow>[_tpye, ...rows]),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AdAllBanner(),
      ),
    );
  }
}
