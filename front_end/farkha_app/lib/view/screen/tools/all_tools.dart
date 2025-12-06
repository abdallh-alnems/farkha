import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/constant/theme/images.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';

class AllTools extends StatelessWidget {
  const AllTools({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: "الادوات"),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 19,
                  childAspectRatio: 1.33,
                ),
                itemCount: toolsBeforeAd.length,
                itemBuilder: (context, index) {
                  final item = toolsBeforeAd[index];
                  return _buildToolCard(context, item);
                },
              ),

              const SizedBox(height: 19),
              const AdNativeWidget(),
              const SizedBox(height: 19),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 19,
                  childAspectRatio: 1.33,
                ),
                itemCount: toolsAfterAd.length,
                itemBuilder: (context, index) {
                  final item = toolsAfterAd[index];
                  return _buildToolCard(context, item);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildToolCard(BuildContext context, ToolsItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color cardColor =
        isDark
            ? AppColors.darkSurfaceElevatedColor
            : AppColors.lightSurfaceColor;
    final Color borderColor = (isDark
            ? AppColors.darkOutlineColor
            : AppColors.lightOutlineColor)
        .withValues(alpha: isDark ? 0.5 : 0.3);
    final Color textColor = colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderColor),
      ),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(13),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.image != null)
              SvgPicture.asset(item.image!, width: 47, height: 47)
            else if (item.isTextIcon == true)
              Text(
                item.text,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            const SizedBox(height: 19),
            Text(
              item.text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final List<ToolsItem> toolsBeforeAd = [
    ToolsItem(
      text: "دراسة جدوي",
      image: AppImages.feasibilityStudy,
      onTap: () => Get.toNamed(AppRoute.feasibilityStudy),
    ),
    ToolsItem(
      text: "معامل التحويل الغذائي",
      image: AppImages.feedConversionRatio,
      onTap: () => Get.toNamed(AppRoute.fcr),
    ),
    ToolsItem(
      text: "متوسط النمو اليومي",
      image: AppImages.averageDailyGain,
      onTap: () => Get.toNamed(AppRoute.adg),
    ),
    ToolsItem(
      text: "الوزن حسب العمر",
      image: AppImages.weight,
      onTap: () => Get.toNamed(AppRoute.weightByAge),
    ),
  ];

  static final List<ToolsItem> toolsAfterAd = [
    ToolsItem(
      text: "استهلاك العلف اليومي",
      image: AppImages.dailyFeedConsumption,
      onTap: () => Get.toNamed(AppRoute.dailyFeedConsumption),
    ),
    ToolsItem(
      text: "استهلاك العلف الكلي",
      image: AppImages.totalFeedConsumption,
      onTap: () => Get.toNamed(AppRoute.totalFeedConsumption),
    ),
    ToolsItem(
      text: "كثافة الفراخ",
      image: AppImages.birdDensity,
      onTap: () => Get.toNamed(AppRoute.chickenDensity),
    ),

    ToolsItem(
      text: "درجة الحرارة حسب العمر",
      image: AppImages.thermometer,
      onTap: () => Get.toNamed(AppRoute.temperatureByAge),
    ),
    ToolsItem(
      text: "ساعات الإظلام",
      image: AppImages.darkness,
      onTap: () => Get.toNamed(AppRoute.darknessLevels),
    ),
    ToolsItem(
      text: "تشغيل الشفاطات",
      image: AppImages.fan,
      onTap: () => Get.toNamed(AppRoute.fanOperation),
    ),
    ToolsItem(
      text: "جدول التحصينات",
      image: AppImages.vaccination,
      onTap: () => Get.toNamed(AppRoute.vaccinationSchedule),
    ),
    ToolsItem(
      text: "مقالات",
      image: AppImages.article,
      onTap: () => Get.toNamed(AppRoute.articlesList),
    ),
    ToolsItem(
      text: "الأمراض",
      image: AppImages.diseases,
      onTap: () => Get.toNamed(AppRoute.diseases),
    ),
    ToolsItem(
      text: "متطلبات فراخ التسمين",
      image: AppImages.chickenRequirements,
      onTap: () => Get.toNamed(AppRoute.broilerChickenRequirements),
    ),

    ToolsItem(
      text: "تكلفة إنتاج الفرخ",
      image: AppImages.budget,
      onTap: () => Get.toNamed(AppRoute.birdProductionCost),
    ),
    ToolsItem(
      text: "تكلفة العلف لكل طائر",
      image: AppImages.feedCostPerBird,
      onTap: () => Get.toNamed(AppRoute.feedCostPerBird),
    ),
    ToolsItem(
      text: "تكلفة العلف لكل كيلو وزن",
      image: AppImages.feedCostPerKilo,
      onTap: () => Get.toNamed(AppRoute.feedCostPerKilo),
    ),
    ToolsItem(
      text: "الربح الصافي للطائر",
      image: AppImages.profits,
      onTap: () => Get.toNamed(AppRoute.birdNetProfit),
    ),
    ToolsItem(
      text: "العائد على الاستثمار",
      image: AppImages.returnOnInvestment,
      onTap: () => Get.toNamed(AppRoute.roi),
    ),

    ToolsItem(
      text: "نسبة النفوق",
      image: AppImages.deadChickens,
      onTap: () => Get.toNamed(AppRoute.mortalityRate),
    ),
    ToolsItem(
      text: "الوزن الإجمالي",
      image: AppImages.totalWeight,
      onTap: () => Get.toNamed(AppRoute.totalFarmWeight),
    ),
    ToolsItem(
      text: "إجمالي الإيرادات",
      image: AppImages.totalRevenue,
      onTap: () => Get.toNamed(AppRoute.totalRevenue),
    ),
  ];
}

class ToolsItem {
  final String text;
  final String? image;
  final bool? isTextIcon;
  final VoidCallback onTap;

  const ToolsItem({
    required this.text,
    this.image,
    this.isTextIcon,
    required this.onTap,
  });
}
