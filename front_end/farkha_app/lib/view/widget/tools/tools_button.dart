import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/theme/theme.dart';

class ToolsButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ToolsButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: isDark ? 0 : AppElevation.sm,
          shadowColor: colorScheme.primary.withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calculate_outlined, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              text,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
