import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widget/ad/native/ad_third_native.dart';
import '../../../widget/app_bar/custom_app_bar.dart';
import '../../../widget/follow_up_tools/articles/text_article/type_article.dart';
import 'package:flutter/material.dart';
import '../../../widget/ad/banner/ad_third_banner.dart';

class Akhtaq extends StatelessWidget {
  const Akhtaq({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(
            text: "اخطاء",
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15).r,
                child: const Column(children: [
                  TypeArticle(
                    type:
                        'تربية الفراخ البيضاء يمكن أن تكون صعبة ومليئة بالتحديات، والتي يمكن أن تؤدي إلى ارتكاب أخطاء قد تؤثر على صحة وسلامة الفراخ. إليك  أخطاء شائعة في تربية الفراخ البيضاء :',
                  ),
                  AdThirdNative(),
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
                ]),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdThirdBanner(),
    );
  }
}
