import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/theme/theme.dart';

class FeasibilityWidgets {
  static void _showHelpPopup(
    BuildContext anchorContext,
    String title,
    String helpText,
  ) {
    final renderBox = anchorContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final colorScheme = Theme.of(anchorContext).colorScheme;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenSize = MediaQuery.sizeOf(anchorContext);
    final rect = RelativeRect.fromRect(
      Rect.fromLTWH(position.dx, position.dy, size.width, size.height),
      Offset.zero & screenSize,
    );

    showMenu<void>(
      context: anchorContext,
      position: rect,
      shape: RoundedRectangleBorder(borderRadius: AppDimens.borderLg),
      color: colorScheme.surface,
      elevation: AppElevation.lg,
      items: [
        PopupMenuItem<void>(
          enabled: false,
          padding: EdgeInsets.all(16.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 280.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  helpText,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildModernSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevatedColor : colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineColor.withValues(alpha: 0.4)
              : AppColors.lightOutlineColor.withValues(alpha: 0.6),
        ),
        boxShadow: isDark
            ? null
            : [
                AppElevation.shadow(
                  opacity: 0.06,
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: 16.w,
              end: 16.w,
              top: 14.h,
              bottom: 6.h,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: color, size: 18.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark
                ? AppColors.darkOutlineColor.withValues(alpha: 0.3)
                : AppColors.lightOutlineColor.withValues(alpha: 0.4),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  static Widget buildResultCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    Color? valueColor,
    String? subtitle,
    String? helpText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedValueColor =
        valueColor ?? (isDark ? colorScheme.primary : color);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceColor
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16.sp,
                    color: resolvedValueColor.withValues(alpha: 0.7),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: colorScheme.onSurface.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (helpText != null) ...[
                    SizedBox(width: 4.w),
                    Builder(
                      builder: (iconContext) => GestureDetector(
                        onTap: () => _showHelpPopup(
                          iconContext,
                          title,
                          helpText,
                        ),
                        child: Icon(
                          Icons.help_outline_rounded,
                          size: 16.sp,
                          color: colorScheme.onSurface.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: resolvedValueColor,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: 6.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.sp,
                color: resolvedValueColor.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ],
      ),
    );
  }

  static Widget buildCostDistributionBar({
    required BuildContext context,
    required double chickenCost,
    required double feedCost,
    required double overheadCost,
    String? helpText,
  }) {
    final totalCost = chickenCost + feedCost + overheadCost;
    if (totalCost <= 0) return const SizedBox.shrink();

    final chickenPct = (chickenCost / totalCost * 100).round();
    final feedPct = (feedCost / totalCost * 100).round();
    final overheadPct = (overheadCost / totalCost * 100).round();

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const chickenColor = AppColors.accentColor;
    const feedColor = AppColors.primaryColor;
    const overheadColor = AppColors.secondaryColor;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceColor
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 16.sp,
                color: colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'توزيع التكاليف',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              if (helpText != null) ...[
                SizedBox(width: 6.w),
                Builder(
                  builder: (iconContext) => GestureDetector(
                    onTap: () => _showHelpPopup(
                      iconContext,
                      'توزيع التكاليف',
                      helpText,
                    ),
                    child: Icon(
                      Icons.help_outline_rounded,
                      size: 16.sp,
                      color: colorScheme.onSurface.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: SizedBox(
              height: 20.h,
              child: Row(
                children: [
                  if (chickenPct > 0)
                    Expanded(
                      flex: chickenPct,
                      child: Container(color: chickenColor),
                    ),
                  if (feedPct > 0)
                    Expanded(
                      flex: feedPct,
                      child: Container(color: feedColor),
                    ),
                  if (overheadPct > 0)
                    Expanded(
                      flex: overheadPct,
                      child: Container(color: overheadColor),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            children: [
              _buildLegendChip(
                context,
                'الكتاكيت',
                chickenPct,
                chickenColor,
                isDark,
              ),
              _buildLegendChip(context, 'العلف', feedPct, feedColor, isDark),
              _buildLegendChip(
                context,
                'النثريات',
                overheadPct,
                overheadColor,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildLegendChip(
    BuildContext context,
    String label,
    int percent,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.h,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            '$label $percent%',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
