import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../data/datasource/static/data_list/articles_list.dart';
import '../../../widget/ad/banner/ad_third_banner.dart';
import '../../../widget/ad/native/ad_third_native.dart';
import '../../../widget/app_bar/custom_app_bar.dart';
import '../../../widget/follow_up_tools/articles/articles/text_article/title_article.dart';
import '../../../widget/follow_up_tools/articles/articles/text_article/type_article.dart';

class Awzan extends StatelessWidget {
  const Awzan({super.key});

  @override
  Widget build(BuildContext context) {
    List<TableRow> rows = [];
    
    TableRow _tpye = TableRow(children: <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(vertical: 7).r,
        child: Text(
          'الوزن بالجرام',
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
      String weight = weightsList[i];

      TableRow row = TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7).r,
            child: Text(
              weight,
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
            text: "اوزان",
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15).r,
                child: Column(
                  children: [
                    TitleArticle(
                      title: 'بعض النصائح من اجل الوصول الي الوزن المطلوب',
                    ),
                    TypeArticle(
                      type:
                          "1 - الماء النظيف: يجب توفير الماء النظيف والعذب بشكل دائم للفراخ، ويجب تغيير الماء بانتظام للحفاظ على نظافته.",
                    ),
                    TypeArticle(
                      type:
                          '2 - التحكم في درجة الحرارة: يجب توفير بيئة دافئة ومريحة للفراخ، ويمكن استخدام مصادر الحرارة المختلفة مثل اللمبات الحرارية أو الأرضيات الدافئة لتوفير هذه البيئة.',
                    ),
                    TypeArticle(
                      type:
                          '3 - الصحة الجيدة: يجب مراقبة صحة الفراخ باستمرار، وتلقيحها ضد الأمراض الشائعة، وتوفير الرعاية الصحية اللازمة إذا ظهرت أي أعراض للمرض.',
                    ),
                    TypeArticle(
                      type:
                          '4 - المساحة المناسبة: يجب توفير مساحة كافية للفراخ للحركة والنمو، وتوفير بيئة نظيفة وصحية لهم.',
                    ),
                    TypeArticle(
                      type:
                          '5 - التخلص من الإجهاد: يجب تقليل مصادر الضوضاء والاضطرابات في البيئة المحيطة بالفراخ، وتجنب التعرض للإجهاد بشكل عام.',
                    ),
                    AdThirdNative(),
                    Text(
                      'ملحوظة : يجب وزن عشر فرخات ثم القسمه علي عشره ليكون المتوسط كالتالي',
                      style: TextStyle(color: Colors.red, fontSize: 11.sp),
                      textAlign: TextAlign.center,
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
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdThirdBanner(),
    );
  }
}
