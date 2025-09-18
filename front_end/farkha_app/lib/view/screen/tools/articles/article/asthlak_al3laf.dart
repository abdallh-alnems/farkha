import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../data/data_source/static/growth_parameters.dart';
import '../../../../../logic/controller/tools_controller/articles_controller.dart';
import '../../../../widget/ad/native.dart';
import '../../../../widget/app_bar/custom_app_bar.dart';
import '../../../../widget/ad/banner.dart';
import '../../../../widget/tools/articles/title_article.dart';
import '../../../../widget/tools/articles/type_article.dart';

class AsthlakAl3laf extends StatelessWidget {
  const AsthlakAl3laf({super.key});

  @override
  Widget build(BuildContext context) {
    final ArticlesController controller = Get.put(ArticlesController());

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: "استهلاك العلف"),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15).r,
                child: Column(
                  children: [
                    const TitleArticle(title: "نصائح في استهلاك العلف"),
                    const TypeArticle(
                      type:
                          '1 - العلف المتوازن: يجب توفير علف متوازن تغذيتيًا يحتوي على النسب المناسبة من البروتين والدهون والكربوهيدرات، ويجب تغذية الفراخ بكميات مناسبة وفقًا للعمر والوزن.',
                    ),
                    const TypeArticle(
                      type:
                          '2 - النوعية: يجب استخدام علف عالي الجودة والمصمم خصيصًا لتلبية احتياجات الفراخ البيضاء، ويجب تجنب استخدام العلف الفاسد أو الفاسد.',
                    ),
                    const TypeArticle(
                      type:
                          '3 - الماء: يجب توفير الماء النظيف والعذب بشكل دائم للفراخ، ويجب تغيير الماء بانتظام للحفاظ على نظافته، ويزيد استهلاك الفرخ للعلف بزيادة استخدامه للماء.',
                    ),
                    const TypeArticle(
                      type:
                          '4 - البيئة: يجب توفير بيئة مناسبة للفراخ تحتوي على درجة حرارة ورطوبة مناسبة، ويجب تجنب التعرض للإجهاد والضوضاء والاضطرابات في البيئة المحيطة بالفراخ.',
                    ),
                    const TypeArticle(
                      type:
                          '5 - المراقبة: يجب مراقبة استهلاك الفراخ للعلف وزيادة وزنها بشكل منتظم، وتعديل كمية العلف وفقًا للحاجة، ومراقبة الفراخ لأي أعراض للمرض أو الوفاة المفاجئة.',
                    ),
                    const AdNativeWidget(),
                    Text(
                      'ملحوظة : الفرخ الابيض  ياكل متوسط 3.5 كيلو علف طول الدورة',
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
                          feedConsumptions,
                          context,
                          "الاستهلاك بالجرام",
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
