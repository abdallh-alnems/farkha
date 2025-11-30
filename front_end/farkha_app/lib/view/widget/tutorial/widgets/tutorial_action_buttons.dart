import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/theme/colors.dart';

class TutorialActionButtons {
  const TutorialActionButtons._();

  static Widget next({
    required VoidCallback onPressed,
    double borderRadius = 8,
    String label = 'التالي',
    double fontSize = 14,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
      child: Text(label, style: TextStyle(fontSize: fontSize.sp)),
    );
  }

  static Widget finish({
    required VoidCallback onPressed,
    double borderRadius = 8,
    String label = 'إنهاء',
    double fontSize = 14,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
      child: Text(label, style: TextStyle(fontSize: fontSize.sp)),
    );
  }

  static Widget previous({
    required VoidCallback onPressed,
    String label = 'السابق',
    double fontSize = 14,
    Color? textColor,
  }) {
    return Builder(
      builder: (context) {
        final Color resolvedColor =
            textColor ?? Theme.of(context).colorScheme.onSurface;
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(foregroundColor: resolvedColor),
          child: Text(
            label,
            style: TextStyle(
              color: resolvedColor,
              fontSize: fontSize.sp,
            ),
          ),
        );
      },
    );
  }
}
