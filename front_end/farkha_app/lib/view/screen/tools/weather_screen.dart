import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../logic/controller/weather_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/weather/weather_forecast.dart';
import '../../widget/weather/weather_hero.dart';
import '../../widget/weather/weather_stats.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WeatherController controller =
        Get.isRegistered<WeatherController>()
            ? Get.find<WeatherController>()
            : Get.put(WeatherController());

    logToolPageViewOnce(widgetType: WeatherScreen, toolId: 24);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final primary =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
    final surface =
        isDark
            ? AppColors.darkSurfaceElevatedColor
            : AppColors.lightSurfaceColor;
    final onSurface = colorScheme.onSurface;
    final onSurfaceMuted = onSurface.withValues(alpha: 0.6);

    return Scaffold(
      appBar: const CustomAppBar(text: 'الطقس', favoriteToolName: 'الطقس'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AdNativeWidget(),
              SizedBox(height: 16.h),
              Obx(() {
                final status = controller.statusRequest.value;
                final effectiveStatus =
                    status == StatusRequest.none
                        ? StatusRequest.loading
                        : status;
                return HandlingDataView(
                  statusRequest: effectiveStatus,
                  widget: _SuccessBody(
                    controller: controller,
                    isDark: isDark,
                    primary: primary,
                    surface: surface,
                    onSurface: onSurface,
                    onSurfaceMuted: onSurfaceMuted,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({
    required this.controller,
    required this.isDark,
    required this.primary,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceMuted,
  });

  final WeatherController controller;
  final bool isDark;
  final Color primary;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceMuted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WeatherHero(
          location: controller.locationMessage,
          temp: controller.currentTemperature.value,
          condition: controller.conditionTextArabic,
          conditionIcon: mapConditionIcon(
            controller.currentConditionText.value,
          ),
          feelsLike: controller.feelsLikeC.value,
          primary: primary,
          surface: surface,
          onSurface: onSurface,
          onSurfaceMuted: onSurfaceMuted,
          isDark: isDark,
        ),
        SizedBox(height: 14.h),
        QuickStatsGrid(
          humidity: controller.currentHumidity.value,
          windSpeed: controller.currentWindSpeed.value,
          windDir: controller.windDirectionArabic,
          precip: controller.precipitationDescription,
          primary: primary,
          surface: surface,
          onSurface: onSurface,
          onSurfaceMuted: onSurfaceMuted,
          isDark: isDark,
        ),
        if (controller.pressureMb.value > 0 ||
            controller.visKm.value > 0 ||
            controller.uv.value > 0 ||
            controller.cloud.value > 0 ||
            controller.gustKph.value > 0) ...[
          SizedBox(height: 14.h),
          DetailGrid(
            controller: controller,
            primary: primary,
            surface: surface,
            onSurface: onSurface,
            onSurfaceMuted: onSurfaceMuted,
            isDark: isDark,
          ),
        ],
        Obx(() {
          final days = controller.forecastDays;
          if (days.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 22.h),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 4.w),
                child: Text(
                  'الأيام القادمة',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              ForecastSection(
                days: days,
                conditionToArabic: controller.conditionToArabic,
                conditionIcon: mapConditionIcon,
                primary: primary,
                surface: surface,
                onSurface: onSurface,
                onSurfaceMuted: onSurfaceMuted,
                isDark: isDark,
                formatDate: weekdayFromDate,
              ),
            ],
          );
        }),
      ],
    );
  }
}
