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
    final onSurfaceMuted = onSurface.withValues(alpha: 0.7);

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

  static const _weekdays = [
    '',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static String _weekdayFromDate(String dateStr) {
    if (dateStr.length < 10) return dateStr;
    final d = DateTime.tryParse(dateStr);
    if (d == null) return dateStr;
    final w = d.weekday;
    return (w >= 1 && w <= 7) ? _weekdays[w] : dateStr;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeaderCard(
          location: controller.locationMessage,
          temp: controller.currentTemperature.value,
          condition: controller.conditionTextArabic,
          feelsLike: controller.feelsLikeC.value,
          primary: primary,
          surface: surface,
          onSurface: onSurface,
          onSurfaceMuted: onSurfaceMuted,
          isDark: isDark,
        ),
        SizedBox(height: 16.h),
        _QuickStats(
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
          SizedBox(height: 16.h),
          _DetailsCard(
            controller: controller,
            primary: primary,
            surface: surface,
            onSurface: onSurface,
            onSurfaceMuted: onSurfaceMuted,
          ),
        ],
        Obx(() {
          final days = controller.forecastDays;
          if (days.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.only(right: 4.w),
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
              _ForecastCard(
                days: days,
                conditionToArabic: controller.conditionToArabic,
                primary: primary,
                surface: surface,
                onSurface: onSurface,
                onSurfaceMuted: onSurfaceMuted,
                formatDate: _weekdayFromDate,
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.location,
    required this.temp,
    required this.condition,
    required this.feelsLike,
    required this.primary,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.isDark,
  });

  final String location;
  final double temp;
  final String condition;
  final double feelsLike;
  final Color primary;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceMuted;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: primary.withValues(alpha: isDark ? 0.4 : 0.3),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            surface,
            primary.withValues(alpha: isDark ? 0.12 : 0.06),
            AppColors.oceanGradientStart.withValues(alpha: isDark ? 0.1 : 0.05),
          ],
        ),
        boxShadow:
            isDark
                ? null
                : [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 20.r, color: primary),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: onSurfaceMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            '°${temp.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.w300,
              color: primary,
              height: 1,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            condition,
            style: TextStyle(
              fontSize: 16.sp,
              color: onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'الإحساس °${feelsLike.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 13.sp, color: onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({
    required this.humidity,
    required this.windSpeed,
    required this.windDir,
    required this.precip,
    required this.primary,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.isDark,
  });

  final int humidity;
  final double windSpeed;
  final String windDir;
  final String precip;
  final Color primary;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceMuted;
  final bool isDark;

  static Color _accent(bool isDark, int index) {
    const light = [
      Color(0xFF0D9488),
      Color(0xFF0891B2),
      Color(0xFF6366F1),
      Color(0xFF0284C7),
    ];
    const dark = [
      Color(0xFF2DD4BF),
      Color(0xFF22D3EE),
      Color(0xFF818CF8),
      Color(0xFF38BDF8),
    ];
    return isDark ? dark[index] : light[index];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatChip(
                icon: Icons.water_drop_rounded,
                label: 'الرطوبة',
                value: '$humidity%',
                accentColor: _accent(isDark, 0),
                surface: surface,
                onSurface: onSurface,
                onSurfaceMuted: onSurfaceMuted,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _StatChip(
                icon: Icons.air_rounded,
                label: 'الرياح',
                value: '${windSpeed.toStringAsFixed(0)} كم/س',
                accentColor: _accent(isDark, 1),
                surface: surface,
                onSurface: onSurface,
                onSurfaceMuted: onSurfaceMuted,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _StatChip(
                icon: Icons.explore_rounded,
                label: 'اتجاه الرياح',
                value: windDir,
                accentColor: _accent(isDark, 2),
                surface: surface,
                onSurface: onSurface,
                onSurfaceMuted: onSurfaceMuted,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _StatChip(
                icon: Icons.grain_rounded,
                label: 'الأمطار',
                value: precip,
                accentColor: _accent(isDark, 3),
                surface: surface,
                onSurface: onSurface,
                onSurfaceMuted: onSurfaceMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceMuted,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceMuted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 22.r, color: accentColor),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Text(label, style: TextStyle(fontSize: 12.sp, color: onSurfaceMuted)),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.controller,
    required this.primary,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceMuted,
  });

  final WeatherController controller;
  final Color primary;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceMuted;

  @override
  Widget build(BuildContext context) {
    final items = <_DetailItem>[];
    if (controller.pressureMb.value > 0) {
      items.add(
        _DetailItem(
          'الضغط الجوي',
          '${controller.pressureMb.value.toStringAsFixed(0)} مليبار',
        ),
      );
    }
    if (controller.visKm.value > 0) {
      items.add(
        _DetailItem(
          'الرؤية',
          '${controller.visKm.value.toStringAsFixed(0)} كم',
        ),
      );
    }
    if (controller.uv.value > 0) {
      items.add(
        _DetailItem(
          'مؤشر الأشعة فوق البنفسجية',
          controller.uv.value.toStringAsFixed(0),
        ),
      );
    }
    if (controller.cloud.value > 0) {
      items.add(_DetailItem('نسبة الغيوم', '${controller.cloud.value}%'));
    }
    if (controller.gustKph.value > 0) {
      items.add(
        _DetailItem(
          'هبوب الرياح',
          '${controller.gustKph.value.toStringAsFixed(0)} كم/س',
        ),
      );
    }
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(14.r),
                bottomRight: Radius.circular(14.r),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primary,
                  AppColors.oceanGradientStart.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تفاصيل إضافية',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: onSurfaceMuted,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...items.map(
                    (e) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.label,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: onSurfaceMuted,
                            ),
                          ),
                          Text(
                            e.value,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  _DetailItem(this.label, this.value);
  final String label;
  final String value;
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({
    required this.days,
    required this.conditionToArabic,
    required this.primary,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.formatDate,
  });

  final List<ForecastDay> days;
  final String Function(String) conditionToArabic;
  final Color primary;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceMuted;
  final String Function(String) formatDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.oceanGradientEnd.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: Column(
          children: [
            for (int i = 0; i < days.length; i++) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        formatDate(days[i].date),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: onSurface,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '°${days[i].maxtempC.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: primary,
                              ),
                            ),
                            Text(
                              ' / ',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: onSurfaceMuted,
                              ),
                            ),
                            Text(
                              '°${days[i].mintempC.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        conditionToArabic(days[i].conditionText),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: onSurfaceMuted,
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < days.length - 1)
                Divider(
                  height: 1.h,
                  color: primary.withValues(alpha: 0.08),
                  indent: 16.w,
                  endIndent: 16.w,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
