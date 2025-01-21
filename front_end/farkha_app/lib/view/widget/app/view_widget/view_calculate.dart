import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/routes/route.dart';
import '../../../../core/constant/image_asset.dart';
import '../../../../core/shared/custom_divider.dart';
import '../../../../core/shared/card/small_card.dart';

class ViewCalculate extends StatelessWidget {
  const ViewCalculate({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomDivider(
          text: "احسب",
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SmallCard(
                onTap: () => Get.toNamed(AppRoute.chickenDensity),
                image: ImageAsset.birdDensity,
                text: "كثافة الفراخ",
              ),
              SmallCard(
                onTap: () => Get.toNamed(AppRoute.feedConsumption),
                image: ImageAsset.feedConsumption,
                text: "استهلاك العلف",
              ),
              SmallCard(
                onTap: () {
                  Get.toNamed(AppRoute.feasibilityStudy);
                },
                image: ImageAsset.feasibilityStudy,
                text: "دراسة جدوي",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
