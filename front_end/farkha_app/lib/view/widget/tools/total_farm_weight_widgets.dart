import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_helpers.dart';

class FormulaStrip extends StatelessWidget {
  const FormulaStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: AppDimens.borderMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.functions,
            size: 18.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.45),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'عدد الطيور × متوسط وزن الفرخ = الوزن الإجمالي',
              style: TextStyle(
                fontSize: 12.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.55),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeightBreakdown extends StatelessWidget {
  final int birds;
  final double avgWeight;
  final double totalWeight;

  const WeightBreakdown({
    super.key,
    required this.birds,
    required this.avgWeight,
    required this.totalWeight,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevatedColor
            : AppColors.lightSurfaceColor,
        borderRadius: AppDimens.borderMd,
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineColor.withValues(alpha: 0.4)
              : AppColors.lightOutlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(
                    alpha: isDark ? 0.2 : 0.1,
                  ),
                  borderRadius: AppDimens.borderSm,
                ),
                child: Icon(
                  Icons.monitor_weight_outlined,
                  color: AppColors.primaryColor,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'تفاصيل الحساب',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          BreakdownRow(
            icon: Icons.pets_outlined,
            label: 'عدد الطيور',
            value: '$birds طائر',
            color: colorScheme.onSurface.withValues(alpha: 0.75),
            isDark: isDark,
          ),
          SizedBox(height: 6.h),
          BreakdownRow(
            icon: Icons.scale_outlined,
            label: 'متوسط وزن الفرخ',
            value: '${formatDecimal(avgWeight)} كجم',
            color: colorScheme.onSurface.withValues(alpha: 0.75),
            isDark: isDark,
          ),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Divider(
              height: 1,
              color: colorScheme.outline.withValues(alpha: 0.25),
            ),
          ),
          SizedBox(height: 2.h),
          BreakdownRow(
            icon: Icons.dataset_outlined,
            label: 'الوزن الإجمالي',
            value: '${formatDecimal(totalWeight, decimals: 0)} كجم',
            color: getToolResultColor(context),
            highlight: true,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class BreakdownRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool highlight;
  final bool isDark;

  const BreakdownRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: highlight
          ? BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.12 : 0.06),
              borderRadius: AppDimens.borderSm,
            )
          : null,
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 14.sp : 13.sp,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class TonConversionCard extends StatelessWidget {
  final double totalWeightKg;

  const TonConversionCard({super.key, required this.totalWeightKg});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tons = totalWeightKg / 1000;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppDimens.borderMd,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 18.sp,
                color: AppColors.accentColor,
              ),
              SizedBox(width: 6.w),
              Text(
                'بالطن',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          Text(
            tons >= 1
                ? '${formatDecimal(tons)} طن'
                : '${formatDecimal(tons, decimals: 2)} طن',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.accentColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class StepByStepGuide extends StatelessWidget {
  const StepByStepGuide({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevatedColor
            : AppColors.lightSurfaceColor,
        borderRadius: AppDimens.borderMd,
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineColor.withValues(alpha: 0.4)
              : AppColors.lightOutlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withValues(
                    alpha: isDark ? 0.2 : 0.1,
                  ),
                  borderRadius: AppDimens.borderSm,
                ),
                child: Icon(
                  Icons.tips_and_updates_outlined,
                  color: AppColors.secondaryColor,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'كيف تحسب الوزن بدقة؟',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          StepItem(
            number: 1,
            text: 'اختر 10 فراخ عشوائيًا من مختلف أماكن العنبر',
            isDark: isDark,
          ),
          SizedBox(height: 10.h),
          StepItem(
            number: 2,
            text: 'وزّن كل فرخة وسجّل الأوزان',
            isDark: isDark,
          ),
          SizedBox(height: 10.h),
          StepItem(
            number: 3,
            text: 'اجمع الأوزان واقسم على 10 للحصول على المتوسط',
            isDark: isDark,
          ),
          SizedBox(height: 10.h),
          StepItem(
            number: 4,
            text: 'اضرب المتوسط في إجمالي عدد الطيور',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class StepItem extends StatelessWidget {
  final int number;
  final String text;
  final bool isDark;

  const StepItem({
    super.key,
    required this.number,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26.w,
          height: 26.w,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor.withValues(
              alpha: isDark ? 0.2 : 0.12,
            ),
            borderRadius: AppDimens.borderSm,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.secondaryColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 3.h),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.45,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
