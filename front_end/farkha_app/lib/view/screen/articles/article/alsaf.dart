import '../../../widget/ad/banner/ad_second_banner.dart';
import 'package:farkha_app/view/widget/follow_up_tools/articles/articles/arrow_back/arrow_back.dart';
import '../../../widget/follow_up_tools/articles/articles/text_article/type_article.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../widget/ad/banner/ad_third_banner.dart';

class Alsaf extends StatelessWidget {
  const Alsaf({super.key});

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
                  child: Column(children: [
                    TypeArticle(
                      type:
                          'تتطلب تربية الفراخ البيضاء في فصل الصيف اهتمامًا خاصًا بسبب الظروف الجوية الحارة والجافة التي يمكن أن تؤثر على صحة ونمو الفراخ. فيما يلي نقاط مهمة حول تربية الفراخ البيضاء في الصيف:',
                    ),
                    TypeArticle(
                      type:
                          '1- توفير الظل: يجب توفير مكان ذي ظل للفراخ حتى يتمكنوا من الاستراحة في الأوقات الحارة من النهار.',
                    ),
                    TypeArticle(
                      type:
                          '2- توفير الماء: يجب توفير كميات كافية من الماء النظيف للفراخ للحفاظ على ترطيب أجسادها وتجنب الجفاف، ويمكن إضافة بعض الثلج إلى الماء لتقليل درجة حرارته.',
                    ),
                    TypeArticle(
                      type:
                          '3- نظام التهوية: يجب توفير نظام تهوية فعال في بيئة تربية الفراخ لتقليل درجة حرارة الجو والحفاظ على مستوى الرطوبة المناسب، ويمكن استخدام المراوح أو النوافذ المفتوحة لتحسين التهوية.',
                    ),
                    TypeArticle(
                      type:
                          '4- الغذاء: يجب توفير الغذاء الصحي والمتوازن للفراخ، وينصح بتغذيتها في الأوقات الباردة من النهار لتجنب الإجهاد الحراري.',
                    ),
                    TypeArticle(
                      type:
                          '5- تنظيف البيئة: يجب تنظيف بيئة تربية الفراخ باستمرار لتجنب تراكم الروث والأوساخ التي قد تؤدي إلى زيادة درجة الحرارة وتفاقم الحالة الصحية للفراخ.',
                    ),
                    TypeArticle(
                      type:
                          '6- الحرص على الصحة: يجب مراقبة صحة الفراخ باستمرار واكتشاف أي علامات للمرض مثل الإسهال أو السعال أو التثاءب، والتدخل بسرعة عند الحاجة.',
                    ),
                    TypeArticle(
                      type:
                          '7- التحكم في درجة حرارة البيئة: يجب الحرص على توفير بيئة مناسبة للفراخ من حيث درجة الحرارة، ويمكن استخدام أجهزة تحكم في درجة الحرارة مثل المروحة أو التكييف لتحسين ظروف التربية.',
                    ),
                    TypeArticle(
                      type:
                          '8- توفير الإضاءة الصحيحة: يجب توفير نظام إضاءة صحيح لتربية الفراخ في الصيف، ويجب تجنب إضاءة شديدة السطوع التي يمكن أن تؤثر سلبًا على صحة الفراخ.',
                    ),
                    TypeArticle(
                      type:
                          '9- التحكم في كمية الطعام: يجب توفير كمية مناسبة من الطعام للفراخ وتجنب إطعامها بكميات زائدة، ويجب توزيع الطعام على فترات متعددة خلال اليوم.',
                    ),
                    TypeArticle(
                      type:
                          '10- مراقبة مستويات الرطوبة: يجب تجنب مستويات الرطوبة المرتفعة في بيئة تربية الفراخ، ويمكن استخدام أجهزة تحكم في مستويات الرطوبة مثل الضواغط لتحسين الظروف.',
                    ),
                  ]))
            ],
          ),
        ),
        bottomNavigationBar: AdThirdBanner(),
      ),
    );
  }
}
