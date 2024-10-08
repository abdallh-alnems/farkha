import 'package:farkha_app/view/widget/drawer/arrow_back/arrow_back.dart';
import 'package:farkha_app/view/widget/drawer/text_drawer/type_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import '../../widget/ad/banner/ad_all_banner.dart';

class Alshata extends StatelessWidget {
  const Alshata({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const ArrowBack(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TypeDrawer(
                        type:
                            'تربية الفراخ البيضاء في الشتاء يحتاج إلى اهتمام خاص بالظروف البيئية المتغيرة وتوفير بيئة مناسبة للفراخ للحفاظ على صحتها وتحقيق أقصى قدر من الإنتاجية. إليك بعض النقاط التي يمكن توسيعها في هذا الموضوع:'),
                    TypeDrawer(
                        type:
                            '1- توفير درجة حرارة مناسبة: يجب الحرص على توفير درجة حرارة مناسبة للفراخ في فصل الشتاء، ويمكن استخدام الأجهزة الحرارية مثل المدافئ والمراوح لتحقيق هذا الهدف.'),
                    TypeDrawer(
                        type:
                            '2- توفير إضاءة كافية: يجب توفير نظام إضاءة كافي لتربية الفراخ في فصل الشتاء، ويمكن استخدام المصابيح الكهربائية الخاصة بالفراخ لتحقيق هذا الهدف.'),
                    TypeDrawer(
                        type:
                            '3- توفير كمية مناسبة من الطعام: يجب توفير كمية مناسبة من الطعام للفراخ في فصل الشتاء وتجنب إطعامها بكميات زائدة. كما يجب توزيع الطعام على فترات متعددة خلال اليوم.'),
                    TypeDrawer(
                        type:
                            '4- مراقبة مستويات الرطوبة: يجب تجنب مستويات الرطوبة المرتفعة في بيئة تربية الفراخ في فصل الشتاء، ويمكن استخدام أجهزة تحكم في مستويات الرطوبة مثل الضواغط لتحسين الظروف.'),
                    TypeDrawer(
                        type:
                            '5- الحرص على نظام النوم: يجب توفير بيئة هادئة ومظلمة للفراخ للحصول على نوم جيد وتحسين صحتها.'),
                    TypeDrawer(
                        type:
                            '6- الحرص على صحة الفراخ: يجب مراقبة صحة الفراخ باستمرار وتحديد أي مشاكل صحية مبكرًا، ويمكن استشارة الطبيب البيطري في حالة الحاجة.'),
                    TypeDrawer(
                        type:
                            '7- توفير مساحة كافية: يجب توفير مساحة كافية للفراخ للتحرك والتمدد وتجنب التزاحم، ويمكن تخصيص مساحات خاصة للعب والتسلية.'),
                    TypeDrawer(
                        type:
                            '8- الاهتمام بنوعية الفراخ: يجب اختيار فراخ صحية وذات جودة عالية لضمان نمو صحي وإنتاجية جيدة.'),
                    TypeDrawer(
                        type:
                            '9- التدريب على التعرض لدرجات الحرارة الباردة: يمكن تدريب الفراخ على التعرض لدرجات الحرارة الباردة في فصل الشتاء عن طريق تعريضها لدرجات حرارة منخفضة تدريجياً.'),
                    TypeDrawer(
                        type:
                            '10- الاستعداد للطوارئ: يجب تحضير خطة لللتعامل مع الحوادث الطارئة مثل انقطاع التيار الكهربائي أو العواصف الثلجية، ويجب توفير مخزون كافي من الطعام والماء والأدوات الضرورية للتدخل السريع في حالة الحاجة.'),
                    TypeDrawer(
                        type:
                            'بشكل عام، يجب توفير بيئة صحية ومناسبة لتربية الفراخ البيضاء في فصل الشتاء، والحرص على توفير جميع الظروف اللازمة للحفاظ على صحتها وتحقيق أقصى قدر من الإنتاجية.'),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AdAllBanner(),
      ),
    );
  }
}
