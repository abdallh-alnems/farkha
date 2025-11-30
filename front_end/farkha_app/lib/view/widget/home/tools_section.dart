import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/images.dart';
import '../../../logic/controller/tools_controller/auto_scroll_controller.dart';
import '../tools/tools_card.dart';

class ToolsSection extends StatelessWidget {
  final GlobalKey? toolsSectionKey;
  final GlobalKey? toolsTitleKey;
  final GlobalKey? viewAllKey;
  final GlobalKey? toolsScrollViewKey;

  const ToolsSection({
    super.key,
    this.toolsSectionKey,
    this.toolsTitleKey,
    this.viewAllKey,
    this.toolsScrollViewKey,
  });

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
      key: toolsSectionKey,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "أدوات مساعدة",
                key: toolsTitleKey,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoute.allTools),
                child: Text(
                  "عرض الكل",
                  key: viewAllKey,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTapDown: (_) => autoScrollController.pauseAutoScroll(),
          onTapUp: (_) => autoScrollController.pauseAutoScroll(),
          onTapCancel: () => autoScrollController.pauseAutoScroll(),
          child: SingleChildScrollView(
            key: toolsScrollViewKey,
            controller: autoScrollController.scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.fcr);
                  },
                  image: AppImages.feedConversionRatio,
                  text: "معامل التحويل الغذائي",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.adg);
                  },
                  image: AppImages.averageDailyGain,
                  text: "متوسط النمو اليومي",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.chickenDensity);
                  },
                  image: AppImages.birdDensity,
                  text: "كثافة الفراخ",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.dailyFeedConsumption);
                  },
                  image: AppImages.dailyFeedConsumption,
                  text: "استهلاك العلف اليومي",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.totalFeedConsumption);
                  },
                  image: AppImages.totalFeedConsumption,
                  text: "استهلاك العلف الكلي",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.weightByAge);
                  },
                  image: AppImages.weight,
                  text: "الوزن حسب العمر",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.temperatureByAge);
                  },
                  image: AppImages.thermometer,
                  text: "درجة الحرارة حسب العمر",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.darknessLevels);
                  },
                  image: AppImages.darkness,
                  text: "مستويات الظلام",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.fanOperation);
                  },
                  image: AppImages.fan,
                  text: "تشغيل الشفاطات",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.vaccinationSchedule);
                  },
                  image: AppImages.vaccination,
                  text: "التحصينات",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.articlesList);
                  },
                  image: AppImages.article,
                  text: "مقالات",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.diseases);
                  },
                  image: AppImages.diseases,
                  text: "الأمراض",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.broilerChickenRequirements);
                  },
                  image: AppImages.chickenRequirements,
                  text: "متطلبات فراخ التسمين",
                ),

                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.feasibilityStudy);
                  },
                  image: AppImages.feasibilityStudy,
                  text: "دراسة جدوي",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.birdProductionCost);
                  },
                  image: AppImages.budget,
                  text: "تكلفة إنتاج الطائر",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.feedCostPerBird);
                  },
                  image: AppImages.feedCostPerBird,
                  text: "تكلفة العلف للطائر",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.feedCostPerKilo);
                  },
                  image: AppImages.feedCostPerKilo,
                  text: "تكلفة العلف للكيلو",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.birdNetProfit);
                  },
                  image: AppImages.profits,
                  text: "صافي ربح الطائر",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.roi);
                  },
                  image: AppImages.returnOnInvestment,
                  text: "العائد على الاستثمار",
                ),

                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.mortalityRate);
                  },
                  image: AppImages.deadChickens,
                  text: "معدل النفوق",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.totalFarmWeight);
                  },
                  image: AppImages.totalWeight,
                  text: "الوزن الإجمالي",
                ),
                ToolsCard(
                  onTap: () {
                    autoScrollController.pauseAutoScroll();
                    Get.toNamed(AppRoute.totalRevenue);
                  },
                  image: AppImages.totalRevenue,
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
