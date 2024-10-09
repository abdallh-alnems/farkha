import 'package:farkha_app/view/widget/drawer/arrow_back/arrow_back.dart';
import 'package:farkha_app/view/widget/drawer/text_drawer/type_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import '../../widget/ad/banner/ad_all_banner.dart';

class Ta7sen extends StatelessWidget {
  const Ta7sen({super.key});

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
                          'يتم تحصين الفراخ خلال الدورة ضد الأمراض الفيروسة مثل الجامبرو والنيوكاسل والأى بي فقط فهذه التحصينات عبارة عن فيروسات المرض يتم اعطاؤها للطائر لتكسبه مناعة ضد المرض لتلافي الاصابه به عند انتشار العدوى ويجود 3 تحصينات هامة ل 3 أمراض ويتم اعطاؤها كالتالي:',
                    ),
                    TypeDrawer(
                      type:
                          'عمر سبعة أيام يتم تحصين نيوكاسل أما هتشنر أو كلون .',
                    ),
                    TypeDrawer(
                      type:
                          'أحيانا يتم تحصين انفلونزا ميت مع النيوكاسل ويكون حقن والنيوكاسل تقطير',
                    ),
                    TypeDrawer(
                      type: 'عمر 12 يوم نقوم بتحصين ضد الجمبورو عترة متوسطة',
                    ),
                    TypeDrawer(
                      type:
                          'عمر 18 يوم يتم التحصين مرة أخرى ضد النيوكاسل مع اضافة تحصين ضد مرض الأى بي ',
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
