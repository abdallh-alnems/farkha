import 'package:farkha_app/view/widget/drawer/arrow_back/arrow_back.dart';
import 'package:farkha_app/view/widget/drawer/text_drawer/type_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import '../../widget/ad/banner/ad_all_banner.dart';

class Nasa7a extends StatelessWidget {
  const Nasa7a({super.key});

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
                          'إذا كنت تخطط لتربية الفراخ البيضاء، فإليك عشر نصائح يمكن أن تفيدك في هذا الصدد:',
                    ),
                    TypeDrawer(
                      type:
                          'اختر مكانًا مناسبًا لتربية الفراخ البيضاء، يفضل أن يكون مكانًا نظيفًا وجافًا ومحميًا من الرياح والأمطار.',
                    ),
                    TypeDrawer(
                      type:
                          'استخدم تغذية متوازنة ومناسبة للفراخ البيضاء، وتأكد من أنها تحتوي على جميع العناصر الغذائية اللازمة لها.',
                    ),
                    TypeDrawer(
                      type:
                          'يجب توفير مياه نظيفة وعذبة طوال الوقت، ويجب تغييرها بشكل مستمر للحفاظ على نظافة الفراخ وصحتها.',
                    ),
                    TypeDrawer(
                      type:
                          'توفر للفراخ مساحة كافية للحركة والتمدد والتحرك، وحاول تجنب الازدحام الزائد في المساحة المخصصة لها.',
                    ),
                    TypeDrawer(
                      type:
                          'تأكد من توفير درجة حرارة مناسبة للفراخ، خاصة في الأشهر الأولى من حياتها، وتأكد من توفير درجة حرارة معتدلة في الأشهر اللاحقة.',
                    ),
                    TypeDrawer(
                      type:
                          'يجب توفير إضاءة مناسبة للفراخ، وخاصة الإضاءة الطبيعية، ويفضل توفير الإضاءة الاصطناعية في الأشهر القليلة الإضاءة الطبيعية.',
                    ),
                    TypeDrawer(
                      type:
                          'يجب تنظيف المساحة المخصصة للفراخ بشكل منتظم للحفاظ على نظافتها وصحة الفراخ.',
                    ),
                    TypeDrawer(
                      type:
                          'تأكد من توفير تهوية مناسبة للمساحة المخصصة للفراخ، وذلك لتوفير الأكسجين اللازم لها وللحد من انتشار البكتيريا والأمراض.',
                    ),
                    TypeDrawer(
                      type:
                          'تأكد من توفير الرعاية الصحية المناسبة للفراخ البيضاء، وخاصة تطعيماتها وعلاجها من الأمراض والإصابات.',
                    ),
                    TypeDrawer(
                      type:
                          'تأكد من توفير الأمان والحماية المناسبة للفراخ، وخاصة من الحيوانات المفترسة والطيور الجارحة، وتأكد من توفير شبكة أمان حول المساحة المخصصة للفراخ.',
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
