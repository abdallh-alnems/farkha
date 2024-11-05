import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widget/ad/native/ad_third_native.dart';
import '../../../widget/app_bar/custom_app_bar.dart';
import '../../../widget/follow_up_tools/articles/text_article/type_article.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import '../../../widget/ad/banner/ad_second_banner.dart';
import '../../../widget/ad/banner/ad_third_banner.dart';

class Altaganous extends StatelessWidget {
  const Altaganous({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            text: "تجانس الاوزان",
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15).r,
                child: Column(
                  children: [
                    TypeArticle(
                        type:
                            'تربية الفراخ البيضاء في التجانس في الأحجام هو عملية تحقيق توازن مثالي في الحجم بين الفراخ المختلفة في المزرعة وهو يعتبر عاملاً هاماً في تحقيق الإنتاجية والأرباح المرتبطة بتربية الفراخ. إليك بعض النقاط التي يمكن تطبيقها في هذا الموضوع :'),
                    AdThirdNative(),
                    TypeArticle(
                        type:
                            '1- التحكم في وزن الفراخ: يجب مراقبة وزن الفراخ بشكل دوري وتقييم أحجامها، ويمكن استخدام أدوات الوزن الخاصة بالفراخ لتحقيق ذلك.'),
                    TypeArticle(
                        type:
                            '2- الاهتمام بمستوى التغذية: يجب توفير كمية كافية من الطعام والمياه النظيفة والصحية للفراخ، وذلك لتحقيق نمو متساوٍ بين الفراخ.'),
                    TypeArticle(
                        type:
                            '3- توفير مساحة كافية: يجب توفير مساحة كافية للفراخ للتحرك والتمدد وتجنب التزاحم، ويمكن تخصيص مساحات خاصة للعب والتسلية.'),
                    TypeArticle(
                        type:
                            '4- الاهتمام بنوعية الفراخ: يجب اختيار فراخ صحية وذات جودة عالية لضمان نمو صحي وإنتاجية جيدة، ويمكن الحصول على الفراخ ذات الحجم المتجانس عن طريق اختيار نوعيات فراخ معينة ذات خصائص وراثية متجانسة.'),
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
