import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ToolsResult extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final Color? titleColor;
  final Color? valueColor;
  final double? fontSize;
  final bool showUnitAfterValue;

  const ToolsResult({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.titleColor,
    this.valueColor,
    this.fontSize,
    this.showUnitAfterValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: titleColor ?? Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        Text(
          showUnitAfterValue ? value : (unit != null ? '$value $unit' : value),
          style: TextStyle(
            fontSize: fontSize ?? 40.sp,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class ToolsResultCard extends StatelessWidget {
  final String title;
  final String value;
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final Color valueColor;

  const ToolsResultCard({
    super.key,
    required this.title,
    required this.value,
    required this.backgroundColor,
    required this.borderColor,
    required this.titleColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(11.w),
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
