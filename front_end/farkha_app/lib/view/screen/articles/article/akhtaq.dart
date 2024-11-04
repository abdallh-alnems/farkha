import '../../../widget/ad/banner/ad_second_banner.dart';
import 'package:farkha_app/view/widget/follow_up_tools/articles/articles/arrow_back/arrow_back.dart';
import '../../../widget/follow_up_tools/articles/articles/text_article/type_article.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../widget/ad/banner/ad_third_banner.dart';

class Akhtaq extends StatelessWidget {
  const Akhtaq({super.key});

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
                          'تربية الفراخ البيضاء يمكن أن تكون صعبة ومليئة بالتحديات، والتي يمكن أن تؤدي إلى ارتكاب أخطاء قد تؤثر على صحة وسلامة الفراخ. إليك  أخطاء شائعة في تربية الفراخ البيضاء:',
                    ),
                    TypeArticle(
                      type:
                          'عدم توفير مساحة كافية للفراخ، مما يؤدي إلى الازدحام والإصابة بالأمراض.',
                    ),
                    TypeArticle(
                      type:
                          'تغذية الفراخ بغذاء غير مناسب أو غير متوازن، مما يؤدي إلى نمو غير صحي وضعف الجهاز المناعي.',
                    ),
                    TypeArticle(
                      type:
                          'عدم توفير مياه نظيفة وعذبة بشكل دائم، مما يؤدي إلى الجفاف والإصابة بالأمراض.',
                    ),
                    TypeArticle(
                      type:
                          'عدم توفير الإضاءة الطبيعية أو الاصطناعية اللازمة للفراخ، مما يؤدي إلى فقدان الرؤية والصحة العامة.',
                    ),
                    TypeArticle(
                      type:
                          'عدم توفير درجة حرارة مناسبة للفراخ، خاصة في الأشهر الأولى من حياتها، مما يؤدي إلى الإصابة بالبرد والأمراض الناتجة عنه.',
                    ),
                    TypeArticle(
                      type:
                          'عدم توفير تهوية مناسبة للمساحة المخصصة للفراخ، مما يؤدي إلى ارتفاع درجة الرطوبة وتراكم البكتيريا والأمراض.',
                    ),
                    TypeArticle(
                      type:
                          'عدم تنظيف المساحة المخصصة للفراخ بشكل منتظم، مما يؤدي إلى تراكم الروائح الكريهة والبكتيريا والأمراض.',
                    ),
                    TypeArticle(
                      type:
                          'عدم توفير الرعاية الصحية المناسبة للفراخ، مما يؤدي إلى الإصابة بالأمراض والإصابات والعدوى.',
                    ),
                    TypeArticle(
                      type:
                          'تجاهل علامات المرض وعدم اتخاذ الإجراءات اللازمة لعلاج الفراخ المصابة بالأمراض.',
                    ),
                    TypeArticle(
                      type:
                          'عدم توفير الأمان والحماية المناسبة للفراخ، مما يؤدي إلى الهروب والإصابة بالحيوانات المفترسة والطيور الجارحة.',
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
