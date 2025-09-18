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

class Awzan extends StatelessWidget {
  const Awzan({super.key});

  @override
  Widget build(BuildContext context) {
    final ArticlesController controller = Get.put(ArticlesController());

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: "اوزان"),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15).r,
                child: Column(
                  children: [
                    const TitleArticle(
                      title: 'بعض النصائح من اجل الوصول الي الوزن المطلوب',
                    ),
                    const TypeArticle(
                      type:
                          "1 - الماء النظيف: يجب توفير الماء النظيف والعذب بشكل دائم للفراخ، ويجب تغيير الماء بانتظام للحفاظ على نظافته.",
                    ),
                    const TypeArticle(
                      type:
                          '2 - التحكم في درجة الحرارة: يجب توفير بيئة دافئة ومريحة للفراخ، ويمكن استخدام مصادر الحرارة المختلفة مثل اللمبات الحرارية أو الأرضيات الدافئة لتوفير هذه البيئة.',
                    ),
                    const TypeArticle(
                      type:
                          '3 - الصحة الجيدة: يجب مراقبة صحة الفراخ باستمرار، وتلقيحها ضد الأمراض الشائعة، وتوفير الرعاية الصحية اللازمة إذا ظهرت أي أعراض للمرض.',
                    ),
                    const TypeArticle(
                      type:
                          '4 - المساحة المناسبة: يجب توفير مساحة كافية للفراخ للحركة والنمو، وتوفير بيئة نظيفة وصحية لهم.',
                    ),
                    const TypeArticle(
                      type:
                          '5 - التخلص من الإجهاد: يجب تقليل مصادر الضوضاء والاضطرابات في البيئة المحيطة بالفراخ، وتجنب التعرض للإجهاد بشكل عام.',
                    ),
                    const AdNativeWidget(),
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
                        children: controller.getRows(
                          weightsList,
                          context,
                          "الوزن بالجرام",
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
