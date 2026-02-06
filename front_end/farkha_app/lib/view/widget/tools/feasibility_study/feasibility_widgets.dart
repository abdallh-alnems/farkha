import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/theme/colors.dart';

class FeasibilityWidgets {
  static void _showHelpPopup(
    BuildContext anchorContext,
    String title,
    String helpText,
  ) {
    final renderBox = anchorContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final isDark = Theme.of(anchorContext).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.grey[800]!;
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: isDark ? AppColors.darkSurfaceColor : AppColors.lightSurfaceColor,
      elevation: 8,
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
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  helpText,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: textColor.withValues(alpha: 0.9),
                    height: 1.5,
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
        color:
            isDark
                ? AppColors.darkSurfaceElevatedColor
                : AppColors.lightSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        border:
            isDark
                ? Border.all(
                  color: AppColors.darkOutlineColor.withValues(alpha: 0.5),
                )
                : null,
        boxShadow:
            isDark
                ? null
                : [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: isDark ? 0.2 : 0.15),
                  color.withValues(alpha: isDark ? 0.1 : 0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, color.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow:
                        isDark
                            ? null
                            : [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 17),
                ),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? colorScheme.onSurface : color,
                    shadows:
                        isDark
                            ? null
                            : [
                              Shadow(
                                color: color.withValues(alpha: 0.2),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
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
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.darkSurfaceColor : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDark
                  ? AppColors.darkOutlineColor.withValues(alpha: 0.3)
                  : color.withValues(alpha: 0.2),
        ),
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
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color:
                          isDark
                              ? colorScheme.onSurface.withValues(alpha: 0.7)
                              : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (helpText != null) ...[
                    SizedBox(width: 4.w),
                    Builder(
                      builder:
                          (iconContext) => GestureDetector(
                            onTap:
                                () => _showHelpPopup(
                                  iconContext,
                                  title,
                                  helpText,
                                ),
                            child: Icon(
                              Icons.help_outline,
                              size: 18.sp,
                              color: (isDark
                                      ? Colors.white70
                                      : Colors.grey.shade500)
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                    ),
                  ],
                ],
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: resolvedValueColor,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: 6.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                color: resolvedValueColor.withValues(alpha: 0.9),
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    const chickenColor = Color(0xFF42A5F5);
    const feedColor = Color(0xFF66BB6A);
    const overheadColor = Color(0xFFFFB74D);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDark
                  ? [
                    AppColors.darkSurfaceColor,
                    AppColors.darkSurfaceColor.withValues(alpha: 0.95),
                  ]
                  : [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color:
              isDark
                  ? AppColors.darkOutlineColor.withValues(alpha: 0.25)
                  : Colors.grey.shade200,
        ),
        boxShadow:
            isDark
                ? null
                : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 18.sp,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              SizedBox(width: 8.w),
              Text(
                'توزيع التكاليف',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              if (helpText != null) ...[
                SizedBox(width: 6.w),
                Builder(
                  builder:
                      (iconContext) => GestureDetector(
                        onTap:
                            () => _showHelpPopup(
                              iconContext,
                              'توزيع التكاليف',
                              helpText,
                            ),
                        child: Icon(
                          Icons.help_outline,
                          size: 18.sp,
                          color: (isDark
                                  ? Colors.white70
                                  : Colors.grey.shade500)
                              .withValues(alpha: 0.8),
                        ),
                      ),
                ),
              ],
            ],
          ),
          SizedBox(height: 14.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Row(
              children: [
                if (chickenPct > 0)
                  Expanded(
                    flex: chickenPct,
                    child: Container(height: 24.h, color: chickenColor),
                  ),
                if (feedPct > 0)
                  Expanded(
                    flex: feedPct,
                    child: Container(height: 24.h, color: feedColor),
                  ),
                if (overheadPct > 0)
                  Expanded(
                    flex: overheadPct,
                    child: Container(height: 24.h, color: overheadColor),
                  ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 16.w,
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.25 : 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.5 : 0.4)),
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
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
