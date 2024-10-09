import '../../widget/ad/banner/ad_all_banner.dart';
import 'package:farkha_app/view/widget/drawer/arrow_back/arrow_back.dart';
import 'package:farkha_app/view/widget/drawer/text_drawer/type_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
                    TypeDrawer(
                      type:
                          'تربية الفراخ البيضاء يمكن أن تكون صعبة ومليئة بالتحديات، والتي يمكن أن تؤدي إلى ارتكاب أخطاء قد تؤثر على صحة وسلامة الفراخ. إليك  أخطاء شائعة في تربية الفراخ البيضاء:',
                    ),
                    TypeDrawer(
                      type:
                          'عدم توفير مساحة كافية للفراخ، مما يؤدي إلى الازدحام والإصابة بالأمراض.',
                    ),
                    TypeDrawer(
                      type:
                          'تغذية الفراخ بغذاء غير مناسب أو غير متوازن، مما يؤدي إلى نمو غير صحي وضعف الجهاز المناعي.',
                    ),
                    TypeDrawer(
                      type:
                          'عدم توفير مياه نظيفة وعذبة بشكل دائم، مما يؤدي إلى الجفاف والإصابة بالأمراض.',
                    ),
                    TypeDrawer(
                      type:
                          'عدم توفير الإضاءة الطبيعية أو الاصطناعية اللازمة للفراخ، مما يؤدي إلى فقدان الرؤية والصحة العامة.',
                    ),
                    TypeDrawer(
                      type:
                          'عدم توفير درجة حرارة مناسبة للفراخ، خاصة في الأشهر الأولى من حياتها، مما يؤدي إلى الإصابة بالبرد والأمراض الناتجة عنه.',
                    ),
                    TypeDrawer(
                      type:
                          'عدم توفير تهوية مناسبة للمساحة المخصصة للفراخ، مما يؤدي إلى ارتفاع درجة الرطوبة وتراكم البكتيريا والأمراض.',
                    ),
                    TypeDrawer(
                      type:
                          'عدم تنظيف المساحة المخصصة للفراخ بشكل منتظم، مما يؤدي إلى تراكم الروائح الكريهة والبكتيريا والأمراض.',
                    ),
                    TypeDrawer(
                      type:
                          'عدم توفير الرعاية الصحية المناسبة للفراخ، مما يؤدي إلى الإصابة بالأمراض والإصابات والعدوى.',
                    ),
                    TypeDrawer(
                      type:
                          'تجاهل علامات المرض وعدم اتخاذ الإجراءات اللازمة لعلاج الفراخ المصابة بالأمراض.',
                    ),
                    TypeDrawer(
                      type:
                          'عدم توفير الأمان والحماية المناسبة للفراخ، مما يؤدي إلى الهروب والإصابة بالحيوانات المفترسة والطيور الجارحة.',
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
