import 'package:farkha_app/core/constant/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widget/ad/banner/ad_second_banner.dart';
import '../../widget/ad/native/ad_second_native.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/follow_up_tools/articles/article_title.dart';

class ArticlesType extends StatelessWidget {
  const ArticlesType({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            text: "مقالات",
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 19).r,
                    child: AdSecondNative(),
                  ),
                  ArticleTitle(
                    text: "درجات الحرارة",
                    onTap: () => Get.toNamed(AppRoute.dartgetAl7rara),
                  ),
                  ArticleTitle(
                    text: "اوزان",
                    onTap: () => Get.toNamed(AppRoute.awzan),
                  ),
                  ArticleTitle(
                    text: "الاضاءة",
                    onTap: () => Get.toNamed(AppRoute.alida),
                  ),
                  ArticleTitle(
                    text: "استهلاك العلف",
                    onTap: () => Get.toNamed(AppRoute.asthlak),
                  ),
                  ArticleTitle(
                    text: "التجانس",
                    onTap: () => Get.toNamed(AppRoute.altaganous),
                  ),
                  ArticleTitle(
                    text: "الرطوبة",
                    onTap: () => Get.toNamed(AppRoute.alrotoba),
                  ),
                  ArticleTitle(
                    text: "امراض",
                    onTap: () => Get.toNamed(AppRoute.amard),
                  ),
                  ArticleTitle(
                    text: "اعراض",
                    onTap: () => Get.toNamed(AppRoute.a3ard),
                  ),
                  ArticleTitle(
                    text: "علاج",
                    onTap: () => Get.toNamed(AppRoute.aL3lag),
                  ),
                  ArticleTitle(
                    text: "نصائح",
                    onTap: () => Get.toNamed(AppRoute.nasa7a),
                  ),
                  ArticleTitle(
                    text: "اخطاء",
                    onTap: () => Get.toNamed(AppRoute.akhtaq),
                  ),
                  ArticleTitle(
                    text: "تطهير",
                    onTap: () => Get.toNamed(AppRoute.tather),
                  ),
                  ArticleTitle(
                    text: "استقبال",
                    onTap: () => Get.toNamed(AppRoute.astaqbal),
                  ),
                  ArticleTitle(
                    text: "تحصينات",
                    onTap: () => Get.toNamed(AppRoute.ta7sen),
                  ),
                  ArticleTitle(
                    text: "سلالات",
                    onTap: () => Get.toNamed(AppRoute.solalat),
                  ),
                  ArticleTitle(
                    text: "الارضية",
                    onTap: () => Get.toNamed(AppRoute.alardya),
                  ),
                  ArticleTitle(
                    text: "الصيف",
                    onTap: () => Get.toNamed(AppRoute.alsaf),
                  ),
                  ArticleTitle(
                    text: "الشتاء",
                    onTap: () => Get.toNamed(AppRoute.alshata),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdSecondBanner(),
    );
  }
}
