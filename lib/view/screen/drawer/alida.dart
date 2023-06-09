import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          'العمر',
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
            padding: EdgeInsets.all(13),
            child: Text(
              lighting,
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(13),
            child: Text(
              darkness,
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(13),
            child: Text(
              intensity,
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(13),
            child: Text(
              '$i',
              style: TextStyle(fontSize: 20),
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
                Container(
                    margin: EdgeInsets.only(left: 3),
                    alignment: Alignment.bottomLeft,
                    child: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          size: 28,
                        ))),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Text(
                        'فوائد الاظلام   : ',
                        style: TextStyle(fontSize: 16),
                        textDirection: TextDirection.rtl,
                      ),
                      Text(
                        " زيادة الوزن وتحسين كفاءة الغذاء من خلال تقليل حركة الطيور وفعاليتها من جهة ومن خلال إعطاء الطيور وقت للنوم والراحة وبالتالي تقليل سرعة مرور المادة الغذائية بالقناة الهضمية والسماح لوقت أطول للامتصاص من جهة أخرى ",
                        style: TextStyle(fontSize: 20),
                        textDirection: TextDirection.rtl,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'تقليل ظهور نسبة التشوهات بالأرجل وحالات الموت المفاجئ وحالات الاستسقاء في البطن وتوفير الكهرباء مع إطالة العمر التشغيلي للمصابيح .الدراسات الحديثة تؤكد على أن النظام الضوئي يعتبر مفتـاح النجاح في تربية السلالات الحديثة لفـروج اللحـم هذه السلالات تتمتع بسرعة نمو فائقة وذات كفاءة عالية في تحويل الغذاء',
                        style: TextStyle(fontSize: 20),
                        textDirection: TextDirection.rtl,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'يرتفع مستوى أنزيم الفوسفاتيز القاعدي في الليل ويعتبر هذا الأنزيم مهم في تطور الهيكل العظمي .دورة الظلام والضـوء سـتؤدي إلى زيـادة إفـراز هرمون ( الميلاثونين ) المهم في تطور الجهاز المناعي .تحسن نسبة التجانس تصبح الطيور متقاربة بالوزن ونسبة التجانس الجيدة هي 85% إذا انخفضت إلى 60% فتعتبر نسبة التجانس ضعيفة',
                        style: TextStyle(fontSize: 20),
                        textDirection: TextDirection.rtl,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text('  الجدول التالي يمثل عدد ساعات الاظلام عند كل عمر'),
                Text(
                  'ملحوظه  : يجب توزيع عدد ساعات الاظلام علي مدار اليوم بالتساوي * ',
                  style: TextStyle(color: Colors.red),
                ),
                Container(
                  width: double.infinity,
                  child: Table(
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      border: TableBorder.all(),
                      children: <TableRow>[_tpye, ...rows]),
                ),
              ],
            ),
          )),
    );
  }
}
