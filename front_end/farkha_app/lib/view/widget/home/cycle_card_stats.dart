import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CycleCardStatsRow extends StatelessWidget {
  const CycleCardStatsRow({
    super.key,
    required this.age,
    required this.liveCount,
    required this.totalExpenses,
    required this.costPerChick,
  });

  final String age;
  final int liveCount;
  final double totalExpenses;
  final double costPerChick;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: isDark ? 0.5 : 0.6),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.schedule_outlined,
              label: 'العمر',
              value: age,
              colorScheme: colorScheme,
            ),
          ),
          _StatDivider(colorScheme: colorScheme),
          Expanded(
            child: _StatItem(
              icon: Icons.pets_outlined,
              label: 'العدد',
              value: '$liveCount',
              colorScheme: colorScheme,
            ),
          ),
          _StatDivider(colorScheme: colorScheme),
          Expanded(
            child: _StatItem(
              icon: Icons.payments_outlined,
              label: 'المصروفات',
              value: totalExpenses.toStringAsFixed(0),
              colorScheme: colorScheme,
            ),
          ),
          _StatDivider(colorScheme: colorScheme),
          Expanded(
            child: _StatItem(
              icon: Icons.attach_money_rounded,
              label: 'تكلفة الفرخ',
              value: costPerChick > 0 ? costPerChick.round().toString() : '0',
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.sp, color: colorScheme.primary),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            height: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  final ColorScheme colorScheme;

  const _StatDivider({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.w,
      height: 24.h,
      color: colorScheme.outline.withValues(alpha: 0.2),
    );
  }
}
