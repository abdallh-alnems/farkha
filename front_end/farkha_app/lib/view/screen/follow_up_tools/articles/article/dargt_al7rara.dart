import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../data/data_source/static/poultry_management_data.dart';
import '../../../../../logic/controller/articles_controller.dart';
import '../../../../widget/app/ad/banner/ad_third_banner.dart';
import '../../../../widget/app/ad/native/ad_third_native.dart';
import '../../../../widget/bar/app_bar/custom_app_bar.dart';
import '../../../../widget/follow_up_tools/articles/title_article.dart';
import '../../../../widget/follow_up_tools/articles/type_article.dart';

class DartgetAl7rara extends StatelessWidget {
  const DartgetAl7rara({super.key});

  @override
  Widget build(BuildContext context) {
    final ArticlesController controller = Get.put(ArticlesController());

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(text: "درجات الحرارة"),
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
                      children: controller.getRows(
                        temperatureList,
                        context,
                        "درجة الحرارة المئوية",
                      ),
                    ),
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
