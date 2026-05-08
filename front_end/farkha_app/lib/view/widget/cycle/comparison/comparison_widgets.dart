import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/theme/theme.dart';

const List<Color> cycleColors = [
  AppColors.primaryColor,
  AppColors.accentColor,
  AppColors.secondaryColor,
];

class MetricDef {
  final String label;
  final String key;
  final String unit;
  final bool isText;
  final bool isCount;
  final bool lowerBetter;

  MetricDef(
    this.label,
    this.key,
    this.unit, {
    this.isText = false,
    this.isCount = false,
    this.lowerBetter = false,
  });
}

class CompareButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const CompareButton({super.key, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primary,
      borderRadius: AppDimens.borderMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimens.borderMd,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(borderRadius: AppDimens.borderMd),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.compare_rounded,
                size: 18.sp,
                color: colorScheme.onPrimary,
              ),
              SizedBox(width: 6.w),
              Text(
                'مقارنة ($count)',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectionHintBar extends StatelessWidget {
  final int selectedCount;
  final int totalCount;

  const SelectionHintBar({
    super.key,
    required this.selectedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.md,
        AppSpacing.screenH,
        AppSpacing.xs,
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppDimens.borderMd,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 18.sp,
            color: colorScheme.primary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'اختر دورتين أو ثلاث للمقارنة',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          SelectionCounter(current: selectedCount, total: totalCount),
        ],
      ),
    );
  }
}

class SelectionCounter extends StatelessWidget {
  final int current;
  final int total;

  const SelectionCounter({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isComplete = current >= 2;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: isComplete
            ? colorScheme.primary.withValues(alpha: 0.12)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: Text(
        '$current/$total',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          color: isComplete
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.4),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
