import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/image_asset.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/color.dart';
import '../../../core/shared/card/calculate_card.dart';
import '../../../logic/controller/tools_controller/auto_scroll_controller.dart';

class ToolsSection extends StatelessWidget {
  const ToolsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AutoScrollController autoScrollController =
        Get.find<AutoScrollController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Get.toNamed(AppRoute.allTools),
                child: Text(
                  "عرض الكل",
                  style: TextStyle(
                    color: AppColor.primaryColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Text(
                "أدوات مساعدة",
                style: TextStyle(
                  color: AppColor.primaryColor,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            controller: autoScrollController.scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                ToolsCard(onTap: () => Get.toNamed(AppRoute.fcr), text: "FCR"),
                ToolsCard(onTap: () => Get.toNamed(AppRoute.adg), text: "ADG"),
                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.chickenDensity),
                  image: ImageAsset.birdDensity,
                  text: "كثافة الفراخ",
                ),
                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.dailyFeedConsumption),
                  image: ImageAsset.dailyFeedConsumption,
                  text: "استهلاك العلف اليومي",
                ),
                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.totalFeedConsumption),
                  image: ImageAsset.totalFeedConsumption,
                  text: "استهلاك العلف الكلي",
                ),
                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.weightByAge),
                  image: ImageAsset.weight,
                  text: "الوزن حسب العمر",
                ),
                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.temperatureByAge),
                  image: ImageAsset.thermometer,
                  text: "درجة الحرارة حسب العمر",
                ),
                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.darknessLevels),
                  image: ImageAsset.darkness,
                  text: "مستويات الظلام",
                ),
                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.fanOperation),
                  image: ImageAsset.fan,
                  text: "تشغيل الشفاطات",
                ),
                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.vaccinationSchedule),
                  image: ImageAsset.vaccination,
                  text: "جدول التطعيم",
                ),
                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.articlesType),
                  image: ImageAsset.article,
                  text: "مقالات",
                ),
                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.diseases),
                  image: ImageAsset.diseases,
                  text: "الأمراض",
                ),
                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.broilerChickenRequirements),
                  image: ImageAsset.chickenRequirements,
                  text: "متطلبات فراخ التسمين",
                ),

                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.feasibilityStudy),
                  image: ImageAsset.feasibilityStudy,
                  text: "دراسة جدوي",
                ),
                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.birdProductionCost),
                  image: ImageAsset.budget,
                  text: "تكلفة إنتاج الطائر",
                ),
                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.feedCostPerBird),
                  image: ImageAsset.feedCostPerBird,
                  text: "تكلفة العلف للطائر",
                ),
                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.feedCostPerKilo),
                  image: ImageAsset.feedCostPerKilo,
                  text: "تكلفة العلف للكيلو",
                ),
                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.birdNetProfit),
                  image: ImageAsset.profits,
                  text: "صافي ربح الطائر",
                ),
                ToolsCard(onTap: () => Get.toNamed(AppRoute.roi), text: "ROI"),

                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.mortalityRate),
                  image: ImageAsset.deadChickens,
                  text: "معدل النفوق",
                ),
                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.totalFarmWeight),
                  image: ImageAsset.totalWeight,
                  text: "الوزن الإجمالي للمزرعة",
                ),
                ToolsCard(
                  onTap: () => Get.toNamed(AppRoute.totalRevenue),
                  image: ImageAsset.totalRevenue,
                  text: "الإيرادات الإجمالية",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
