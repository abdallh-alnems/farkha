import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/constant/image_asset.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/color.dart';
import '../../widget/app_bar/custom_app_bar.dart';

class AllTools extends StatelessWidget {
  const AllTools({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: "جميع الحسابات", showIcon: false),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 19,
            childAspectRatio: 1.33,
          ),
          itemCount: calculationItems.length,
          itemBuilder: (context, index) {
            final item = calculationItems[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
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
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primaryColor,
                        ),
                      ),

                    const SizedBox(height: 19),
                    Text(
                      item.text,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static final List<ToolsItem> calculationItems = [
    ToolsItem(
      text: "FCR",
      image: null,
      isTextIcon: true,
      onTap: () => Get.toNamed(AppRoute.fcr),
    ),
    ToolsItem(
      text: "ADG",
      image: null,
      isTextIcon: true,
      onTap: () => Get.toNamed(AppRoute.adg),
    ),
    ToolsItem(
      text: "كثافة الفراخ",
      image: ImageAsset.birdDensity,
      onTap: () => Get.toNamed(AppRoute.chickenDensity),
    ),
    ToolsItem(
      text: "استهلاك العلف اليومي",
      image: ImageAsset.dailyFeedConsumption,
      onTap: () => Get.toNamed(AppRoute.dailyFeedConsumption),
    ),
    ToolsItem(
      text: "استهلاك العلف الكلي",
      image: ImageAsset.totalFeedConsumption,
      onTap: () => Get.toNamed(AppRoute.totalFeedConsumption),
    ),
    ToolsItem(
      text: "الوزن حسب العمر",
      image: ImageAsset.weight,
      onTap: () => Get.toNamed(AppRoute.weightByAge),
    ),
    ToolsItem(
      text: "درجة الحرارة حسب العمر",
      image: ImageAsset.thermometer,
      onTap: () => Get.toNamed(AppRoute.temperatureByAge),
    ),
    ToolsItem(
      text: "ساعات الإظلام",
      image: ImageAsset.darkness,
      onTap: () => Get.toNamed(AppRoute.darknessLevels),
    ),
    ToolsItem(
      text: "تشغيل الشفاطات",
      image: ImageAsset.fan,
      onTap: () => Get.toNamed(AppRoute.fanOperation),
    ),
    ToolsItem(
      text: "جدول التحصينات",
      image: ImageAsset.vaccination,
      onTap: () => Get.toNamed(AppRoute.vaccinationSchedule),
    ),
    ToolsItem(
      text: "مقالات",
      image: ImageAsset.article,
      onTap: () => Get.toNamed(AppRoute.articlesType),
    ),
    ToolsItem(
      text: "الأمراض",
      image: ImageAsset.diseases,
      onTap: () => Get.toNamed(AppRoute.diseases),
    ),
    ToolsItem(
      text: "متطلبات فراخ التسمين",
      image: ImageAsset.chickenRequirements,
      onTap: () => Get.toNamed(AppRoute.broilerChickenRequirements),
    ),

    ToolsItem(
      text: "دراسة جدوي",
      image: ImageAsset.feasibilityStudy,
      onTap: () => Get.toNamed(AppRoute.feasibilityStudy),
    ),
    ToolsItem(
      text: "تكلفة إنتاج الفرخ",
      image: ImageAsset.budget,
      onTap: () => Get.toNamed(AppRoute.birdProductionCost),
    ),
    ToolsItem(
      text: "تكلفة العلف لكل طائر",
      image: ImageAsset.feedCostPerBird,
      onTap: () => Get.toNamed(AppRoute.feedCostPerBird),
    ),
    ToolsItem(
      text: "تكلفة العلف لكل كيلو وزن",
      image: ImageAsset.feedCostPerKilo,
      onTap: () => Get.toNamed(AppRoute.feedCostPerKilo),
    ),
    ToolsItem(
      text: "الربح الصافي للطائر",
      image: ImageAsset.profits,
      onTap: () => Get.toNamed(AppRoute.birdNetProfit),
    ),
    ToolsItem(
      text: "ROI",
      image: null,
      isTextIcon: true,
      onTap: () => Get.toNamed(AppRoute.roi),
    ),

    ToolsItem(
      text: "نسبة النفوق",
      image: ImageAsset.deadChickens,
      onTap: () => Get.toNamed(AppRoute.mortalityRate),
    ),
    ToolsItem(
      text: "الوزن الإجمالي",
      image: ImageAsset.totalWeight,
      onTap: () => Get.toNamed(AppRoute.totalFarmWeight),
    ),
    ToolsItem(
      text: "إجمالي الإيرادات",
      image: ImageAsset.totalRevenue,
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
