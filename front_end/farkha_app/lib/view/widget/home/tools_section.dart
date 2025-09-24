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
    final autoScrollController = Get.find<AutoScrollController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        autoScrollController.startAutoScrollWhenReady();
      });
    });

    autoScrollController.scrollController.addListener(() {
      if (autoScrollController
          .scrollController
          .position
          .isScrollingNotifier
          .value) {
        autoScrollController.startManualScroll();
      }
    });
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
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Text(
                "أدوات مساعدة",
                style: TextStyle(
                  color: AppColor.primaryColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Directionality(
          textDirection: TextDirection.rtl,
          child: GestureDetector(
            onTapDown: (_) => autoScrollController.pauseAutoScroll(),
            onTapUp: (_) => autoScrollController.pauseAutoScroll(),
            onTapCancel: () => autoScrollController.pauseAutoScroll(),
            child: SingleChildScrollView(
              controller: autoScrollController.scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.fcr);
                    },
                    text: "FCR",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.adg);
                    },
                    text: "ADG",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.chickenDensity);
                    },
                    image: ImageAsset.birdDensity,
                    text: "كثافة الفراخ",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.dailyFeedConsumption);
                    },
                    image: ImageAsset.dailyFeedConsumption,
                    text: "استهلاك العلف اليومي",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.totalFeedConsumption);
                    },
                    image: ImageAsset.totalFeedConsumption,
                    text: "استهلاك العلف الكلي",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.weightByAge);
                    },
                    image: ImageAsset.weight,
                    text: "الوزن حسب العمر",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.temperatureByAge);
                    },
                    image: ImageAsset.thermometer,
                    text: "درجة الحرارة حسب العمر",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.darknessLevels);
                    },
                    image: ImageAsset.darkness,
                    text: "مستويات الظلام",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.fanOperation);
                    },
                    image: ImageAsset.fan,
                    text: "تشغيل الشفاطات",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.vaccinationSchedule);
                    },
                    image: ImageAsset.vaccination,
                    text: "جدول التطعيم",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.articlesType);
                    },
                    image: ImageAsset.article,
                    text: "مقالات",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.diseases);
                    },
                    image: ImageAsset.diseases,
                    text: "الأمراض",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.broilerChickenRequirements);
                    },
                    image: ImageAsset.chickenRequirements,
                    text: "متطلبات فراخ التسمين",
                  ),

                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.feasibilityStudy);
                    },
                    image: ImageAsset.feasibilityStudy,
                    text: "دراسة جدوي",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.birdProductionCost);
                    },
                    image: ImageAsset.budget,
                    text: "تكلفة إنتاج الطائر",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.feedCostPerBird);
                    },
                    image: ImageAsset.feedCostPerBird,
                    text: "تكلفة العلف للطائر",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.feedCostPerKilo);
                    },
                    image: ImageAsset.feedCostPerKilo,
                    text: "تكلفة العلف للكيلو",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.birdNetProfit);
                    },
                    image: ImageAsset.profits,
                    text: "صافي ربح الطائر",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.roi);
                    },
                    text: "ROI",
                  ),

                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.mortalityRate);
                    },
                    image: ImageAsset.deadChickens,
                    text: "معدل النفوق",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.totalFarmWeight);
                    },
                    image: ImageAsset.totalWeight,
                    text: "الوزن الإجمالي للمزرعة",
                  ),
                  ToolsCard(
                    onTap: () {
                      autoScrollController.pauseAutoScroll();
                      Get.toNamed(AppRoute.totalRevenue);
                    },
                    image: ImageAsset.totalRevenue,
                    text: "الإيرادات الإجمالية",
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
