// ignore_for_file: no_leading_underscores_for_local_identifiers

import '../../widget/ad/banner/ad_all_banner.dart';
import 'package:farkha_app/view/widget/drawer/arrow_back/arrow_back.dart';
import 'package:farkha_app/view/widget/drawer/text_drawer/type_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Awzan extends StatelessWidget {
  const Awzan({super.key});

  @override
  Widget build(BuildContext context) {
    List<TableRow> rows = [];
    List<String> variable = [
      '',
      '40',
      '54',
      '74',
      '94',
      '114',
      '140',
      '160',
      '197',
      '220',
      '255',
      '293',
      '334',
      '378',
      '400',
      '437',
      '490',
      '546',
      '605',
      '667',
      '732',
      '790',
      '855',
      '915',
      '957',
      '1003',
      '1065',
      '1100',
      '1131',
      '1300',
      '1395',
      '1500',
      '1630',
      '1770',
      '1900',
      '2000',
      '2025',
      '2145',
      '2230',
      '2300',
      '2325',
      '2411',
      '2507',
      '2626',
      '2750',
      '2800',
    ];
    TableRow _tpye = const TableRow(children: <Widget>[
      Padding(
        padding: EdgeInsets.all(13),
        child: Text(
          'الوزن بالجرام',
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
      String weight = variable[i];

      TableRow row = TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.all(13),
            child: Text(
              weight,
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
                    TypeDrawer(
                      type:
                          'إذا كنت تود تربية الفراخ بشكل صحي وزيادة وزنها بشكل طبيعي، فإليك بعض النصائح المفيدة:',
                    ),
                    TypeDrawer(
                      type:
                          "1 - الماء النظيف: يجب توفير الماء النظيف والعذب بشكل دائم للفراخ، ويجب تغيير الماء بانتظام للحفاظ على نظافته.",
                    ),
                    TypeDrawer(
                      type:
                          '2 - التحكم في درجة الحرارة: يجب توفير بيئة دافئة ومريحة للفراخ، ويمكن استخدام مصادر الحرارة المختلفة مثل اللمبات الحرارية أو الأرضيات الدافئة لتوفير هذه البيئة.',
                    ),
                    TypeDrawer(
                      type:
                          '3 - الصحة الجيدة: يجب مراقبة صحة الفراخ باستمرار، وتلقيحها ضد الأمراض الشائعة، وتوفير الرعاية الصحية اللازمة إذا ظهرت أي أعراض للمرض.',
                    ),
                    TypeDrawer(
                      type:
                          '4 - الفضاء المناسب: يجب توفير مساحة كافية للفراخ للحركة والنمو، وتوفير بيئة نظيفة وصحية لهم.',
                    ),
                    TypeDrawer(
                      type:
                          '5 - التخلص من الإجهاد: يجب تقليل مصادر الضوضاء والاضطرابات في البيئة المحيطة بالفراخ، وتجنب التعرض للإجهاد بشكل عام.',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              const Text(
                  'الجدول التالي يمثل  اوزان الفراخ بالجرام عند عمر كل يوم'),
              const Text(
                'ملحوظه : يجب وزن عشره فرخات ثم القسمه علي عشره ليكون المتوسط كالتالي',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
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
