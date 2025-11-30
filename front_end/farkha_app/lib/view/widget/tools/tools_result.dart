import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ToolsResult extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final bool showUnitAfterValue;

  const ToolsResult({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.showUnitAfterValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color titleColor = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.w600,
            color: titleColor.withOpacity(0.85),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 9.h),
        Text(
          showUnitAfterValue ? value : (unit != null ? '$value $unit' : value),
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
