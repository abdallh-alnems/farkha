import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constant/theme/theme.dart';

class AppAlertDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? iconBgColor;
  final String title;
  final String description;
  final String primaryActionLabel;
  final VoidCallback primaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? secondaryAction;

  const AppAlertDialog({
    super.key,
    required this.icon,
    required this.iconColor,
    this.iconBgColor,
    required this.title,
    required this.description,
    required this.primaryActionLabel,
    required this.primaryAction,
    this.secondaryActionLabel,
    this.secondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bgColor = colorScheme.surface;
    final effectiveIconBgColor =
        iconBgColor ?? iconColor.withValues(alpha: 0.12);

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: AppDimens.borderXl),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: effectiveIconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36.sp, color: iconColor),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 24.h),
            _buildActions(colorScheme, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(ColorScheme colorScheme, ThemeData theme) {
    if (secondaryActionLabel != null && secondaryAction != null) {
      return Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: secondaryAction,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurface.withValues(alpha: 0.6),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                secondaryActionLabel!,
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(child: _buildPrimaryButton(colorScheme, theme)),
        ],
      );
    }

    return SizedBox(width: double.infinity, child: _buildPrimaryButton(colorScheme, theme));
  }

  Widget _buildPrimaryButton(ColorScheme colorScheme, ThemeData theme) {
    return ElevatedButton(
      onPressed: primaryAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: AppElevation.none,
        shape: RoundedRectangleBorder(borderRadius: AppDimens.borderMd),
        padding: EdgeInsets.symmetric(vertical: 12.h),
      ),
      child: Text(
        primaryActionLabel,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
    );
  }
}
