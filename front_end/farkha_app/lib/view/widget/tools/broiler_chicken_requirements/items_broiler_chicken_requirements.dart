import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constant/theme/theme.dart';
import '../../../../core/functions/number_format.dart';
import '../../../../logic/controller/tools_controller/broiler_controller.dart';
import 'card_broiler_chicken_requirements.dart';
import 'details_broiler.dart';

class ItemsBroilerChickenRequirements extends GetView<BroilerController> {
  const ItemsBroilerChickenRequirements({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showData.value) {
        return _buildEmptyState(context);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DetailsBroiler(),
          SizedBox(height: 20.h),
          _buildSectionHeader(
            context: context,
            icon: Icons.thermostat_outlined,
            title: 'المناخ',
            subtitle: 'درجة الحرارة والرطوبة المناسبة',
          ),
          SizedBox(height: 12.h),
          _buildClimateGrid(context),
          SizedBox(height: 24.h),
          _buildSectionHeader(
            context: context,
            icon: Icons.checklist_rtl_outlined,
            title: 'متطلبات القطيع',
            subtitle: 'المساحة والإضاءة والوزن والعلف',
          ),
          SizedBox(height: 12.h),
          _buildRequirementsGrid(context),
        ],
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevatedColor.withValues(alpha: 0.5)
            : colorScheme.surface,
        borderRadius: AppDimens.borderXl,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),

        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets_outlined,
              size: 40.sp,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'أدخل العمر والعدد',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'لحساب متطلبات فراخ التسمين من حرارة ورطوبة ومساحة وعلف',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: AppDimens.borderSm,
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClimateGrid(BuildContext context) {
    final Widget temperatureTile = _ClimateTile(
      title: 'درجة الحرارة',
      requiredValue: '°${controller.ageTemperature}',
      requiredLabel: 'المطلوبة',
      icon: Icons.device_thermostat,
      weatherWidget: Obx(() => _WeatherStatus(
            hasData: controller.weatherController.hasWeatherData,
            label: 'الخارج',
            value: controller.weatherController.temperatureText,
            icon: Icons.device_thermostat,
          )),
      gradientColors: const [
        AppColors.sunsetGradientStart,
        AppColors.sunsetGradientEnd,
      ],
    );

    final Widget humidityTile = _ClimateTile(
      title: 'نسبة الرطوبة',
      requiredValue: controller.ageHumidityRange,
      requiredLabel: 'المطلوبة',
      icon: Icons.water_drop_outlined,
      weatherWidget: Obx(() => _WeatherStatus(
            hasData: controller.weatherController.hasWeatherData,
            label: 'الخارج',
            value: controller.weatherController.humidityText,
            icon: Icons.water_drop,
          )),
      gradientColors: const [
        AppColors.oceanGradientStart,
        AppColors.oceanGradientEnd,
      ],
    );

    return Row(
      children: [
        Expanded(child: temperatureTile),
        SizedBox(width: 12.w),
        Expanded(child: humidityTile),
      ],
    );
  }

  Widget _buildRequirementsGrid(BuildContext context) {
    final List<_RequirementData> items = [
      _RequirementData(
        title: 'المساحة المطلوبة',
        primary:
            '${formatDecimal(controller.requiredArea.value, decimals: 0)} م²',
        secondary:
            'إجمالي: ${formatDecimal(controller.collegeArea, decimals: 0)} م²',
        icon: Icons.crop_square_outlined,
      ),
      _RequirementData(
        title: 'الإضاءة',
        primary: 'اظلام: ${controller.ageDarkness} ساعة',
        secondary: 'إضاءة: ${24 - controller.ageDarkness} ساعة',
        icon: Icons.light_mode_outlined,
      ),
      _RequirementData(
        title: 'متوسط الوزن',
        primary: '${controller.ageWeight} جم',
        secondary:
            controller.selectedChickenAge.value == null
                ? 'حدد العمر لعرض التفاصيل'
                : 'لعمر يوم ${controller.selectedChickenAge.value}',
        icon: Icons.monitor_weight_outlined,
      ),
      _RequirementData(
        title: 'استهلاك العلف',
        primary: 'يومي: ${_formatFeed(controller.dailyFeedConsumption)}',
        secondary:
            'كلي: ${_formatTotalFeed(controller.totalFeedConsumption)}',
        icon: Icons.grain_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 12;
        final double itemWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (data) => SizedBox(
                  width: itemWidth,
                  child: CardBroilerChickenRequirements(
                    title: data.title,
                    value: data.primary,
                    subtitle: data.secondary,
                    icon: data.icon,
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
      final double dailyFeedInKg = dailyFeed / 1000;
      return '${formatDecimal(dailyFeedInKg)} كيلو';
    } else {
      return '$dailyFeed جرام';
    }
  }

  String _formatTotalFeed(double totalFeed) {
    if (totalFeed >= 1000) {
      final double totalFeedInTon = totalFeed / 1000;
      return '${formatDecimal(totalFeedInTon)} طن';
    } else {
      return '${formatDecimal(totalFeed, decimals: 0)} كيلو';
    }
  }
}

class _ClimateTile extends StatelessWidget {
  const _ClimateTile({
    required this.title,
    required this.requiredValue,
    required this.requiredLabel,
    required this.icon,
    required this.weatherWidget,
    required this.gradientColors,
  });

  final String title;
  final String requiredValue;
  final String requiredLabel;
  final IconData icon;
  final Widget weatherWidget;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: AppDimens.borderLg,
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white.withValues(alpha: 0.9),
                size: 18.sp,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            requiredValue,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  fontSize: 24.sp,
                ),
          ),
          SizedBox(height: 2.h),
          Text(
            requiredLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: weatherWidget,
          ),
        ],
      ),
    );
  }
}

class _WeatherStatus extends StatelessWidget {
  const _WeatherStatus({
    required this.hasData,
    required this.label,
    required this.value,
    required this.icon,
  });

  final bool hasData;
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (!hasData) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off_outlined, color: Colors.white54, size: 14.sp),
          SizedBox(width: 4.w),
          Text(
            'فعّل الموقع',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14.sp),
        SizedBox(width: 4.w),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(width: 6.w),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
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
