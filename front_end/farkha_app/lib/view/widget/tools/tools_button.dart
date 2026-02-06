import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/theme/colors.dart';

class ToolsButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ToolsButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.primaryColor : colorScheme.primary;
    final foregroundColor = isDark ? Colors.white : colorScheme.onPrimary;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 2,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
