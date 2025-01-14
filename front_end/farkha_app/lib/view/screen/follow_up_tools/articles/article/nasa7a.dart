import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../widget/app/ad/native/ad_third_native.dart';
import '../../../../widget/bar/app_bar/custom_app_bar.dart';
import '../../../../widget/follow_up_tools/articles/type_article.dart';
import 'package:flutter/material.dart';
import '../../../../widget/app/ad/banner/ad_third_banner.dart';

class Nasa7a extends StatelessWidget {
  const Nasa7a({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: "نصائح"),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15).r,
                child: const Column(children: [
                  TypeArticle(
                    type:
                        'إذا كنت تخطط لتربية الفراخ البيضاء، فإليك بعض النصائح يمكن أن تفيدك في هذا الصدد:',
                  ),
                  AdThirdNative(),
                  TypeArticle(
                    type:
                        'اختر مكانًا مناسبًا لتربية الفراخ البيضاء، يفضل أن يكون مكانًا نظيفًا وجافًا ومحميًا من الرياح والأمطار.',
                  ),
                  TypeArticle(
                    type:
                        'استخدم تغذية متوازنة ومناسبة للفراخ البيضاء، وتأكد من أنها تحتوي على جميع العناصر الغذائية اللازمة لها.',
                  ),
                  TypeArticle(
                    type:
                        'يجب توفير مياه نظيفة وعذبة طوال الوقت، ويجب تغييرها بشكل مستمر للحفاظ على نظافة الفراخ وصحتها.',
                  ),
                  TypeArticle(
                    type:
                        'توفر للفراخ مساحة كافية للحركة والتمدد والتحرك، وحاول تجنب الازدحام الزائد في المساحة المخصصة لها.',
                  ),
                  TypeArticle(
                    type:
                        'تأكد من توفير درجة حرارة مناسبة للفراخ، خاصة في الأشهر الأولى من حياتها، وتأكد من توفير درجة حرارة معتدلة في الأشهر اللاحقة.',
                  ),
                  TypeArticle(
                    type:
                        'يجب توفير إضاءة مناسبة للفراخ، وخاصة الإضاءة الطبيعية، ويفضل توفير الإضاءة الاصطناعية في الأشهر القليلة الإضاءة الطبيعية.',
                  ),
                  TypeArticle(
                    type:
                        'يجب تنظيف المساحة المخصصة للفراخ بشكل منتظم للحفاظ على نظافتها وصحة الفراخ.',
                  ),
                  TypeArticle(
                    type:
                        'تأكد من توفير تهوية مناسبة للمساحة المخصصة للفراخ، وذلك لتوفير الأكسجين اللازم لها وللحد من انتشار البكتيريا والأمراض.',
                  ),
                  TypeArticle(
                    type:
                        'تأكد من توفير الرعاية الصحية المناسبة للفراخ البيضاء، وخاصة تطعيماتها وعلاجها من الأمراض والإصابات.',
                  ),
                  TypeArticle(
                    type:
                        'تأكد من توفير الأمان والحماية المناسبة للفراخ، وخاصة من الحيوانات المفترسة والطيور الجارحة، وتأكد من توفير شبكة أمان حول المساحة المخصصة للفراخ.',
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
