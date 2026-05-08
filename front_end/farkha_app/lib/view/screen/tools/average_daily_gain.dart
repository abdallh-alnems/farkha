import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_helpers.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../logic/controller/tools_controller/adg_controller.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tool_page_scaffold.dart';

class AverageDailyGain extends StatefulWidget {
  AverageDailyGain({super.key});
  final AdgController controller = Get.put(AdgController());

  @override
  State<AverageDailyGain> createState() => _AverageDailyGainState();
}

class _AverageDailyGainState extends State<AverageDailyGain>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _animController;
  late Animation<double> _gaugeAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _gaugeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );

    ever(widget.controller.adg, (_) {
      if (widget.controller.adg.value > 0) {
        _animController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onCalculatePressed() {
    if (_formKey.currentState?.validate() != true) return;
    widget.controller.calculateADG();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: AverageDailyGain, toolId: 2);
    final colorScheme = Theme.of(context).colorScheme;

    return ToolPageScaffold(
      title: 'متوسط النمو اليومي',
      inputChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoHeader(colorScheme),
          SizedBox(height: 14.h),
          TwoInputFields(
            formKey: _formKey,
            firstLabel: 'العمر',
            secondLabel: 'متوسط الوزن الحالي',
            secondHint: 'وزن الفرخ الواحد',
            firstController: widget.controller.daysController,
            secondController: widget.controller.currentWeightKgController,
            firstSuffix: 'يوم',
            secondSuffix: 'كجم',
          ),
        ],
      ),
      buttonText: 'احسب ADG',
      onButtonPressed: _onCalculatePressed,
      footerSections: [
        Obx(() {
          final value = widget.controller.adg.value;
          final quality = widget.controller.getAdgQuality();
          if (value <= 0) return const SizedBox.shrink();

          final resultColor = getQualityColor(quality);
          final label = getQualityLabel(quality);

          return Column(
            children: [
              _buildGaugeResult(value, resultColor, label),
              SizedBox(height: 16.h),
            ],
          );
        }),
        _buildReferenceRanges(context),
        const NotesCard(
          notes: [
            'بعد عمر 7 أيام يفضل حساب متوسط زيادة الوزن',
            'ارتفاع متوسط زيادة الوزن يدل على سرعة نمو جيدة',
            'لحساب الوزن الكلي للقطيع: زن 10 فراخ عشوائيًا احسب المتوسط ثم اضربه في عدد الطيور',
          ],
        ),
        const RelatedArticlesSection(relatedArticleIds: [13]),
      ],
    );
  }

  Widget _buildInfoHeader(ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: AppDimens.borderMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.trending_up_rounded,
            size: 20.sp,
            color: colorScheme.primary,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              ' ADG = (الوزن الحالي − وزن الكتاكيت) ÷ العمر',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeResult(double value, Color resultColor, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clampedValue = value.clamp(0.0, 80.0);
    final normalizedValue = clampedValue / 80.0;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final animatedValue = normalizedValue * _gaugeAnim.value;
        final displayValue = value * _gaugeAnim.value;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevatedColor : AppColors.lightSurfaceColor,
            borderRadius: AppDimens.borderLg,
            border: Border.all(
              color: resultColor.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: isDark
                ? null
                : [AppElevation.shadow(opacity: 0.05)],
          ),
          child: Column(
            children: [
              Text(
                'متوسط الزيادة اليومية (ADG)',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: 180.w,
                height: 100.w,
                child: CustomPaint(
                  painter: _GaugePainter(
                    progress: animatedValue,
                    color: resultColor,
                    isDark: isDark,
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatDecimal(displayValue),
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w800,
                              color: resultColor,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'جرام / يوم',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: resultColor.withValues(alpha: 0.14),
                    borderRadius: AppDimens.borderXl,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: resultColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReferenceRanges(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceElevatedColor : AppColors.lightSurfaceColor,
          borderRadius: AppDimens.borderMd,
          border: Border.all(
            color: isDark
                ? AppColors.darkOutlineColor.withValues(alpha: 0.5)
                : AppColors.lightOutlineColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed_rounded,
                  color: colorScheme.primary,
                  size: 18.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  'النسب المرجعية',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildRangeRow(Icons.eco_rounded, Colors.green, '≥ 55', 'ممتاز'),
            SizedBox(height: 6.h),
            _buildRangeRow(Icons.check_circle_outline, Colors.orange, '45 – 55', 'جيد'),
            SizedBox(height: 6.h),
            _buildRangeRow(Icons.remove_circle_outline, Colors.amber.shade800, '35 – 45', 'مقبول'),
            SizedBox(height: 6.h),
            _buildRangeRow(Icons.trending_down_rounded, Colors.red, '< 35', 'يحتاج تحسين'),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeRow(IconData icon, Color color, String range, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 8.w),
          Text(
            '$range جرام/يوم',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppDimens.borderSm,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;

  _GaugePainter({
    required this.progress,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 8;

    final bgPaint = Paint()
      ..color = (isDark ? AppColors.darkOutlineColor : AppColors.lightOutlineColor)
          .withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;

    const startAngle = math.pi;
    const sweepAngle = math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    if (progress > 0) {
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 10;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * progress,
        false,
        fillPaint,
      );

      final indicatorAngle = startAngle + sweepAngle * progress;
      final indicatorX = center.dx + radius * math.cos(indicatorAngle);
      final indicatorY = center.dy + radius * math.sin(indicatorAngle);

      final dotPaint = Paint()..color = color;
      canvas.drawCircle(Offset(indicatorX, indicatorY), 5, dotPaint);

      final dotBorder = Paint()
        ..color = isDark ? AppColors.darkSurfaceElevatedColor : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(indicatorX, indicatorY), 5, dotBorder);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
