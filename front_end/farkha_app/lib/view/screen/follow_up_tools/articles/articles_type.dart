import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constant/routes/route.dart';
import '../../../../core/shared/card_title.dart';
import '../../../widget/app/ad/banner/banner.dart';
import '../../../widget/app/ad/native/ad_second_native.dart';
import '../../../widget/app/app_bar/custom_app_bar.dart';

class ArticlesType extends StatelessWidget {
  const ArticlesType({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(text: "مقالات"),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 19).r,
                    child: AdSecondNative(),
                  ),
                  CardTitle(
                    text: "درجات الحرارة",
                    onTap: () => Get.toNamed(AppRoute.dartgetAl7rara),
                  ),
                  CardTitle(
                    text: "اوزان",
                    onTap: () => Get.toNamed(AppRoute.awzan),
                  ),
                  CardTitle(
                    text: "الاضاءة",
                    onTap: () => Get.toNamed(AppRoute.alida),
                  ),
                  CardTitle(
                    text: "استهلاك العلف",
                    onTap: () => Get.toNamed(AppRoute.asthlakAl3laf),
                  ),
                  CardTitle(
                    text: "تجانس الاوزان",
                    onTap: () => Get.toNamed(AppRoute.altaganous),
                  ),
                  CardTitle(
                    text: "الرطوبة",
                    onTap: () => Get.toNamed(AppRoute.alrotoba),
                  ),
                  CardTitle(
                    text: "امراض",
                    onTap: () => Get.toNamed(AppRoute.amard),
                  ),
                  CardTitle(
                    text: "اعراض",
                    onTap: () => Get.toNamed(AppRoute.a3ard),
                  ),
                  CardTitle(
                    text: "علاج",
                    onTap: () => Get.toNamed(AppRoute.aL3lag),
                  ),
                  CardTitle(
                    text: "نصائح",
                    onTap: () => Get.toNamed(AppRoute.nasa7a),
                  ),
                  CardTitle(
                    text: "اخطاء",
                    onTap: () => Get.toNamed(AppRoute.akhtaq),
                  ),
                  CardTitle(
                    text: "تطهير",
                    onTap: () => Get.toNamed(AppRoute.tather),
                  ),
                  CardTitle(
                    text: "استقبال",
                    onTap: () => Get.toNamed(AppRoute.astaqbal),
                  ),
                  CardTitle(
                    text: "تحصينات",
                    onTap: () => Get.toNamed(AppRoute.ta7sen),
                  ),
                  CardTitle(
                    text: "سلالات",
                    onTap: () => Get.toNamed(AppRoute.solalat),
                  ),
                  CardTitle(
                    text: "الارضية",
                    onTap: () => Get.toNamed(AppRoute.alardya),
                  ),
                  CardTitle(
                    text: "الصيف",
                    onTap: () => Get.toNamed(AppRoute.alsaf),
                  ),
                  CardTitle(
                    text: "الشتاء",
                    onTap: () => Get.toNamed(AppRoute.alshata),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(adIndex: 1),
    );
  }
}
