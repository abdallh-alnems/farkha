import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/theme/theme.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({super.key, required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final accentColor = isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
    final surfaceColor = isDark
        ? AppColors.darkSurfaceElevatedColor
        : AppColors.lightCardBackgroundColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimens.borderMd,
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: AppDimens.borderMd,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.25),
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 3.5.h,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppDimens.radiusMd),
                    topRight: Radius.circular(AppDimens.radiusMd),
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
