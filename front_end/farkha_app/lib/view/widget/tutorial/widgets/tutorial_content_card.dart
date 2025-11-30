import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TutorialContentCardDefaults {
  const TutorialContentCardDefaults._();

  static const double titleSpacing = 8;

  static const double descriptionSpacing = 16;

  static const double padding = 20;

  static const double bottomMargin = 20;

  static EdgeInsetsGeometry paddingInsets() =>
      EdgeInsets.all(TutorialContentCardDefaults.padding.w);

  static EdgeInsetsGeometry bottomMarginInsets() =>
      EdgeInsets.only(bottom: TutorialContentCardDefaults.bottomMargin.h);
}

class TutorialContentCard extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> actionButtons;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final double titleSpacing;
  final double descriptionSpacing;
  final MainAxisAlignment actionsAlignment;

  const TutorialContentCard({
    super.key,
    required this.title,
    required this.description,
    required this.actionButtons,
    this.padding,
    this.margin,
    this.titleStyle,
    this.descriptionStyle,
    this.titleSpacing = TutorialContentCardDefaults.titleSpacing,
    this.descriptionSpacing = TutorialContentCardDefaults.descriptionSpacing,
    this.actionsAlignment = MainAxisAlignment.spaceBetween,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final EdgeInsetsGeometry resolvedPadding =
        padding ?? TutorialContentCardDefaults.paddingInsets();
    final EdgeInsetsGeometry resolvedMargin =
        margin ?? TutorialContentCardDefaults.bottomMarginInsets();

    return Container(
      padding: resolvedPadding,
      margin: resolvedMargin,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.outline.withOpacity(isDark ? 0.3 : 0.15),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTitle(theme, colorScheme),
          SizedBox(height: titleSpacing.h),
          _buildDescription(theme, colorScheme),
          SizedBox(height: descriptionSpacing.h),
          Row(
            mainAxisAlignment: actionsAlignment,
            children: actionButtons,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      title,
      style: titleStyle ??
          theme.textTheme.titleMedium?.copyWith(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
    );
  }

  Widget _buildDescription(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      description,
      style: descriptionStyle ??
          theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14.sp,
            color: colorScheme.onSurface.withOpacity(0.9),
          ),
    );
  }
}
