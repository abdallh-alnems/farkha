import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/image_asset.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/shared/card/calculate_card.dart';
import '../../../core/shared/custom_divider.dart';
import '../../../logic/controller/calculate_controller/auto_scroll_controller.dart';

class CalculationSection extends StatelessWidget {
  const CalculationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AutoScrollController autoScrollController =
        Get.find<AutoScrollController>();

    return Column(
      children: [
        CustomDivider(
          text: "احسب",
          onViewAllPressed: () => Get.toNamed(AppRoute.allCalculations),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 11),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              controller: autoScrollController.scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  // إضافة مسافة في البداية
                  const SizedBox(width: 8),
                  CalculateCard(
                    onTap: () => Get.toNamed(AppRoute.fcr),
                    text: "FCR",
                  ),
                  CalculateCard(
                    onTap: () => Get.toNamed(AppRoute.chickenDensity),
                    image: ImageAsset.birdDensity,
                    text: "كثافة الفراخ",
                  ),
                  CalculateCard(
                    onTap: () => Get.toNamed(AppRoute.feedConsumption),
                    image: ImageAsset.feedConsumption,
                    text: "استهلاك العلف",
                  ),
                  CalculateCard(
                    onTap: () => Get.toNamed(AppRoute.adg),
                    text: "ADG",
                  ),
                  CalculateCard(
                    onTap: () => Get.toNamed(AppRoute.roi),
                    text: "ROI",
                  ),
                  CalculateCard(
                    onTap: () => Get.toNamed(AppRoute.mortalityRate),
                    image: ImageAsset.deadChickens,
                    text: "معدل النفوق",
                  ),
                  CalculateCard(
                    onTap: () => Get.toNamed(AppRoute.birdProductionCost),
                    image: ImageAsset.budget,
                    text: "تكلفة إنتاج الطائر",
                  ),
                  CalculateCard(
                    onTap: () => Get.toNamed(AppRoute.birdNetProfit),
                    image: ImageAsset.profits,
                    text: "صافي ربح الطائر",
                  ),
                  CalculateCard(
                    onTap: () => Get.toNamed(AppRoute.weightByAge),
                    image: ImageAsset.weight,
                    text: "الوزن حسب العمر",
                  ),
                  CalculateCard(
                    onTap: () => Get.toNamed(AppRoute.temperatureByAge),
                    image: ImageAsset.thermometer,
                    text: "درجة الحرارة حسب العمر",
                  ),
                  CalculateCard(
                    onTap: () => Get.toNamed(AppRoute.darknessLevels),
                    image: ImageAsset.darkness,
                    text: "مستويات الظلام",
                  ),
                  CalculateCard(
                    onTap: () => Get.toNamed(AppRoute.totalFarmWeight),
                    image: ImageAsset.totalWeight,
                    text: "الوزن الإجمالي للمزرعة",
                  ),
                  CalculateCard(
                    onTap: () => Get.toNamed(AppRoute.totalRevenue),
                    image: ImageAsset.totalRevenue,
                    text: "الإيرادات الإجمالية",
                  ),
                  CalculateCard(
                    onTap: () => Get.toNamed(AppRoute.feedCostPerBird),
                    image: ImageAsset.feedCostPerBird,
                    text: "تكلفة العلف للطائر",
                  ),
                  CalculateCard(
                    onTap: () => Get.toNamed(AppRoute.feedCostPerKilo),
                    image: ImageAsset.feedCostPerKilo,
                    text: "تكلفة العلف للكيلو",
                  ),
                  CalculateCard(
                    onTap: () => Get.toNamed(AppRoute.vaccinationSchedule),
                    image: ImageAsset.vaccination,
                    text: "جدول التطعيم",
                  ),
                  CalculateCard(
                    onTap: () => Get.toNamed(AppRoute.feasibilityStudy),
                    image: ImageAsset.feasibilityStudy,
                    text: "دراسة جدوي",
                  ),
                  // إضافة مسافة في النهاية
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
