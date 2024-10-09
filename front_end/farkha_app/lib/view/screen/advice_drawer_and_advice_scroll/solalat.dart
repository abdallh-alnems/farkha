import 'package:farkha_app/view/widget/drawer/arrow_back/arrow_back.dart';
import 'package:farkha_app/view/widget/drawer/divider_drawer.dart';
import 'package:farkha_app/view/widget/drawer/text_drawer/title_drawer.dart';
import 'package:farkha_app/view/widget/drawer/text_drawer/type_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import '../../widget/ad/banner/ad_all_banner.dart';

class Solalat extends StatelessWidget {
  const Solalat({super.key});

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
                    TypeDrawer(
                      type:
                          'تعتبر تربية الفراخ البيضاء أحد الأنشطة الزراعية الرئيسية في مصر، حيث تمتلك البلاد الإمكانيات الطبيعية والبشرية المناسبة لتحقيق هذا النوع من الإنتاج الداجني. وتتوفر في مصر عدة سلالات من الفراخ البيضاء، والتي تختلف في مجالات مثل النمو، الإنتاجية، وجودة اللحم والبيض  \n وفيما يلي نلقي نظرة على بعض السلالات الأكثر شيوعًا في مصر:.',
                    ),
                    const TitleDrawer(title: 'سلالة روس البيضاء (الاشهر)'),
                    TypeDrawer(
                      type:
                          'تعدّ هذه السلالة من أشهر سلالات الفراخ البيضاء في مصر، وهي ذات جودة عالية في الإنتاجية وسرعة النمو. وتصل وزن الفرخ من هذه السلالة إلى المستوى المطلوب، ما يجعلها مناسبة جدًا لتربية الدواجن للحصول على اللحوم البيضاء. ',
                    ),
                    const DividerDrawer(),
                    const TitleDrawer(title: 'سلالة كوب'),
                    TypeDrawer(
                      type:
                          'تمتلك سلالة كوب خصائص مماثلة لسلالة هبارد، حيث يمكن تربيتها في ظروف صعبة، وهي تنتج كمية كبيرة من  واللحم. وتمتلك هذه السلالة نسبة عالية من الأحماض الأمينية الضرورية للجسم البشري، مما يجعلها مفضلة للأشخاص الذين يهتمون بالصحة.',
                    ),
                    const DividerDrawer(),
                    const TitleDrawer(title: 'سلالة هاي لاين'),
                    TypeDrawer(
                      type:
                          'تعتبر سلالة هاي لاين من السلالات الأكثر شهرة في العالم، وهي مستوردة من الدول الأوروبية. وتمتاز بنمو سريع وإنتاجية عالية في اللحم  وتستخدم بشكل واسع في مصر لإنتاج اللحم الابيض .',
                    ),
                    const DividerDrawer(),
                    const TitleDrawer(title: 'سلالة كوب 500'),
                    TypeDrawer(
                      type:
                          'تمثل سلالة كوب 500 من السلالات الحديثة التي تم تدشينها في مصر، وهي تعتبر من السلالات الهجينة التي تتميز بإنتاجية عالية في اللحم . وتتميز هذه السلالة بقدرتها على التحمل في ظروف المناخ الصعبة، وتعتبر مثالية للمزارعين الذين يرغبون في تحقيق الأرباح العالية.',
                    ),
                  ]))
            ],
          ),
        ),
        bottomNavigationBar: AdAllBanner(),
      ),
    );
  }
}
