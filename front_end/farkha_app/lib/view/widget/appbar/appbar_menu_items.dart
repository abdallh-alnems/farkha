import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/theme/colors.dart';

PopupMenuItem<String> buildMenuHeader(String title) {
  return PopupMenuItem<String>(
    enabled: false,
    height: 32.h,
    child: Text(
      title,
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryColor,
        letterSpacing: 0.3,
      ),
    ),
  );
}

PopupMenuItem<String> buildMenuItem(
  BuildContext context,
  String value,
  IconData icon,
  String text, {
  Color? color,
}) {
  return PopupMenuItem(
    value: value,
    height: 40.h,
    child: Row(
      children: [
        Icon(icon, size: 18.sp, color: color ?? Theme.of(context).colorScheme.onSurface),
        SizedBox(width: 10.w),
        Text(
          text,
          style: TextStyle(
            color: color ?? Theme.of(context).colorScheme.onSurface,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
