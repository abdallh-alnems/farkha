import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/theme/colors.dart';
import 'performance_calculations.dart';

class PerformanceMetricsGrid extends StatelessWidget {
  const PerformanceMetricsGrid({
    super.key,
    required this.fcr,
    required this.canFCR,
    required this.showEarly,
    required this.currentWeight,
    required this.expectedWeight,
    required this.epef,
    required this.cost,
    required this.isDark,
  });

  final double fcr;
  final bool canFCR;
  final bool showEarly;
  final double currentWeight;
  final double expectedWeight;
  final double epef;
  final double cost;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final surfaceColor =
        isDark ? AppColors.darkSurfaceElevatedColor : AppColors.lightSurfaceColor;
    final dimColor = isDark ? AppColors.darkOutlineColor : AppColors.lightOutlineColor;
    final accentColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    Widget metricCard({
      required String label,
      required String value,
      String? unit,
      String? badge,
      Color? badgeColor,
      Color? valueColor,
    }) {
      final effectiveVC = valueColor ?? accentColor;
      return Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: dimColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: value.length > 12 ? 13.sp : 22.sp,
                        fontWeight: FontWeight.w800,
                        color: effectiveVC,
                        height: 1.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (unit != null && unit.isNotEmpty) ...[
                    SizedBox(width: 3.w),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
              if (badge != null) ...[
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? accentColor).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: badgeColor ?? accentColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(children: [
          canFCR
              ? metricCard(
                  label: 'معدل التحويل الغذائي',
                  value: fcr > 0 ? (fcr % 1 == 0 ? fcr.round().toString() : fcr.toStringAsFixed(1)) : '0',
                  badge: showEarly ? 'تقييم مبكر' : null,
                  badgeColor: showEarly ? AppColors.warningColor : null,
                )
              : metricCard(
                  label: 'معدل التحويل الغذائي',
                  value: 'عند 15 يوم',
                  valueColor: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
          SizedBox(width: 8.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: dimColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'متوسط الوزن',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        formatWeightValue(currentWeight),
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        weightUnit(currentWeight),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  if (expectedWeight > 0) ...[
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.grey[800] : Colors.grey[100]),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'متوقع: ',
                            style: TextStyle(fontSize: 9.sp, color: isDark ? Colors.grey[500] : Colors.grey[500]),
                          ),
                          Text(
                            formatWeight(expectedWeight),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.grey[300] : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ]),
        SizedBox(height: 8.w),
        Row(children: [
          metricCard(
            label: 'الكفاءة الإنتاجية',
            value: epef.round().toString(),
            unit: '%',
          ),
          SizedBox(width: 8.w),
          metricCard(
            label: 'تكلفة الطائر',
            value: cost.round().toString(),
            unit: 'جنيه',
          ),
        ]),
      ],
    );
  }
}
