import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constant/theme/theme.dart';

class ToolResultCard extends StatelessWidget {
  final String title;
  final String value;
  final Color resultColor;
  final String? badgeLabel;

  const ToolResultCard({
    super.key,
    required this.title,
    required this.value,
    required this.resultColor,
    this.badgeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            resultColor.withValues(alpha: isDark ? 0.22 : 0.1),
            resultColor.withValues(alpha: isDark ? 0.12 : 0.05),
          ],
        ),
        borderRadius: AppDimens.borderLg,
        border: Border.all(
          color: resultColor.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: resultColor,
            ),
          ),
          if (badgeLabel != null && badgeLabel!.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: resultColor.withValues(alpha: 0.18),
                borderRadius: AppDimens.borderXl,
              ),
              child: Text(
                badgeLabel!,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: resultColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
