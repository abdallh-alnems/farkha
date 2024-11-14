import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../data/data_source/static/data_list/articles_list.dart';
import '../../../../widget/ad/native/ad_third_native.dart';
import '../../../../widget/app_bar/custom_app_bar.dart';
import '../../../../widget/follow_up_tools/articles/text_article/title_article.dart';
import '../../../../widget/follow_up_tools/articles/text_article/type_article.dart';
import 'package:flutter/material.dart';
import '../../../../widget/ad/banner/ad_third_banner.dart';

class Alida extends StatelessWidget {
  const Alida({super.key});

  @override
  Widget build(BuildContext context) {
    List<TableRow> rows = [];

    TableRow tpye = TableRow(children: <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(vertical: 7).r,
        child: Text(
          'الاضاءة',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
      ),
      Text(
        'الاظلام',
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
      Text(
        'شدة الاضاءة',
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
      Text(
        'العمر باليوم',
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
    ]);

    for (int i = 1; i <= 45; i++,) {
      String darkness = darknessLevels[i];
      String lighting = lightLevels[i];
      String intensity = intensityLevels[i];

      TableRow row = TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7).r,
            child: Text(
              lighting,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            darkness,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          Text(
            intensity,
            style: TextStyle(fontSize: 19.sp),
            textAlign: TextAlign.center,
          ),
          Text(
            '$i',
            style: TextStyle(fontSize: 19.sp),
            textAlign: TextAlign.center,
          ),
        ],
      );
      rows.add(row);
    }

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            text: "الاضاءة",
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15).r,
                child: Column(
                  children: [
                    TitleArticle(
                      title: 'فوائد الاظلام',
                    ),
                    TypeArticle(
                      type:
                          "زيادة الوزن وتحسين كفاءة الغذاء من خلال تقليل حركة الطيور وفعاليتها من جهة ومن خلال إعطاء الطيور وقت للنوم والراحة وبالتالي تقليل سرعة مرور المادة الغذائية بالقناة الهضمية والسماح لوقت أطول للامتصاص من جهة أخرى ",
                    ),
                    TypeArticle(
                      type:
                          'تقليل ظهور نسبة التشوهات بالأرجل وحالات الموت المفاجئ وحالات الاستسقاء في البطن وتوفير الكهرباء مع إطالة العمر التشغيلي للمصابيح .الدراسات الحديثة تؤكد على أن النظام الضوئي يعتبر مفتـاح النجاح في تربية السلالات الحديثة لفـروج اللحـم هذه السلالات تتمتع بسرعة نمو فائقة وذات كفاءة عالية في تحويل الغذاء',
                    ),
                    TypeArticle(
                      type:
                          'يرتفع مستوى أنزيم الفوسفاتيز القاعدي في الليل ويعتبر هذا الأنزيم مهم في تطور الهيكل العظمي .دورة الظلام والضـوء سـتؤدي إلى زيـادة إفـراز هرمون ( الميلاثونين ) المهم في تطور الجهاز المناعي .تحسن نسبة التجانس تصبح الطيور متقاربة بالوزن ونسبة التجانس الجيدة هي 85% إذا انخفضت إلى 60% فتعتبر نسبة التجانس ضعيفة',
                    ),
                    AdThirdNative(),
                    Text(
                      'ملحوظة : يجب توزيع عدد ساعات الاظلام علي مدار اليوم بالتساوي',
                      style: TextStyle(color: Colors.red, fontSize: 11.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Table(
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          border: TableBorder.all(),
                          children: <TableRow>[tpye, ...rows]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdThirdBanner(),
    );
  }
}
