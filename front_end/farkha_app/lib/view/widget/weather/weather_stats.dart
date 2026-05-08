import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/weather_controller.dart';

class QuickStatsGrid extends StatelessWidget {
  const QuickStatsGrid({
    super.key,
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

  Color _chipAccent(int index) {
    const light = [
      AppColors.infoColor,
      AppColors.accentColor,
      AppColors.secondaryColor,
      AppColors.primaryColor,
    ];
    const dark = [
      Color(0xFF7DB8A8),
      Color(0xFFD48B6E),
      Color(0xFFDFC06A),
      Color(0xFF8FBC8F),
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
              child: StatChip(
                icon: Icons.water_drop_rounded,
                label: 'الرطوبة',
                value: '$humidity%',
                accent: _chipAccent(0),
                surface: surface,
                onSurface: onSurface,
                onSurfaceMuted: onSurfaceMuted,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: StatChip(
                icon: Icons.air_rounded,
                label: 'الرياح',
                value: '${windSpeed.toStringAsFixed(0)} كم/س',
                accent: _chipAccent(1),
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
              child: StatChip(
                icon: Icons.explore_rounded,
                label: 'اتجاه الرياح',
                value: windDir,
                accent: _chipAccent(2),
                surface: surface,
                onSurface: onSurface,
                onSurfaceMuted: onSurfaceMuted,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: StatChip(
                icon: Icons.grain_rounded,
                label: 'الأمطار',
                value: precip,
                accent: _chipAccent(3),
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

class StatChip extends StatelessWidget {
  const StatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceMuted,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
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
        border: Border.all(color: accent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18.r, color: accent),
          ),
          SizedBox(height: 8.h),
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

class DetailGrid extends StatelessWidget {
  const DetailGrid({
    super.key,
    required this.controller,
    required this.primary,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.isDark,
  });

  final WeatherController controller;
  final Color primary;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceMuted;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final items = <DetailRow>[];
    if (controller.pressureMb.value > 0) {
      items.add(
        DetailRow(
          Icons.speed_rounded,
          'الضغط الجوي',
          '${controller.pressureMb.value.toStringAsFixed(0)} مليبار',
        ),
      );
    }
    if (controller.visKm.value > 0) {
      items.add(
        DetailRow(
          Icons.visibility_rounded,
          'الرؤية',
          '${controller.visKm.value.toStringAsFixed(0)} كم',
        ),
      );
    }
    if (controller.uv.value > 0) {
      items.add(
        DetailRow(
          Icons.wb_sunny_rounded,
          'مؤشر الأشعة فوق البنفسجية',
          controller.uv.value.toStringAsFixed(0),
        ),
      );
    }
    if (controller.cloud.value > 0) {
      items.add(
        DetailRow(
          Icons.cloud_rounded,
          'نسبة الغيوم',
          '${controller.cloud.value}%',
        ),
      );
    }
    if (controller.gustKph.value > 0) {
      items.add(
        DetailRow(
          Icons.air_rounded,
          'هبوب الرياح',
          '${controller.gustKph.value.toStringAsFixed(0)} كم/س',
        ),
      );
    }
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل إضافية',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: primary,
            ),
          ),
          SizedBox(height: 14.h),
          ...List.generate(items.length, (i) {
            final isLast = i == items.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
              child: Row(
                children: [
                  Icon(
                    items[i].icon,
                    size: 18.r,
                    color: primary.withValues(alpha: 0.7),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      items[i].label,
                      style: TextStyle(fontSize: 13.sp, color: onSurfaceMuted),
                    ),
                  ),
                  Text(
                    items[i].value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class DetailRow {
  DetailRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
}
