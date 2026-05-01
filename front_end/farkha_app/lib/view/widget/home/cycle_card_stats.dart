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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Center(
            child: _buildInfoItem('العمر', age, colorScheme),
          ),
        ),
        Expanded(
          child: Center(
            child: _buildInfoItem('العدد', '$liveCount', colorScheme),
          ),
        ),
        Expanded(
          child: Center(
            child: _buildInfoItem(
              'المصروفات',
              totalExpenses.toStringAsFixed(0),
              colorScheme,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: _buildInfoItem(
              'تكلفة الفرخ',
              costPerChick > 0 ? costPerChick.round().toString() : '0',
              colorScheme,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8.5.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 8.5.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
