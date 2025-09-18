import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constant/routes/route.dart';
import '../../../../core/shared/card_title.dart';
import '../../../widget/ad/banner.dart';
import '../../../widget/ad/native.dart';
import '../../../widget/app_bar/custom_app_bar.dart';

class ArticlesType extends StatelessWidget {
  const ArticlesType({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: 'مقالات'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 11),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 19).r,
                    child: const AdNativeWidget(),
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
                    text: "الاظلام",
                    onTap: () => Get.toNamed(AppRoute.alzlam),
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
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
