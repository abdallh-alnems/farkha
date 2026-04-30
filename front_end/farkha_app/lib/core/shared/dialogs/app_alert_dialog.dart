import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constant/theme/colors.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurfaceColor : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bodyTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final effectiveIconBgColor =
        iconBgColor ?? iconColor.withValues(alpha: isDark ? 0.2 : 0.1);

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
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
              child: Icon(icon, size: 40.sp, color: iconColor),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
                color: bodyTextColor,
              ),
            ),
            SizedBox(height: 24.h),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    if (secondaryActionLabel != null && secondaryAction != null) {
      return Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: secondaryAction,
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: Text(
                secondaryActionLabel!,
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(child: _buildPrimaryButton()),
        ],
      );
    }

    return SizedBox(width: double.infinity, child: _buildPrimaryButton());
  }

  Widget _buildPrimaryButton() {
    return ElevatedButton(
      onPressed: primaryAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 12.h),
      ),
      child: Text(
        primaryActionLabel,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
      ),
    );
  }
}
