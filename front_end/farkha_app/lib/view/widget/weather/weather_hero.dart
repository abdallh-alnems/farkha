import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WeatherHero extends StatelessWidget {
  const WeatherHero({
    super.key,
    required this.location,
    required this.temp,
    required this.condition,
    required this.conditionIcon,
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
  final IconData conditionIcon;
  final double feelsLike;
  final Color primary;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceMuted;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: primary.withValues(alpha: isDark ? 0.3 : 0.15),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            surface,
            primary.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
        ),
        boxShadow:
            isDark
                ? null
                : [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_rounded, size: 18.r, color: primary),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  location,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: onSurfaceMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            '°${temp.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 64.sp,
              fontWeight: FontWeight.w200,
              color: primary,
              height: 0.9,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(conditionIcon, size: 20.r, color: onSurfaceMuted),
              SizedBox(width: 6.w),
              Text(
                condition,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
