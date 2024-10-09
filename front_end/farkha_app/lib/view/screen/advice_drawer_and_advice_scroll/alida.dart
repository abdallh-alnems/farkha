// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import '../../widget/ad/banner/ad_all_banner.dart';
import 'package:farkha_app/view/widget/drawer/arrow_back/arrow_back.dart';
import 'package:farkha_app/view/widget/drawer/text_drawer/type_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Alida extends StatelessWidget {
  const Alida({super.key});

  @override
  Widget build(BuildContext context) {
    List<TableRow> rows = [];
    List<String> variable = [
      '',
      'لا يوجد',
      'لا يوجد',
      'لا يوجد',
      'لا يوجد',
      'لا يوجد',
      '1',
      '3',
      '3',
      '4',
      '4',
      '4',
      '4',
      '6',
      '8',
      '8',
      '8',
      '8',
      '8',
      '8',
      '8',
      '8',
      '8',
      '8',
      '8',
      '8',
      '8',
      '8',
      '8',
      '8',
      '8',
      '4',
      '4',
      '4',
      '4',
      '4',
      '2',
      '2',
      '2',
      '2',
      '2',
      '2',
      '2',
      '2',
      '2',
      '2',
      '2',
    ];
    List<String> variable2 = [
      '',
      '24',
      '24',
      '24',
      '24',
      '24',
      '23',
      '21',
      '21',
      '20',
      '20',
      '20',
      '20',
      '18',
      '16',
      '16',
      '16',
      '16',
      '16',
      '16',
      '16',
      '16',
      '16',
      '16',
      '16',
      '16',
      '16',
      '16',
      '16',
      '16',
      '16',
      '20',
      '20',
      '20',
      '20',
      '20',
      '22',
      '22',
      '22',
      '22',
      '22',
      '22',
      '22',
      '22',
      '22',
      '22',
      '22',
    ];
    List<String> variable3 = [
      '',
      '20',
      '20',
      '20',
      '20',
      '20',
      '20',
      '20',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
      '5',
    ];
    // ignore: no_leading_underscores_for_local_identifiers
    TableRow _tpye = const TableRow(children: <Widget>[
      Padding(
        padding: EdgeInsets.all(13),
        child: Text(
          'الاضاءة',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(13),
        child: Text(
          'الاظلام',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(13),
        child: Text(
          'شدة الاضاءة',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(13),
        child: Text(
          'العمر باليوم',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
    ]);

    for (int i = 1; i <= 45; i++,) {
      String darkness = variable[i];
      String lighting = variable2[i];
      String intensity = variable3[i];

      TableRow row = TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.all(13),
            child: Text(
              lighting,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Text(
              darkness,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Text(
              intensity,
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
                      type: 'فوائد الاظلام   : ',
                    ),
                    TypeDrawer(
                      type:
                          " زيادة الوزن وتحسين كفاءة الغذاء من خلال تقليل حركة الطيور وفعاليتها من جهة ومن خلال إعطاء الطيور وقت للنوم والراحة وبالتالي تقليل سرعة مرور المادة الغذائية بالقناة الهضمية والسماح لوقت أطول للامتصاص من جهة أخرى ",
                    ),
                    TypeDrawer(
                      type:
                          'تقليل ظهور نسبة التشوهات بالأرجل وحالات الموت المفاجئ وحالات الاستسقاء في البطن وتوفير الكهرباء مع إطالة العمر التشغيلي للمصابيح .الدراسات الحديثة تؤكد على أن النظام الضوئي يعتبر مفتـاح النجاح في تربية السلالات الحديثة لفـروج اللحـم هذه السلالات تتمتع بسرعة نمو فائقة وذات كفاءة عالية في تحويل الغذاء',
                    ),
                    TypeDrawer(
                      type:
                          'يرتفع مستوى أنزيم الفوسفاتيز القاعدي في الليل ويعتبر هذا الأنزيم مهم في تطور الهيكل العظمي .دورة الظلام والضـوء سـتؤدي إلى زيـادة إفـراز هرمون ( الميلاثونين ) المهم في تطور الجهاز المناعي .تحسن نسبة التجانس تصبح الطيور متقاربة بالوزن ونسبة التجانس الجيدة هي 85% إذا انخفضت إلى 60% فتعتبر نسبة التجانس ضعيفة',
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text('  الجدول التالي يمثل عدد ساعات الاظلام عند كل عمر'),
              Text(
                'ملحوظه  : يجب توزيع عدد ساعات الاظلام علي مدار اليوم بالتساوي * ',
                style: TextStyle(color: Colors.red),
              ),
              Container(
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
