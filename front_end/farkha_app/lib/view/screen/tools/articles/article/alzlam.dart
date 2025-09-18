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

class Alzlam extends StatelessWidget {
  const Alzlam({super.key});

  @override
  Widget build(BuildContext context) {
    final ArticlesController controller = Get.put(ArticlesController());

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: "الاضاءة"),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15).r,
                child: Column(
                  children: [
                    const TitleArticle(title: 'فوائد الاظلام'),
                    const TypeArticle(
                      type:
                          "زيادة الوزن وتحسين كفاءة الغذاء من خلال تقليل حركة الطيور وفعاليتها من جهة ومن خلال إعطاء الطيور وقت للنوم والراحة وبالتالي تقليل سرعة مرور المادة الغذائية بالقناة الهضمية والسماح لوقت أطول للامتصاص من جهة أخرى ",
                    ),
                    const TypeArticle(
                      type:
                          'تقليل ظهور نسبة التشوهات بالأرجل وحالات الموت المفاجئ وحالات الاستسقاء في البطن وتوفير الكهرباء مع إطالة العمر التشغيلي للمصابيح .الدراسات الحديثة تؤكد على أن النظام الضوئي يعتبر مفتـاح النجاح في تربية السلالات الحديثة لفـروج اللحـم هذه السلالات تتمتع بسرعة نمو فائقة وذات كفاءة عالية في تحويل الغذاء',
                    ),
                    const TypeArticle(
                      type:
                          'يرتفع مستوى أنزيم الفوسفاتيز القاعدي في الليل ويعتبر هذا الأنزيم مهم في تطور الهيكل العظمي .دورة الظلام والضـوء سـتؤدي إلى زيـادة إفـراز هرمون ( الميلاثونين ) المهم في تطور الجهاز المناعي .تحسن نسبة التجانس تصبح الطيور متقاربة بالوزن ونسبة التجانس الجيدة هي 85% إذا انخفضت إلى 60% فتعتبر نسبة التجانس ضعيفة',
                    ),
                    const AdNativeWidget(),
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
                        children: controller.getRows(
                          darknessLevels,
                          context,
                          "الاظلام بالساعة",
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
