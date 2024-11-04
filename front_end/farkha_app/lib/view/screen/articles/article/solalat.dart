import 'package:farkha_app/view/widget/follow_up_tools/articles/articles/arrow_back/arrow_back.dart';
import 'package:farkha_app/view/widget/follow_up_tools/articles/articles/divider_drawer.dart';
import 'package:farkha_app/view/widget/follow_up_tools/articles/articles/text_article/title_article.dart';
import '../../../widget/follow_up_tools/articles/articles/text_article/type_article.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import '../../../widget/ad/banner/ad_second_banner.dart';
import '../../../widget/ad/banner/ad_third_banner.dart';

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
                    TypeArticle(
                      type:
                          'تعتبر تربية الفراخ البيضاء أحد الأنشطة الزراعية الرئيسية في مصر، حيث تمتلك البلاد الإمكانيات الطبيعية والبشرية المناسبة لتحقيق هذا النوع من الإنتاج الداجني. وتتوفر في مصر عدة سلالات من الفراخ البيضاء، والتي تختلف في مجالات مثل النمو، الإنتاجية، وجودة اللحم والبيض  \n وفيما يلي نلقي نظرة على بعض السلالات الأكثر شيوعًا في مصر:.',
                    ),
                    const TitleArticle(title: 'سلالة روس البيضاء (الاشهر)'),
                    TypeArticle(
                      type:
                          'تعدّ هذه السلالة من أشهر سلالات الفراخ البيضاء في مصر، وهي ذات جودة عالية في الإنتاجية وسرعة النمو. وتصل وزن الفرخ من هذه السلالة إلى المستوى المطلوب، ما يجعلها مناسبة جدًا لتربية الدواجن للحصول على اللحوم البيضاء. ',
                    ),
                    const DividerDrawer(),
                    const TitleArticle(title: 'سلالة كوب'),
                    TypeArticle(
                      type:
                          'تمتلك سلالة كوب خصائص مماثلة لسلالة هبارد، حيث يمكن تربيتها في ظروف صعبة، وهي تنتج كمية كبيرة من  واللحم. وتمتلك هذه السلالة نسبة عالية من الأحماض الأمينية الضرورية للجسم البشري، مما يجعلها مفضلة للأشخاص الذين يهتمون بالصحة.',
                    ),
                    const DividerDrawer(),
                    const TitleArticle(title: 'سلالة هاي لاين'),
                    TypeArticle(
                      type:
                          'تعتبر سلالة هاي لاين من السلالات الأكثر شهرة في العالم، وهي مستوردة من الدول الأوروبية. وتمتاز بنمو سريع وإنتاجية عالية في اللحم  وتستخدم بشكل واسع في مصر لإنتاج اللحم الابيض .',
                    ),
                    const DividerDrawer(),
                    const TitleArticle(title: 'سلالة كوب 500'),
                    TypeArticle(
                      type:
                          'تمثل سلالة كوب 500 من السلالات الحديثة التي تم تدشينها في مصر، وهي تعتبر من السلالات الهجينة التي تتميز بإنتاجية عالية في اللحم . وتتميز هذه السلالة بقدرتها على التحمل في ظروف المناخ الصعبة، وتعتبر مثالية للمزارعين الذين يرغبون في تحقيق الأرباح العالية.',
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
