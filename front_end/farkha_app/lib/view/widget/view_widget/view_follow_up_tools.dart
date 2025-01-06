import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/routes/route.dart';
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
                onTap: () {
                  Get.snackbar(
                    '',
                    '',
                    titleText: const Text(
                      '',
                      style: TextStyle(fontSize: 0),
                      textAlign: TextAlign.center,
                    ),
                    messageText: const Text(
                      'قريبا',
                      style: TextStyle(fontSize: 23),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
                image: ImageAsset.poultrySale,
                text: "بيع الدواجن",
              ),
              BigCard(
                onTap: () => Get.toNamed(AppRoute.broilerChickenRequirements),
                image: ImageAsset.chicken,
                text: "احتياجات فراخ التسمين",
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BigCard(
              onTap: () {
                Get.snackbar(
                  '',
                  '',
                  titleText: const Text(
                    '',
                    style: TextStyle(fontSize: 0),
                    textAlign: TextAlign.center,
                  ),
                  messageText: const Text(
                    'قريبا',
                    style: TextStyle(fontSize: 23),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              image: ImageAsset.diseases,
              text: "الامراض",
            ),
            BigCard(
              onTap: () => Get.toNamed(AppRoute.articlesType),
              image: ImageAsset.articles,
              text: "مقالات",
            ),
          ],
        ),
      ],
    );
  }
}
