import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/age_dropdown.dart';
import '../../../logic/controller/tools_controller/darkness_levels_controller.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tool_page_scaffold.dart';

class DarknessLevelsScreen extends StatelessWidget {
  const DarknessLevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DarknessLevelsController controller = Get.put(DarknessLevelsController());

    logToolPageViewOnce(widgetType: DarknessLevelsScreen, toolId: 8);

    return ToolPageScaffold(
      title: 'ساعات الاظلام',
      inputChild: AgeDropdown(
        key: ValueKey(controller.selectedDay.value),
        selectedAge: controller.selectedDay.value,
        onAgeChanged: (value) => controller.setDay(value),
        maxAge: controller.maxDay,
      ),
      footerSections: [
        Obx(() {
          final darknessHours = controller.darkness;
          final lightHours = controller.light;
          final hasValidDay = controller.selectedDay.value != null &&
              darknessHours != null &&
              lightHours != null;

          if (!hasValidDay) return const SizedBox.shrink();

          return _DarknessResult(darknessHours: darknessHours, lightHours: lightHours);
        }),
        const NotesCard(
          notes: [
            'يتم تطبيق الإظلام تدريجياً حسب عمر الطائر.',
            'أقصى مدة للظلام ساعتين في المرة الواحدة الباقي من ساعات الإظلام يقسم على باقي اليوم',
            'الاظلام عملية مهمة جدا في  النمو',
          ],
        ),
        const RelatedArticlesSection(relatedArticleIds: [9]),
      ],
    );
  }
}

class _DarknessResult extends StatelessWidget {
  final int darknessHours;
  final int lightHours;

  const _DarknessResult({required this.darknessHours, required this.lightHours});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final darknessRatio = darknessHours / 24.0;
    final sweepAngle = darknessRatio * 2 * math.pi;

    final darkSegmentColor = isDark
        ? const Color(0xFF5C4A7A)
        : const Color(0xFF4A3F6B);
    final lightSegmentColor = isDark
        ? const Color(0xFF8FBC8F)
        : const Color(0xFFD4A843);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: AppDimens.borderLg,
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.4),
              ),
              boxShadow: isDark ? null : [AppElevation.shadow(opacity: 0.06)],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DayNightDial(
                      sweepAngle: sweepAngle,
                      darkColor: darkSegmentColor,
                      lightColor: lightSegmentColor,
                      darknessHours: darknessHours,
                      lightHours: lightHours,
                      isDark: isDark,
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HourLabel(
                            icon: Icons.nights_stay_rounded,
                            label: 'ساعات الإظلام',
                            hours: darknessHours,
                            color: darkSegmentColor,
                            isDark: isDark,
                          ),
                          SizedBox(height: 16.h),
                          _HourLabel(
                            icon: Icons.wb_sunny_rounded,
                            label: 'ساعات الإضاءة',
                            hours: lightHours,
                            color: lightSegmentColor,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                _SplitBar(
                  darknessRatio: darknessRatio,
                  darkColor: darkSegmentColor,
                  lightColor: lightSegmentColor,
                  isDark: isDark,
                ),
                SizedBox(height: 12.h),
                Text(
                  'اليوم ${darknessHours + lightHours} ساعة — إظلام $darknessHours | إضاءة $lightHours',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayNightDial extends StatelessWidget {
  final double sweepAngle;
  final Color darkColor;
  final Color lightColor;
  final int darknessHours;
  final int lightHours;
  final bool isDark;

  const _DayNightDial({
    required this.sweepAngle,
    required this.darkColor,
    required this.lightColor,
    required this.darknessHours,
    required this.lightHours,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 110.w,
      height: 110.w,
      child: CustomPaint(
        painter: _DialPainter(
          sweepAngle: sweepAngle,
          darkColor: darkColor,
          lightColor: lightColor,
          trackColor: colorScheme.outline.withValues(alpha: 0.15),
          strokeWidth: 12.w,
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: darknessHours == 0
                ? Icon(
                    Icons.wb_sunny_rounded,
                    key: const ValueKey('sun'),
                    size: 28.sp,
                    color: lightColor,
                  )
                : Icon(
                    Icons.nights_stay_rounded,
                    key: const ValueKey('moon'),
                    size: 28.sp,
                    color: darkColor,
                  ),
          ),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  final double sweepAngle;
  final Color darkColor;
  final Color lightColor;
  final Color trackColor;
  final double strokeWidth;

  _DialPainter({
    required this.sweepAngle,
    required this.darkColor,
    required this.lightColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - strokeWidth / 2;
    const startAngle = -math.pi / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final darkPaint = Paint()
      ..color = darkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (sweepAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        darkPaint,
      );
    }

    final lightPaint = Paint()
      ..color = lightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final lightSweep = (2 * math.pi) - sweepAngle;
    if (lightSweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + sweepAngle,
        lightSweep,
        false,
        lightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) =>
      oldDelegate.sweepAngle != sweepAngle;
}

class _HourLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final int hours;
  final Color color;
  final bool isDark;

  const _HourLabel({
    required this.icon,
    required this.label,
    required this.hours,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.sp, color: color),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '$hours ساعة',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SplitBar extends StatelessWidget {
  final double darknessRatio;
  final Color darkColor;
  final Color lightColor;
  final bool isDark;

  const _SplitBar({
    required this.darknessRatio,
    required this.darkColor,
    required this.lightColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.r),
      child: SizedBox(
        height: 8.h,
        child: Row(
          children: [
            Expanded(
              flex: (darknessRatio * 1000).round().clamp(1, 999),
              child: Container(
                decoration: BoxDecoration(
                  color: darkColor.withValues(alpha: isDark ? 0.7 : 0.85),
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(6.r),
                    bottomStart: Radius.circular(6.r),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: ((1 - darknessRatio) * 1000).round().clamp(1, 999),
              child: Container(
                decoration: BoxDecoration(
                  color: lightColor.withValues(alpha: isDark ? 0.7 : 0.85),
                  borderRadius: BorderRadiusDirectional.only(
                    topEnd: Radius.circular(6.r),
                    bottomEnd: Radius.circular(6.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
