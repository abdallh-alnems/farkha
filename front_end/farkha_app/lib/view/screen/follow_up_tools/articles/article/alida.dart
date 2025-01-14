import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../data/data_source/static/poultry_management_data.dart';
import '../../../../../logic/controller/articles_controller.dart';
import '../../../../widget/app/ad/native/ad_third_native.dart';
import '../../../../widget/bar/app_bar/custom_app_bar.dart';
import '../../../../widget/follow_up_tools/articles/title_article.dart';
import '../../../../widget/follow_up_tools/articles/type_article.dart';
import '../../../../widget/app/ad/banner/ad_third_banner.dart';

class Alida extends StatelessWidget {
  const Alida({super.key});

  @override
  Widget build(BuildContext context) {
    final ArticlesController controller = Get.put(ArticlesController());

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(text: "الاضاءة"),
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
      bottomNavigationBar: AdThirdBanner(),
    );
  }
}
