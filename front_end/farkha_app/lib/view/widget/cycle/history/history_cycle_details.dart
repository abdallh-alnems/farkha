import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CycleItemMetrics extends StatelessWidget {
  final String chickCount;
  final String liveCount;
  final String mortality;
  final String mortalityRate;
  final String costPerBird;
  final String fcr;
  final double averageWeight;
  final ColorScheme colorScheme;

  const CycleItemMetrics({
    super.key,
    required this.chickCount,
    required this.liveCount,
    required this.mortality,
    required this.mortalityRate,
    required this.costPerBird,
    required this.fcr,
    required this.averageWeight,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
      child: Column(
        children: [
          _ChickCountCard(
            initialCount: chickCount,
            liveCount: liveCount,
            colorScheme: colorScheme,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _PremiumMetricBox(
                  label: 'النافق',
                  value: '$mortality ($mortalityRate%)',
                  accentColor: const Color(0xFFF43F5E),
                  colorScheme: colorScheme,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _PremiumMetricBox(
                  label: 'تكلفة الفرخ',
                  value: costPerBird,
                  accentColor: const Color(0xFFF59E0B),
                  colorScheme: colorScheme,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _PremiumMetricBox(
                  label: 'معامل التحويل',
                  value: fcr,
                  accentColor: const Color(0xFF6366F1),
                  colorScheme: colorScheme,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _PremiumMetricBox(
                  label: 'متوسط الوزن',
                  value: '${averageWeight.toStringAsFixed(1)} كجم',
                  accentColor: const Color(0xFF9333EA),
                  colorScheme: colorScheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChickCountCard extends StatelessWidget {
  final String initialCount;
  final String liveCount;
  final ColorScheme colorScheme;

  const _ChickCountCard({
    required this.initialCount,
    required this.liveCount,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.03),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  initialCount,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'العدد الأولي',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  liveCount,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF10B981),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'المتبقي',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumMetricBox extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;
  final ColorScheme colorScheme;

  const _PremiumMetricBox({
    required this.label,
    required this.value,
    required this.accentColor,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.03),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Container(
                width: 3.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CycleItemFooter extends StatelessWidget {
  final double totalFeed;
  final double totalExpenses;
  final double totalSales;
  final double netProfit;
  final bool isDark;
  final ColorScheme colorScheme;

  const CycleItemFooter({
    super.key,
    required this.totalFeed,
    required this.totalExpenses,
    required this.totalSales,
    required this.netProfit,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black12 : const Color(0xFFF8FAFC),
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _FooterStat(
              label: 'العلف',
              value: totalFeed.toStringAsFixed(0),
              unit: 'كجم',
              colorScheme: colorScheme,
            ),
            _FooterDivider(colorScheme: colorScheme),
            _FooterStat(
              label: 'المصروفات',
              value: totalExpenses.toStringAsFixed(0),
              unit: 'ج',
              colorScheme: colorScheme,
            ),
            _FooterDivider(colorScheme: colorScheme),
            _FooterStat(
              label: 'المبيعات',
              value: totalSales.toStringAsFixed(0),
              unit: 'ج',
              colorScheme: colorScheme,
            ),
            _FooterDivider(colorScheme: colorScheme),
            _FooterStat(
              label: 'الصافي',
              value: netProfit.toStringAsFixed(0),
              unit: 'ج',
              valueColor:
                  netProfit >= 0
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF43F5E),
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color? valueColor;
  final ColorScheme colorScheme;

  const _FooterStat({
    required this.label,
    required this.value,
    required this.unit,
    this.valueColor,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: valueColor ?? colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterDivider extends StatelessWidget {
  final ColorScheme colorScheme;

  const _FooterDivider({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30.h,
      color: colorScheme.outline.withValues(alpha: 0.3),
    );
  }
}
