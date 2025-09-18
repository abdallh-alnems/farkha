import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../data/data_source/static/growth_parameters.dart';
import '../../../../../logic/controller/tools_controller/articles_controller.dart';
import '../../../../widget/ad/banner.dart';
import '../../../../widget/ad/native.dart';
import '../../../../widget/app_bar/custom_app_bar.dart';
import '../../../../widget/tools/articles/title_article.dart';
import '../../../../widget/tools/articles/type_article.dart';

class DartgetAl7rara extends StatelessWidget {
  const DartgetAl7rara({super.key});

  @override
  Widget build(BuildContext context) {
    final ArticlesController controller = Get.put(ArticlesController());

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: "درجات الحرارة"),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15).r,
                child: Column(
                  children: [
                    const TitleArticle(
                      title: 'علامات ارتفاع درجة الحرارة داخل الحظيرة',
                    ),
                    const TypeArticle(
                      type:
                          "تلاحظ تباعد الدجاج عن بعضه بصوره غير طبيعية مع فتح جناحيه عن جسمه وبعض الدجاج يمد رقبته للأمام على الأرض ",
                    ),
                    const TitleArticle(
                      title: 'علامات انخفاض درجة الحرارة داخل المزرعه',
                    ),
                    const TypeArticle(
                      type:
                          'الشعور بالبرودة خمول وكسل الدجاج وعدم إقباله على الأكل والشرب و تجمعه في جماعات بجوار الجدران أو تحت الحضانات ليحاول تدفئة نفسه',
                    ),
                    const AdNativeWidget(),
                    const TitleArticle(
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
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
