import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/theme/colors.dart';
import '../../../../logic/controller/tools_controller/broiler_controller.dart';
import '../../../../logic/controller/weather_controller.dart';
import 'card_broiler_chicken_requirements.dart';
import 'details_broiler.dart';

class ItemsBroilerChickenRequirements extends GetView<BroilerController> {
  const ItemsBroilerChickenRequirements({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showData.value) {
        return _buildEmptyState();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DetailsBroiler(),
          const SizedBox(height: 15),
          _buildSectionTitle(icon: Icons.heat_pump, title: "المناخ"),
          const SizedBox(height: 13),
          _buildClimateGrid(),
          const SizedBox(height: 21),
          _buildSectionTitle(icon: Icons.checklist, title: "متطلبات القطيع"),
          const SizedBox(height: 13),
          _buildRequirementsGrid(),
        ],
      );
    });
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(Get.context!).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 61),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline,
                size: 48,
                color: colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'ادخل العدد والعمر',
              style: Get.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لحساب متطلبات فراخ التسمين',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle({required IconData icon, required String title}) {
    final colorScheme = Theme.of(Get.context!).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.15),
                  colorScheme.primary.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Text(
            title,
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClimateGrid() {
    final Widget temperatureTile = _ColoredInfoTile(
      title: "درجة الحرارة المطلوبة",
      value: "°${controller.ageTemperature}",
      trailing: GetBuilder<WeatherController>(
        builder: (_) {
          return _ChipInfo(
            icon: Icons.device_thermostat,
            label: controller.weatherController.temperatureText,
          );
        },
      ),
      gradient: const [
        AppColors.sunsetGradientStart,
        AppColors.sunsetGradientEnd,
      ],
    );

    final Widget humidityTile = _ColoredInfoTile(
      title: "نسبة الرطوبة المطلوبة",
      value: controller.ageHumidityRange,
      trailing: GetBuilder<WeatherController>(
        builder: (_) {
          return _ChipInfo(
            icon: Icons.water_drop,
            label: controller.weatherController.humidityText,
          );
        },
      ),
      gradient: const [
        AppColors.oceanGradientStart,
        AppColors.oceanGradientEnd,
      ],
    );

    return Row(
      children: [
        Expanded(child: temperatureTile),
        const SizedBox(width: 15),
        Expanded(child: humidityTile),
      ],
    );
  }

  Widget _buildRequirementsGrid() {
    final List<_RequirementData> items = [
      _RequirementData(
        title: "المساحة المطلوبة",
        primary: "${controller.requiredArea.toStringAsFixed(0)} م²",
        secondary: "إجمالي : ${controller.collegeArea.toStringAsFixed(0)} م²",
        icon: Icons.crop_square,
      ),
      _RequirementData(
        title: "الإضاءة",
        primary: "اظلام : ${controller.ageDarkness} ساعة",
        secondary: "إضاءة : ${24 - controller.ageDarkness} ساعة",
        icon: Icons.light_mode,
      ),
      _RequirementData(
        title: "متوسط الوزن",
        primary: "${controller.ageWeight} جم",
        secondary:
            controller.selectedChickenAge.value == null
                ? "حدد العمر لعرض تفاصيل الوزن"
                : "لعمر يوم ${controller.selectedChickenAge.value}",
        icon: Icons.monitor_weight,
      ),
      _RequirementData(
        title: "استهلاك العلف",
        primary: "يومي : ${_formatFeed(controller.dailyFeedConsumption)}",
        secondary: "كلي : ${_formatTotalFeed(controller.totalFeedConsumption)}",
        icon: Icons.grain,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 16;
        final double itemWidth =
            (constraints.maxWidth - spacing) / 2; // دائماً 2 كارت في كل صف

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children:
              items
                  .map(
                    (data) => SizedBox(
                      width: itemWidth,
                      child: CardBroilerChickenRequirements(
                        title: data.title,
                        value: data.primary,
                        subtitle: data.secondary,
                        icon: data.icon,
                        gradientColors: const [],
                      ),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }

  String _formatFeed(int dailyFeed) {
    if (dailyFeed >= 1000) {
      double dailyFeedInKg = dailyFeed / 1000;
      return "${dailyFeedInKg.toStringAsFixed(1)} كيلو";
    } else {
      return "$dailyFeed جرام";
    }
  }

  String _formatTotalFeed(double totalFeed) {
    if (totalFeed >= 1000) {
      double totalFeedInTon = totalFeed / 1000;
      return "${totalFeedInTon.toStringAsFixed(1)} طن";
    } else {
      return "${totalFeed.toStringAsFixed(0)} كيلو";
    }
  }
}

class _ColoredInfoTile extends StatelessWidget {
  const _ColoredInfoTile({
    required this.title,
    required this.value,
    required this.trailing,
    required this.gradient,
  });

  final String title;
  final String value;
  final Widget trailing;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          trailing,
        ],
      ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  const _ChipInfo({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 0),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementData {
  const _RequirementData({
    required this.title,
    required this.primary,
    required this.secondary,
    required this.icon,
  });

  final String title;
  final String primary;
  final String secondary;
  final IconData icon;
}
