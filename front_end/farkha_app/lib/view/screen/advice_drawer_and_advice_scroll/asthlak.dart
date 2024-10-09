// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:farkha_app/view/widget/drawer/arrow_back/arrow_back.dart';
import 'package:farkha_app/view/widget/drawer/text_drawer/type_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import '../../widget/ad/banner/ad_all_banner.dart';

class Asthlak extends StatelessWidget {
  const Asthlak({super.key});

  @override
  Widget build(BuildContext context) {
    List<TableRow> rows = [];
    List<String> variable = [
      '',
      '6',
      '9',
      '15',
      '19',
      '20',
      '24',
      '26',
      '30',
      '35',
      '39',
      '44',
      '50',
      '55',
      '60',
      '72',
      '78',
      '92',
      '100',
      '105',
      '110',
      '115',
      '120',
      '125',
      '130',
      '130',
      '135',
      '140',
      '142',
      '145',
      '151',
      '154',
      '157',
      '158',
      '160',
      '163',
      '167',
      '171',
      '175',
      '175',
      '180',
      '185',
      '190',
      '195',
      '202',
      '203',
    ];
    TableRow _tpye = const TableRow(children: <Widget>[
      Padding(
        padding: EdgeInsets.all(13),
        child: Text(
          ' الاستهلاك بالجرام',
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
      String consumption = variable[i];

      TableRow row = TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.all(13),
            child: Text(
              consumption,
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
                          ' هناك بعض النقاط المتعلقة بإستهلاك الفراخ البيضاء للعلف',
                    ),
                    TypeDrawer(
                      type:
                          '1 - العلف المتوازن: يجب توفير علف متوازن تغذيتيًا يحتوي على النسب المناسبة من البروتين والدهون والكربوهيدرات، ويجب تغذية الفراخ بكميات مناسبة وفقًا للعمر والوزن.',
                    ),
                    TypeDrawer(
                      type:
                          '2 - النوعية: يجب استخدام علف عالي الجودة والمصمم خصيصًا لتلبية احتياجات الفراخ البيضاء، ويجب تجنب استخدام العلف الفاسد أو الفاسد.',
                    ),
                    TypeDrawer(
                      type:
                          '3 - الماء: يجب توفير الماء النظيف والعذب بشكل دائم للفراخ، ويجب تغيير الماء بانتظام للحفاظ على نظافته، ويزيد استهلاك الفرخ للعلف بزيادة استخدامه للماء.',
                    ),
                    TypeDrawer(
                      type:
                          '4 - البيئة: يجب توفير بيئة مناسبة للفراخ تحتوي على درجة حرارة ورطوبة مناسبة، ويجب تجنب التعرض للإجهاد والضوضاء والاضطرابات في البيئة المحيطة بالفراخ.',
                    ),
                    TypeDrawer(
                      type:
                          '5 - المراقبة: يجب مراقبة استهلاك الفراخ للعلف وزيادة وزنها بشكل منتظم، وتعديل كمية العلف وفقًا للحاجة، ومراقبة الفراخ لأي أعراض للمرض أو الوفاة المفاجئة.',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              const Text(
                  'الجدول التالي يمثل  استهلاك الفراخ البيضاء للعلف بالجرام عند عمر كل يوم'),
              const Text(
                'ملحوظه : الفرخ الابيض  ياكل متوسط 3.5 كيلو علف طول الدورة',
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
