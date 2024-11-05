import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widget/ad/native/ad_third_native.dart';
import '../../../widget/app_bar/custom_app_bar.dart';
import '../../../widget/follow_up_tools/articles/text_article/type_article.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import '../../../widget/ad/banner/ad_second_banner.dart';
import '../../../widget/ad/banner/ad_third_banner.dart';

class Alshata extends StatelessWidget {
  const Alshata({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            text: "الشتاء",
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15).r,
                child: Column(
                  children: [
                    TypeArticle(
                        type:
                            'تربية الفراخ البيضاء في الشتاء يحتاج إلى اهتمام خاص بالظروف البيئية المتغيرة وتوفير بيئة مناسبة للفراخ للحفاظ على صحتها وتحقيق أقصى قدر من الإنتاجية. إليك بعض النقاط التي يمكن توسيعها في هذا الموضوع:'),
                    AdThirdNative(),
                    TypeArticle(
                        type:
                            '1- توفير درجة حرارة مناسبة: يجب الحرص على توفير درجة حرارة مناسبة للفراخ في فصل الشتاء، ويمكن استخدام الأجهزة الحرارية مثل المدافئ والمراوح لتحقيق هذا الهدف.'),
                    TypeArticle(
                        type:
                            '2- توفير إضاءة كافية: يجب توفير نظام إضاءة كافي لتربية الفراخ في فصل الشتاء، ويمكن استخدام المصابيح الكهربائية الخاصة بالفراخ لتحقيق هذا الهدف.'),
                    TypeArticle(
                        type:
                            '3- توفير كمية مناسبة من الطعام: يجب توفير كمية مناسبة من الطعام للفراخ في فصل الشتاء وتجنب إطعامها بكميات زائدة. كما يجب توزيع الطعام على فترات متعددة خلال اليوم.'),
                    TypeArticle(
                        type:
                            '4- مراقبة مستويات الرطوبة: يجب تجنب مستويات الرطوبة المرتفعة في بيئة تربية الفراخ في فصل الشتاء، ويمكن استخدام أجهزة تحكم في مستويات الرطوبة مثل الضواغط لتحسين الظروف.'),
                    TypeArticle(
                        type:
                            '5- الحرص على نظام النوم: يجب توفير بيئة هادئة ومظلمة للفراخ للحصول على نوم جيد وتحسين صحتها.'),
                    TypeArticle(
                        type:
                            '6- الحرص على صحة الفراخ: يجب مراقبة صحة الفراخ باستمرار وتحديد أي مشاكل صحية مبكرًا، ويمكن استشارة الطبيب البيطري في حالة الحاجة.'),
                    TypeArticle(
                        type:
                            '7- توفير مساحة كافية: يجب توفير مساحة كافية للفراخ للتحرك والتمدد وتجنب التزاحم، ويمكن تخصيص مساحات خاصة للعب والتسلية.'),
                    TypeArticle(
                        type:
                            '8- الاهتمام بنوعية الفراخ: يجب اختيار فراخ صحية وذات جودة عالية لضمان نمو صحي وإنتاجية جيدة.'),
                    TypeArticle(
                        type:
                            '9- التدريب على التعرض لدرجات الحرارة الباردة: يمكن تدريب الفراخ على التعرض لدرجات الحرارة الباردة في فصل الشتاء عن طريق تعريضها لدرجات حرارة منخفضة تدريجياً.'),
                    TypeArticle(
                        type:
                            '10- الاستعداد للطوارئ: يجب تحضير خطة لللتعامل مع الحوادث الطارئة مثل انقطاع التيار الكهربائي أو العواصف الثلجية، ويجب توفير مخزون كافي من الطعام والماء والأدوات الضرورية للتدخل السريع في حالة الحاجة.'),
                    TypeArticle(
                        type:
                            'بشكل عام، يجب توفير بيئة صحية ومناسبة لتربية الفراخ البيضاء في فصل الشتاء، والحرص على توفير جميع الظروف اللازمة للحفاظ على صحتها وتحقيق أقصى قدر من الإنتاجية.'),
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