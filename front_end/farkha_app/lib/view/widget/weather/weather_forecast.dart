import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/weather_controller.dart';

const _weekdays = [
  '',
  'الإثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
  'الأحد',
];

String weekdayFromDate(String dateStr) {
  if (dateStr.length < 10) return dateStr;
  final d = DateTime.tryParse(dateStr);
  if (d == null) return dateStr;
  final w = d.weekday;
  return (w >= 1 && w <= 7) ? _weekdays[w] : dateStr;
}

IconData mapConditionIcon(String englishText) {
  final t = englishText.toLowerCase();
  if (t.contains('sunny') || t.contains('clear')) {
    return Icons.wb_sunny_rounded;
  }
  if (t.contains('thunder') || t.contains('storm')) {
    return Icons.flash_on_rounded;
  }
  if (t.contains('snow') || t.contains('sleet') || t.contains('blizzard')) {
    return Icons.ac_unit_rounded;
  }
  if (t.contains('fog') || t.contains('mist') || t.contains('haze')) {
    return Icons.blur_on_rounded;
  }
  if (t.contains('rain') || t.contains('drizzle') || t.contains('shower')) {
    return Icons.water_drop_rounded;
  }
  if (t.contains('overcast')) return Icons.cloud_rounded;
  if (t.contains('cloud') || t.contains('partly')) {
    return Icons.wb_cloudy_rounded;
  }
  return Icons.wb_cloudy_rounded;
}

class ForecastSection extends StatelessWidget {
  const ForecastSection({
    super.key,
    required this.days,
    required this.conditionToArabic,
    required this.conditionIcon,
    required this.primary,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.isDark,
    required this.formatDate,
  });

  final List<ForecastDay> days;
  final String Function(String) conditionToArabic;
  final IconData Function(String) conditionIcon;
  final Color primary;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceMuted;
  final bool isDark;
  final String Function(String) formatDate;

  @override
  Widget build(BuildContext context) {
    final globalMin = days.map((d) => d.mintempC).reduce(math.min);
    final globalMax = days.map((d) => d.maxtempC).reduce(math.max);
    final safeRange = (globalMax - globalMin).clamp(1.0, double.infinity);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: primary.withValues(alpha: 0.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: [
            for (int i = 0; i < days.length; i++) ...[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Icon(
                                conditionIcon(days[i].conditionText),
                                size: 16.r,
                                color: onSurfaceMuted,
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  formatDate(days[i].date),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
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
                                  fontWeight: FontWeight.w500,
                                  color: onSurfaceMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: TempRangeBar(
                        dayMin: days[i].mintempC,
                        dayMax: days[i].maxtempC,
                        globalMin: globalMin,
                        safeRange: safeRange,
                        primary: primary,
                        isDark: isDark,
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

class TempRangeBar extends StatelessWidget {
  const TempRangeBar({
    super.key,
    required this.dayMin,
    required this.dayMax,
    required this.globalMin,
    required this.safeRange,
    required this.primary,
    required this.isDark,
  });

  final double dayMin;
  final double dayMax;
  final double globalMin;
  final double safeRange;
  final Color primary;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final start =
        ((dayMin - globalMin) / safeRange).clamp(0.0, 1.0);
    final end =
        ((dayMax - globalMin) / safeRange).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final barStart = start * trackWidth;
        final rawWidth = (end - start) * trackWidth;
        final barWidth = rawWidth.clamp(8.0, trackWidth - barStart);

        return SizedBox(
          height: 5.h,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
              Positioned(
                left: barStart,
                width: barWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.infoColor.withValues(alpha: 0.8),
                        AppColors.accentColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
