import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constant/theme/theme.dart';

enum AppButtonVariant { primary, outlined, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;
  final bool loading;
  final double? fontSize;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.fullWidth = true,
    this.loading = false,
    this.fontSize,
    this.borderRadius = 12,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (variant == AppButtonVariant.text) {
      return TextButton(
        onPressed: loading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: foregroundColor ?? colorScheme.primary,
          padding: padding ??
              EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),
          ),
        ),
        child: _buildChild(colorScheme, isText: true),
      );
    }

    final bgColor = backgroundColor ?? colorScheme.primary;
    final fgColor = foregroundColor ?? colorScheme.onPrimary;

    Widget button = ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            variant == AppButtonVariant.outlined ? Colors.transparent : bgColor,
        foregroundColor:
            variant == AppButtonVariant.outlined ? bgColor : fgColor,
        disabledBackgroundColor:
            variant == AppButtonVariant.outlined
                ? Colors.transparent
                : bgColor.withValues(alpha: 0.5),
        padding: padding ??
            EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.r),
          side: variant == AppButtonVariant.outlined
              ? BorderSide(color: bgColor, width: 1.5)
              : BorderSide.none,
        ),
        elevation: variant == AppButtonVariant.outlined ? 0 : AppElevation.sm,
      ),
      child: _buildChild(colorScheme),
    );

    if (fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildChild(ColorScheme colorScheme, {bool isText = false}) {
    if (loading) {
      return SizedBox(
        height: 20.h,
        width: 20.h,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color:
              isText
                  ? colorScheme.onSurface
                  : variant == AppButtonVariant.outlined
                  ? colorScheme.primary
                  : colorScheme.onPrimary,
        ),
      );
    }

    final effectiveFontSize = fontSize ?? 15.sp;
    final child = Text(
      label,
      style: TextStyle(
        fontSize: effectiveFontSize,
        fontWeight: FontWeight.w600,
      ),
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: effectiveFontSize + 2),
          SizedBox(width: 8.w),
          Flexible(child: child),
        ],
      );
    }

    return child;
  }
}
