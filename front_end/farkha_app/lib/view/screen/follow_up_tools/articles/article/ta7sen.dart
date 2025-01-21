import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../widget/app/ad/native/ad_third_native.dart';
import '../../../../widget/app/app_bar/custom_app_bar.dart';
import '../../../../widget/app/follow_up_tools/articles/type_article.dart';
import 'package:flutter/material.dart';
import '../../../../widget/app/ad/banner/ad_third_banner.dart';

class Ta7sen extends StatelessWidget {
  const Ta7sen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: "تحصينات"),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15).r,
                child: const Column(children: [
                  TypeArticle(
                    type:
                        'يتم تحصين الفراخ خلال الدورة ضد الأمراض الفيروسة مثل الجامبرو والنيوكاسل والأى بي فقط فهذه التحصينات عبارة عن فيروسات المرض يتم اعطاؤها للطائر لتكسبه مناعة ضد المرض لتلافي الاصابه به عند انتشار العدوى ويجود 3 تحصينات هامة ل 3 أمراض ويتم اعطاؤها كالتالي:',
                  ),
                  AdThirdNative(),
                  TypeArticle(
                    type: 'عمر سبعة أيام يتم تحصين نيوكاسل أما هتشنر أو كلون .',
                  ),
                  TypeArticle(
                    type:
                        'أحيانا يتم تحصين انفلونزا ميت مع النيوكاسل ويكون حقن والنيوكاسل تقطير',
                  ),
                  TypeArticle(
                    type: 'عمر 12 يوم نقوم بتحصين ضد الجمبورو عترة متوسطة',
                  ),
                  TypeArticle(
                    type:
                        'عمر 18 يوم يتم التحصين مرة أخرى ضد النيوكاسل مع اضافة تحصين ضد مرض الأى بي ',
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
