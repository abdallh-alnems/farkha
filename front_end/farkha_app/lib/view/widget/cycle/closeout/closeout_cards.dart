import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/theme/theme.dart';
import 'closeout_data.dart';

class CloseoutInfoCard extends StatelessWidget {
  final CloseoutData data;
  final bool isDark;

  const CloseoutInfoCard({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark
        ? AppColors.darkSurfaceElevatedColor
        : AppColors.lightCardBackgroundColor;
    final dimColor =
        isDark ? AppColors.darkOutlineColor : AppColors.lightOutlineColor;
    final accentColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    final items = [
      InfoItem('اسم الدورة', data.name, Icons.label_outline),
      InfoItem('عمر الدورة', '${data.ageDays} يوم', Icons.calendar_today_outlined),
      InfoItem('السلالة', data.breed, Icons.category_outlined),
      InfoItem('نظام التربية', data.systemType, Icons.home_outlined),
      InfoItem('مساحة العنبر', '${data.space} م²', Icons.straighten),
      InfoItem('تاريخ البدء', data.startDate, Icons.date_range),
    ];

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: dimColor),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 7.h),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.value,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(item.icon, size: 17.sp, color: accentColor),
                  ],
                ),
              ),
              if (i < items.length - 1)
                Divider(
                  height: 1,
                  color: dimColor.withValues(alpha: 0.5),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class CloseoutPerformanceRow extends StatelessWidget {
  final CloseoutData data;
  final bool isDark;

  const CloseoutPerformanceRow(
      {super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final accentColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    final metrics = [
      MetricData(
          'العدد الأولي', '${data.chickCount}', Icons.pets_outlined, accentColor),
      MetricData(
          'النافق',
          '${data.mortality} (${data.mortalityRate}%)',
          Icons.warning_amber_rounded,
          data.mortalityRate > 5 ? AppColors.errorColor : accentColor),
      MetricData('الباقي', '${data.liveCount}',
          Icons.check_circle_outline_rounded, const Color(0xFF6B9C5A)),
      MetricData('م. الوزن', '${data.avgWeight.toStringAsFixed(2)} كجم',
          Icons.monitor_weight_outlined, AppColors.accentColor),
    ];

    return Row(
      children: metrics.map((m) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  m.color.withValues(alpha: isDark ? 0.18 : 0.1),
                  m.color.withValues(alpha: isDark ? 0.05 : 0.02),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: m.color.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                Icon(m.icon, size: 20.sp, color: m.color),
                SizedBox(height: 6.h),
                Text(m.label,
                    style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    textAlign: TextAlign.center),
                SizedBox(height: 4.h),
                FittedBox(
                  child: Text(m.value,
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class CloseoutKpiGrid extends StatelessWidget {
  final CloseoutData data;
  final bool isDark;

  const CloseoutKpiGrid({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark
        ? AppColors.darkSurfaceElevatedColor
        : AppColors.lightCardBackgroundColor;
    final dimColor =
        isDark ? AppColors.darkOutlineColor : AppColors.lightOutlineColor;
    final accentColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    final kpis = [
      MetricData('FCR', data.fcr.toStringAsFixed(2),
          Icons.restaurant_outlined, accentColor),
      MetricData('EPEF', data.epef.toStringAsFixed(0), Icons.speed_outlined,
          AppColors.secondaryColor),
      MetricData('تكلفة الفرخ', '${data.costPerBird.toStringAsFixed(1)} ج',
          Icons.attach_money, AppColors.accentColor),
      MetricData('إجمالي العلف', '${data.totalFeed.toStringAsFixed(0)} كجم',
          Icons.grain_outlined, isDark ? AppColors.darkSecondaryColor : const Color(0xFF8B7E6A)),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildKpiCard(kpis[0], isDark, surfaceColor, dimColor)),
            SizedBox(width: 8.w),
            Expanded(child: _buildKpiCard(kpis[1], isDark, surfaceColor, dimColor)),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(child: _buildKpiCard(kpis[2], isDark, surfaceColor, dimColor)),
            SizedBox(width: 8.w),
            Expanded(child: _buildKpiCard(kpis[3], isDark, surfaceColor, dimColor)),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard(
      MetricData kpi, bool isDark, Color surfaceColor, Color dimColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: dimColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(kpi.label,
                  style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : Colors.grey[600])),
              SizedBox(width: 6.w),
              Icon(kpi.icon, size: 16.sp, color: kpi.color),
            ],
          ),
          SizedBox(height: 8.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              kpi.value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: kpi.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CloseoutBenchmarkRow extends StatelessWidget {
  final CloseoutData data;
  final bool isDark;

  const CloseoutBenchmarkRow(
      {super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (data.expectedWeight <= 0) return const SizedBox.shrink();

    final diff = data.avgWeight - data.expectedWeight;
    final isAbove = diff >= 0;
    final pctDiff =
        data.expectedWeight > 0 ? (diff / data.expectedWeight * 100) : 0.0;
    final color = isAbove ? AppColors.successColor : AppColors.warningColor;
    final surfaceColor = isDark
        ? AppColors.darkSurfaceElevatedColor
        : AppColors.lightCardBackgroundColor;

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'مقارنة بالقياسي',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'الفعلي: ${fmtWeight(data.avgWeight)} | القياسي: ${fmtWeight(data.expectedWeight)} (${isAbove ? '+' : ''}${pctDiff.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAbove ? Icons.thumb_up_outlined : Icons.thumb_down_outlined,
              color: color,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }
}
