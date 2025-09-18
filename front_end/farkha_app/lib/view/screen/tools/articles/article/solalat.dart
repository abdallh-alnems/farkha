import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../widget/ad/native.dart';
import '../../../../widget/app_bar/custom_app_bar.dart';
import '../../../../widget/tools/articles/title_article.dart';
import '../../../../widget/tools/articles/type_article.dart';
import 'package:flutter/material.dart';
import '../../../../widget/ad/banner.dart';

class Solalat extends StatelessWidget {
  const Solalat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: "سلالات"),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15).r,
                child: const Column(
                  children: [
                    TypeArticle(
                      type:
                          'تعتبر تربية الفراخ البيضاء أحد الأنشطة الزراعية الرئيسية في مصر، حيث تمتلك البلاد الإمكانيات الطبيعية والبشرية المناسبة لتحقيق هذا النوع من الإنتاج الداجني. وتتوفر في مصر عدة سلالات من الفراخ البيضاء والتي تختلف في مجالات مثل النمو الإنتاجية وجودة اللحم والبيض وفيما يلي نلقي نظرة على بعض السلالات الأكثر شيوعًا في مصر:',
                    ),
                    AdNativeWidget(),
                    TitleArticle(title: 'سلالة روس البيضاء (الاشهر)'),
                    TypeArticle(
                      type:
                          'تعدّ هذه السلالة من أشهر سلالات الفراخ البيضاء في مصر، وهي ذات جودة عالية في الإنتاجية وسرعة النمو. وتصل وزن الفرخ من هذه السلالة إلى المستوى المطلوب، ما يجعلها مناسبة جدًا لتربية الدواجن للحصول على اللحوم البيضاء. ',
                    ),
                    TitleArticle(title: 'سلالة كوب'),
                    TypeArticle(
                      type:
                          'تمتلك سلالة كوب خصائص مماثلة لسلالة هبارد، حيث يمكن تربيتها في ظروف صعبة، وهي تنتج كمية كبيرة من  واللحم. وتمتلك هذه السلالة نسبة عالية من الأحماض الأمينية الضرورية للجسم البشري، مما يجعلها مفضلة للأشخاص الذين يهتمون بالصحة.',
                    ),
                    TitleArticle(title: 'سلالة هاي لاين'),
                    TypeArticle(
                      type:
                          'تعتبر سلالة هاي لاين من السلالات الأكثر شهرة في العالم، وهي مستوردة من الدول الأوروبية. وتمتاز بنمو سريع وإنتاجية عالية في اللحم  وتستخدم بشكل واسع في مصر لإنتاج اللحم الابيض .',
                    ),
                    TitleArticle(title: 'سلالة كوب 500'),
                    TypeArticle(
                      type:
                          'تمثل سلالة كوب 500 من السلالات الحديثة التي تم تدشينها في مصر، وهي تعتبر من السلالات الهجينة التي تتميز بإنتاجية عالية في اللحم . وتتميز هذه السلالة بقدرتها على التحمل في ظروف المناخ الصعبة، وتعتبر مثالية للمزارعين الذين يرغبون في تحقيق الأرباح العالية.',
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
