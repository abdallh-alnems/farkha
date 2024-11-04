import 'package:farkha_app/core/constant/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/image_asset.dart';
import '../../../core/shared/custom_divider.dart';
import '../../../core/shared/card/big_card.dart';

class ViewHomeFollowUpTools extends StatelessWidget {
  const ViewHomeFollowUpTools({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomDivider(
          text: "ادوات مساعدة",
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BigCard(
                onTap: () {},
                image: AppImageAsset.poultrySale,
                text: "بيع الدواجن",
              ),
              BigCard(
                onTap: () {},
                image: AppImageAsset.chicken,
                text: "احتياجات فراخ التسمين",
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BigCard(
              onTap: () {},
              image: AppImageAsset.diseases,
              text: "الامراض",
            ),
            BigCard(
              onTap: () => Get.toNamed(AppRoute.articlesType),
              image: AppImageAsset.articles,
              text: "مقالات",
            ),
          ],
        ),
      ],
    );
  }
}
