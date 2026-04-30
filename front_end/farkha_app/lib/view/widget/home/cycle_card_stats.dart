import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/theme/colors.dart';

class CycleCardStatsRow extends StatelessWidget {
  const CycleCardStatsRow({
    super.key,
    required this.age,
    required this.liveCount,
    required this.totalExpenses,
    required this.costPerChick,
    required this.isDark,
  });

  final String age;
  final int liveCount;
  final double totalExpenses;
  final double costPerChick;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Center(
            child: _buildInfoItem('العمر', age),
          ),
        ),
        Expanded(
          child: Center(
            child: _buildInfoItem('العدد', '$liveCount'),
          ),
        ),
        Expanded(
          child: Center(
            child: _buildInfoItem(
              'المصروفات',
              totalExpenses.toStringAsFixed(0),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: _buildInfoItem(
              'تكلفة الفرخ',
              costPerChick > 0 ? costPerChick.round().toString() : '0',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8.5.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 8.5.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
