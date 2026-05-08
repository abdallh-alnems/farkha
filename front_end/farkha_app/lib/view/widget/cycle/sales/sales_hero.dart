import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constant/theme/theme.dart';
import '../../../../logic/controller/cycle_sales_controller.dart';

class SalesHero extends StatelessWidget {
  final CycleSalesController controller;
  final AnimationController heroController;

  const SalesHero({
    super.key,
    required this.controller,
    required this.heroController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: heroController,
        curve: Curves.easeOutCubic,
      ),
      child: Obx(() {
        final totalSales = controller.totalSales.value;
        final sales = controller.sales;
        final totalBirds =
            sales.fold<int>(0, (sum, s) => sum + s.birdsCount);
        final totalWeight =
            sales.fold<double>(0.0, (sum, s) => sum + s.totalWeight);

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      colorScheme.primary.withValues(alpha: 0.12),
                      AppColors.darkSurfaceElevatedColor,
                    ]
                  : [
                      colorScheme.primary.withValues(alpha: 0.06),
                      AppColors.lightSurfaceColor,
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: AppDimens.borderXl,
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.1),
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color:
                          colorScheme.primary.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Padding(
            padding:
                EdgeInsetsDirectional.fromSTEB(20.w, 20.h, 20.w, 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color:
                            colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: AppDimens.borderMd,
                      ),
                      child: Icon(
                        Icons.trending_up_rounded,
                        color: colorScheme.primary,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'إجمالي المبيعات',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface
                              .withValues(alpha: 0.7),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      totalSales.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                        height: 1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Text(
                        'جنيه',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                if (sales.isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 14.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primary
                          .withValues(alpha: isDark ? 0.08 : 0.06),
                      borderRadius: AppDimens.borderMd,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _heroStat(Icons.receipt_long_outlined,
                            '${sales.length}', 'عملية', colorScheme),
                        _heroDivider(colorScheme),
                        _heroStat(Icons.pets_outlined, '$totalBirds',
                            'طائر', colorScheme),
                        _heroDivider(colorScheme),
                        _heroStat(Icons.scale_outlined,
                            totalWeight.toStringAsFixed(0), 'كجم', colorScheme),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _heroStat(
      IconData icon, String value, String unit, ColorScheme colorScheme) {
    return Column(
      children: [
        Icon(icon, size: 18.sp, color: colorScheme.primary),
        SizedBox(height: 6.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              unit,
              style: TextStyle(
                fontSize: 11.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _heroDivider(ColorScheme colorScheme) {
    return Container(
      width: 1,
      height: 32.h,
      color: colorScheme.outline.withValues(alpha: 0.3),
    );
  }
}
