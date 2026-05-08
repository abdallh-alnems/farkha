import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/theme/theme.dart';

class CardBroilerChickenRequirements extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;

  const CardBroilerChickenRequirements({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevatedColor
            : AppColors.lightSurfaceColor,
        borderRadius: AppDimens.borderLg,
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineColor.withValues(alpha: 0.4)
              : colorScheme.primary.withValues(alpha: 0.1),
        ),
        boxShadow: isDark
            ? null
            : [AppElevation.shadow(opacity: 0.06)],
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconBadge(context, colorScheme),
          SizedBox(height: 12.h),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.07),
                borderRadius: AppDimens.borderSm,
              ),
              child: Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconBadge(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: AppDimens.borderSm,
      ),
      child: Icon(
        icon,
        color: colorScheme.primary,
        size: 18.sp,
      ),
    );
  }
}
