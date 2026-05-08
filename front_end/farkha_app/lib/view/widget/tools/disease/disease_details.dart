import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/theme/colors.dart';

Widget buildSection(String title, Widget content, {required IconData icon}) {
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final colorScheme = Theme.of(context).colorScheme;
      final primaryColor =
          isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

      final surfaceColor = isDark
          ? AppColors.darkSurfaceElevatedColor
          : AppColors.lightSurfaceColor;
      final borderColor = isDark
          ? AppColors.darkOutlineColor.withValues(alpha: 0.5)
          : AppColors.lightOutlineColor.withValues(alpha: 0.3);

      return Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsetsDirectional.fromSTEB(14.w, 12.h, 14.w, 10.h),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.r),
                  topRight: Radius.circular(14.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 20.sp, color: primaryColor),
                  SizedBox(width: 8.w),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(14.w, 10.h, 14.w, 14.h),
              child: content,
            ),
          ],
        ),
      );
    },
  );
}

Widget buildList(List<String> items) {
  return Builder(
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsetsDirectional.only(end: 10.w, top: 6.h),
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.5,
                          color: colorScheme.onSurface.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      );
    },
  );
}

Widget buildCriteriaList(Map<String, List<String>> criteria) {
  return Builder(
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: criteria.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: entry.value
                      .map(
                        (v) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            v,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
        }).toList(),
      );
    },
  );
}
