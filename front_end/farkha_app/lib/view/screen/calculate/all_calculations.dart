import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/constant/image_asset.dart';
import '../../../core/constant/theme/color.dart';
import '../../widget/app_bar/custom_app_bar.dart';

class AllCalculations extends StatelessWidget {
  const AllCalculations({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: "جميع الحسابات"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: calculationItems.length,
          itemBuilder: (context, index) {
            final item = calculationItems[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (item.image != null)
                          item.image!.endsWith('.svg')
                              ? SvgPicture.asset(
                                item.image!,
                                width: 48,
                                height: 48,
                              )
                              : Image.asset(item.image!, width: 48, height: 48)
                        else if (item.isTextIcon == true)
                          Text(
                            item.text,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColor.primaryColor,
                            ),
                          )
                        else
                          Icon(
                            Icons.calculate,
                            size: 48,
                            color: AppColor.primaryColor,
                          ),
                        const SizedBox(height: 12),
                        Text(
                          item.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static final List<CalculationItem> calculationItems = [
    CalculationItem(
      text: "FCR",
      image: null,
      isTextIcon: true,
      onTap: () => Get.toNamed(AppRoute.fcr),
    ),
    CalculationItem(
      text: "ADG",
      image: null,
      isTextIcon: true,
      onTap: () => Get.toNamed(AppRoute.adg),
    ),
    CalculationItem(
      text: "كثافة الفراخ",
      image: ImageAsset.birdDensity,
      onTap: () => Get.toNamed(AppRoute.chickenDensity),
    ),
    CalculationItem(
      text: "استهلاك العلف",
      image: ImageAsset.feedConsumption,
      onTap: () => Get.toNamed(AppRoute.feedConsumption),
    ),
    CalculationItem(
      text: "دراسة جدوي",
      image: ImageAsset.feasibilityStudy,
      onTap: () => Get.toNamed(AppRoute.feasibilityStudy),
    ),
    CalculationItem(
      text: "نسبة النفوق",
      image: ImageAsset.deadChickens,
      onTap: () => Get.toNamed(AppRoute.mortalityRate),
    ),
    CalculationItem(
      text: "تكلفة إنتاج الفرخ",
      image: ImageAsset.budget,
      onTap: () => Get.toNamed(AppRoute.birdProductionCost),
    ),
    CalculationItem(
      text: "الربح الصافي للطائر",
      image: ImageAsset.profits,
      onTap: () => Get.toNamed(AppRoute.birdNetProfit),
    ),
    CalculationItem(
      text: "ROI",
      image: null,
      isTextIcon: true,
      onTap: () => Get.toNamed(AppRoute.roi),
    ),
    CalculationItem(
      text: "الوزن حسب العمر",
      image: ImageAsset.weight,
      onTap: () => Get.toNamed(AppRoute.weightByAge),
    ),
    CalculationItem(
      text: "درجة الحرارة حسب العمر",
      image: ImageAsset.thermometer,
      onTap: () => Get.toNamed(AppRoute.temperatureByAge),
    ),
    CalculationItem(
      text: "ساعات الإظلام",
      image: ImageAsset.darkness,
      onTap: () => Get.toNamed(AppRoute.darknessLevels),
    ),
    CalculationItem(
      text: "الوزن الإجمالي",
      image: ImageAsset.totalWeight,
      onTap: () => Get.toNamed(AppRoute.totalFarmWeight),
    ),
    CalculationItem(
      text: "إجمالي الإيرادات",
      image: ImageAsset.totalRevenue,
      onTap: () => Get.toNamed(AppRoute.totalRevenue),
    ),
    CalculationItem(
      text: "تكلفة العلف لكل طائر",
      image: ImageAsset.feedCostPerBird,
      onTap: () => Get.toNamed(AppRoute.feedCostPerBird),
    ),
    CalculationItem(
      text: "تكلفة العلف لكل طن وزن",
      image: ImageAsset.feedCostPerKilo,
      onTap: () => Get.toNamed(AppRoute.feedCostPerKilo),
    ),
    CalculationItem(
      text: "جدول التحصينات",
      image: ImageAsset.vaccination,
      onTap: () => Get.toNamed(AppRoute.vaccinationSchedule),
    ),
  ];
}

class CalculationItem {
  final String text;
  final String? image;
  final bool? isTextIcon;
  final VoidCallback onTap;

  const CalculationItem({
    required this.text,
    this.image,
    this.isTextIcon,
    required this.onTap,
  });
}
