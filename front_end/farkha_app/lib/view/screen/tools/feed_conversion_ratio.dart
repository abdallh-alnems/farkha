import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_helpers.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/feed_conversion_ratio_controller.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tool_page_scaffold.dart';

class FeedConversionRatio extends StatefulWidget {
  FeedConversionRatio({super.key});
  final FcrController controller = Get.put(FcrController());

  @override
  State<FeedConversionRatio> createState() => _FeedConversionRatioState();
}

class _FeedConversionRatioState extends State<FeedConversionRatio>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuart,
    );
    ever(widget.controller.fcr, (_) {
      if (widget.controller.fcr.value > 0 && mounted) {
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
    widget.controller.calculateFCR();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: FeedConversionRatio, toolId: 1);

    return ToolPageScaffold(
      title: 'معامل التحويل الغذائي',
      inputChild: TwoInputFields(
        formKey: _formKey,
        firstLabel: 'العلف المستهلك',
        secondLabel: 'الوزن الحالي',
        firstHint: 'إجمالي العلف المأكول',
        secondHint: 'إجمالي وزن القطيع',
        firstController: widget.controller.feedConsumedController,
        secondController: widget.controller.currentWeightController,
        firstSuffix: 'كجم',
        secondSuffix: 'كجم',
      ),
      buttonText: 'احسب الآن',
      onButtonPressed: _onCalculatePressed,
      footerSections: [
        Obx(() {
          final value = widget.controller.fcr.value;
          final quality = widget.controller.getFcrQuality();
          if (value <= 0) return const SizedBox.shrink();

          final resultColor = getQualityColor(quality);
          final label = getQualityLabel(quality);

          return FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(_scaleAnim),
              child: Column(
                children: [
                  ToolResultCard(
                    title: 'معامل التحويل (FCR)',
                    value: formatDecimal(value, decimals: 2),
                    resultColor: resultColor,
                    badgeLabel: label,
                  ),
                  SizedBox(height: 8.h),
                  _buildGaugeIndicator(context, value, quality),
                ],
              ),
            ),
          );
        }),
        SizedBox(height: 16.h),
        _buildRangesCard(context),
        SizedBox(height: 16.h),
        const NotesCard(
          notes: [
            'معامل التحويل = العلف المستهلك ÷ الوزن المكتسب',
            'معامل التحويل أقل من 1.6 يعتبر ممتاز',
            'معامل التحويل من 1.6 إلى 1.8 يعتبر جيد',
            'معامل التحويل أكثر من 1.9 يحتاج تحسين',
            'يتم حساب معامل التحويل في نهاية دورة التربية',
          ],
        ),
        SizedBox(height: 10.h),
        const RelatedArticlesSection(relatedArticleIds: [19, 12]),
      ],
    );
  }

  Widget _buildGaugeIndicator(BuildContext context, double value, int quality) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const double maxFcr = 2.5;
    final double normalized = (value / maxFcr).clamp(0.0, 1.0);

    const List<Color> segmentColors = [
      Color(0xFF4E7A3E),
      Color(0xFF7A9E3E),
      Color(0xFFC9A83C),
      Color(0xFFC26A4A),
    ];
    const List<double> segmentStops = [0.0, 0.56, 0.72, 0.76, 1.0];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevatedColor
            : AppColors.lightSurfaceColor,
        borderRadius: AppDimens.borderMd,
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineColor.withValues(alpha: 0.4)
              : AppColors.lightOutlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 6.h),
          _GaugeBar(
            progress: normalized,
            qualityIndex: quality.clamp(0, 3),
            segmentColors: segmentColors,
            segmentStops: segmentStops,
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1.4',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4E7A3E),
                ),
              ),
              Text(
                '1.6',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7A9E3E),
                ),
              ),
              Text(
                '1.8',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC9A83C),
                ),
              ),
              Text(
                '2.0+',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC26A4A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRangesCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevatedColor
            : AppColors.lightSurfaceColor,
        borderRadius: AppDimens.borderMd,
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineColor.withValues(alpha: 0.4)
              : AppColors.lightOutlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: AppDimens.borderSm,
                ),
                child: Icon(
                  Icons.speed_outlined,
                  color: AppColors.primaryColor,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'النسب المرجعية',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _RangeRow(
            color: const Color(0xFF4E7A3E),
            range: '1.4 – 1.6',
            label: 'ممتاز',
            icon: Icons.eco_outlined,
            isDark: isDark,
          ),
          SizedBox(height: 8.h),
          _RangeRow(
            color: const Color(0xFF7A9E3E),
            range: '1.6 – 1.8',
            label: 'جيد',
            icon: Icons.thumb_up_outlined,
            isDark: isDark,
          ),
          SizedBox(height: 8.h),
          _RangeRow(
            color: const Color(0xFFC9A83C),
            range: '1.8 – 1.9',
            label: 'مقبول',
            icon: Icons.trending_flat_rounded,
            isDark: isDark,
          ),
          SizedBox(height: 8.h),
          _RangeRow(
            color: const Color(0xFFC26A4A),
            range: '> 1.9',
            label: 'ضعيف',
            icon: Icons.trending_up_rounded,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _GaugeBar extends StatelessWidget {
  final double progress;
  final int qualityIndex;
  final List<Color> segmentColors;
  final List<double> segmentStops;

  const _GaugeBar({
    required this.progress,
    required this.qualityIndex,
    required this.segmentColors,
    required this.segmentStops,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: 22.h,
          width: width,
          child: CustomPaint(
            painter: _GaugePainter(
              progress: progress,
              segmentColors: segmentColors,
              segmentStops: segmentStops,
              trackColor: isDark
                  ? AppColors.darkOutlineColor.withValues(alpha: 0.4)
                  : AppColors.lightOutlineColor.withValues(alpha: 0.4),
            ),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final List<Color> segmentColors;
  final List<double> segmentStops;
  final Color trackColor;

  _GaugePainter({
    required this.progress,
    required this.segmentColors,
    required this.segmentStops,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.fill;

    final trackRrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(trackRrect, trackPaint);

    final fillWidth = size.width * progress;
    if (fillWidth > 0) {
      for (int i = 0; i < segmentColors.length; i++) {
        final segStart = segmentStops[i] * size.width;
        final segEnd = segmentStops[i + 1] * size.width;
        final drawStart = math.max(segStart, 0.0);
        final drawEnd = math.min(segEnd, fillWidth);

        if (drawEnd <= drawStart) continue;

        final segPaint = Paint()
          ..color = segmentColors[i]
          ..style = PaintingStyle.fill;

        final leftRadius = i == 0 ? Radius.circular(size.height / 2) : Radius.zero;
        final rightRadius = drawEnd >= fillWidth - 0.5
            ? Radius.circular(size.height / 2)
            : Radius.zero;

        final segRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(drawStart, 0, drawEnd - drawStart, size.height),
          topLeft: leftRadius,
          bottomLeft: leftRadius,
          topRight: rightRadius,
          bottomRight: rightRadius,
        );
        canvas.drawRRect(segRect, segPaint);
      }

      final indicatorX = fillWidth.clamp(8.0, size.width - 8.0);
      final indicatorPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final indicatorShadow = Paint()
        ..color = const Color(0xFF000000).withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(indicatorX, size.height / 2 + 0.5),
        7,
        indicatorShadow,
      );
      canvas.drawCircle(
        Offset(indicatorX, size.height / 2),
        6,
        indicatorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _RangeRow extends StatelessWidget {
  final Color color;
  final String range;
  final String label;
  final IconData icon;
  final bool isDark;

  const _RangeRow({
    required this.color,
    required this.range,
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.06),
        borderRadius: AppDimens.borderSm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: 8.w),
          Text(
            range,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(width: 6.w),
          Container(
            width: 1.w,
            height: 14.h,
            color: color.withValues(alpha: 0.3),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
