import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import '../../../../data/datasource/static/data_list/articles_list.dart';
import '../../../../test.dart';
import '../../../widget/ad/banner/ad_second_banner.dart';
import '../../../widget/ad/banner/ad_third_banner.dart';
import '../../../widget/ad/native/ad_third_native.dart';
import '../../../widget/app_bar/custom_app_bar.dart';
import '../../../widget/follow_up_tools/articles/articles/text_article/title_article.dart';
import '../../../widget/follow_up_tools/articles/articles/text_article/type_article.dart';

class DartgetAl7rara extends StatelessWidget {
  const DartgetAl7rara({super.key});

  @override
  Widget build(BuildContext context) {
    List<TableRow> rows = [];
    
    TableRow _tpye = TableRow(children: <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(vertical: 7).r,
        child: Text(
          'درجة الحرارة المئوية',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
      ),
      Text(
        'العمر باليوم',
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
      )
    ]);

    for (int i = 1; i <= 45; i++,) {
      String temperature = temperatureList[i];

      TableRow row = TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7).r,
            child: Text(
              temperature,
              style: TextStyle(fontSize: 19.sp),
              textAlign: TextAlign.center,
            ),
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
            text: "درجات الحرارة",
          ),
          Expanded(
            child: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15).r,
              child: Column(
                children: [
                  TitleArticle(
                    title: 'علامات ارتفاع درجة الحرارة داخل الحظيرة',
                  ),
                  TypeArticle(
                    type:
                        "تلاحظ تباعد الدجاج عن بعضه بصوره غير طبيعية مع فتح جناحيه عن جسمه وبعض الدجاج يمد رقبته للأمام على الأرض ",
                  ),
                  TitleArticle(
                    title: 'علامات انخفاض درجة الحرارة داخل المزرعه',
                  ),
                  TypeArticle(
                    type:
                        'الشعور بالبرودة خمول وكسل الدجاج وعدم إقباله على الأكل والشرب و تجمعه في جماعات بجوار الجدران أو تحت الحضانات ليحاول تدفئة نفسه',
                  ),
                  AdThirdNative(),
                  TitleArticle(
                    title: 'الجدول التالي يمثل درجات الحراره باليوم',
                  ),
                  SizedBox(
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
          ),
        ],
      ),
      bottomNavigationBar: AdThirdBanner(),
    );
  }
}
