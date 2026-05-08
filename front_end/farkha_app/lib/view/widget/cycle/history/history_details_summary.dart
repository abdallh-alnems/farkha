import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/theme/theme.dart';

class MetricItem {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  MetricItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
}

class HistoryDateBar extends StatelessWidget {
  final String startDate;
  final String endDate;
  final String cycleAge;
  final String space;
  final bool isDark;
  final ColorScheme colorScheme;

  const HistoryDateBar({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.cycleAge,
    required this.space,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14.sp,
                      color: AppColors.primaryColor,
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        startDate,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  '—',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 14.sp,
                      color: AppColors.successColor,
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        endDate,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _buildDateChip(
                Icons.timelapse_rounded,
                '$cycleAge يوم',
                AppColors.accentColor,
              ),
              SizedBox(width: 10.w),
              if (space.isNotEmpty && space != '0') ...[
                _buildDateChip(
                  Icons.square_foot_outlined,
                  '$space م\u00B2',
                  AppColors.infoColor,
                ),
                SizedBox(width: 10.w),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryMetricsGrid extends StatelessWidget {
  final bool isDark;
  final ColorScheme colorScheme;
  final List<MetricItem> items;

  const HistoryMetricsGrid({
    super.key,
    required this.isDark,
    required this.colorScheme,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(5.r),
                    decoration: BoxDecoration(
                      color:
                          item.color.withValues(alpha: isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(item.icon, size: 14.sp, color: item.color),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                item.value,
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

class HistoryFinancialCard extends StatelessWidget {
  final String costPerBird;
  final double totalFeed;
  final double totalExpenses;
  final double totalSales;
  final double netProfit;
  final VoidCallback? onExpensesTap;
  final bool isDark;
  final ColorScheme colorScheme;

  const HistoryFinancialCard({
    super.key,
    required this.costPerBird,
    required this.totalFeed,
    required this.totalExpenses,
    required this.totalSales,
    required this.netProfit,
    this.onExpensesTap,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.4)),
      ),
      padding: EdgeInsets.all(18.r),
      child: Column(
        children: [
          _buildFinancialRow(
            icon: Icons.egg_outlined,
            title: 'تكلفة الفرخ',
            value: '$costPerBird ج',
            color: AppColors.secondaryColor,
          ),
          Divider(
            color: colorScheme.outline.withValues(alpha: 0.2),
            height: 28.h,
          ),
          _buildFinancialRow(
            icon: Icons.agriculture_outlined,
            title: 'إجمالي العلف',
            value: '${totalFeed.toStringAsFixed(0)} كجم',
            color: AppColors.accentColor,
          ),
          Divider(
            color: colorScheme.outline.withValues(alpha: 0.2),
            height: 28.h,
          ),
          _buildFinancialRow(
            icon: Icons.trending_down_rounded,
            title: 'المصروفات الكلية',
            value: '${totalExpenses.toStringAsFixed(0)} ج',
            color: AppColors.errorColor,
            onTap: onExpensesTap,
          ),
          Divider(
            color: colorScheme.outline.withValues(alpha: 0.2),
            height: 28.h,
          ),
          _buildFinancialRow(
            icon: Icons.trending_up_rounded,
            title: 'المبيعات الكلية',
            value: '${totalSales.toStringAsFixed(0)} ج',
            color: AppColors.successColor,
          ),
          SizedBox(height: 16.h),
          _buildNetProfitHero(),
        ],
      ),
    );
  }

  Widget _buildFinancialRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 16.sp, color: color),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onTap != null) ...[
              Icon(
                Icons.chevron_left,
                size: 16.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              SizedBox(width: 4.w),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: 15.sp,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetProfitHero() {
    final isPositive = netProfit >= 0;
    final color = isPositive ? AppColors.successColor : AppColors.errorColor;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: color,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التصفية (الصافي)',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${netProfit.toStringAsFixed(0)} ج',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: -0.5,
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

class HistorySectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final ColorScheme colorScheme;
  final Widget? suffix;

  const HistorySectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.colorScheme,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.primaryColor),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}
