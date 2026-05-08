import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/chicken_age_count_input.dart';
import '../../../logic/controller/tools_controller/water_consumption_controller.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tool_page_scaffold.dart';

class WaterConsumption extends StatefulWidget {
  const WaterConsumption({super.key});

  @override
  State<WaterConsumption> createState() => _WaterConsumptionState();
}

class _WaterConsumptionState extends State<WaterConsumption>
    with SingleTickerProviderStateMixin {
  late final WaterConsumptionController _controller;
  late final AnimationController _anim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(WaterConsumptionController());
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: WaterConsumption, toolId: 23);

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const waterColor = AppColors.infoColor;

    return ToolPageScaffold(
      title: 'استهلاك الماء',
      inputChild: ChickenAgeCountInput(
        controller: _controller.textController,
        selectedAge: _controller.selectedAge.value,
        onAgeChanged: (v) => _controller.selectedAge.value = v,
        validateCount: false,
        countSuffix: 'فرخ',
      ),
      buttonText: 'احسب استهلاك الماء',
      onButtonPressed: () {
        _controller.calculateWaterConsumption();
        if (_controller.resultDaily.value.isNotEmpty) {
          _anim.forward(from: 0);
        }
      },
      footerSections: [
        Obx(() {
          final daily = _controller.resultDaily.value;
          final weekly = _controller.resultWeekly.value;
          final toEnd = _controller.resultToEndOfCycle.value;
          if (daily.isEmpty) return const SizedBox.shrink();

          return FadeTransition(
            opacity: _fadeAnim,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 14.h * (1 - _anim.value)),
                  child: child,
                );
              },
              child: Column(
                children: [
                  _HeroCard(
                    value: daily,
                    waterColor: waterColor,
                    isDark: isDark,
                    colorScheme: colorScheme,
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.calendar_today_rounded,
                          label: 'الأسبوعي',
                          value: weekly,
                          waterColor: waterColor,
                          isDark: isDark,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.flag_rounded,
                          label: 'حتى نهاية الدورة',
                          value: toEnd,
                          suffix: '٣٥ يوم',
                          waterColor: waterColor,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        SizedBox(height: 16.h),
        const NotesCard(
          title: '💧 نصائح استهلاك الماء',
          notes: [
            'استهلاك الماء يزداد تدريجياً مع تقدم عمر الطيور',
            'درجة الحرارة العالية تزيد الاستهلاك بنسبة ٢٠-٥٠٪',
            'تأكد من توفر مياه نظيفة وباردة دائماً',
            'استهلاك الماء اليومي = استهلاك الفرخ × عدد الفراخ',
          ],
        ),
        const RelatedArticlesSection(relatedArticleIds: []),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String value;
  final Color waterColor;
  final bool isDark;
  final ColorScheme colorScheme;

  const _HeroCard({
    required this.value,
    required this.waterColor,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.only(
        top: 24.h,
        bottom: 8.h,
        start: 20.w,
        end: 20.w,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppDimens.borderXl,
        border: Border.all(
          color: waterColor.withValues(alpha: isDark ? 0.3 : 0.18),
          width: 1.5,
        ),
        boxShadow: isDark
            ? null
            : [
                AppElevation.shadow(opacity: 0.05),
                BoxShadow(
                  color: waterColor.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: waterColor.withValues(alpha: isDark ? 0.15 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.water_drop_rounded,
              color: waterColor,
              size: 30.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'الاستهلاك اليومي',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
              color: waterColor,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'لكل القطيع',
            style: TextStyle(
              fontSize: 12.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 24.h,
            width: double.infinity,
            child: CustomPaint(
              painter: _WavePainter(
                color: waterColor.withValues(alpha: isDark ? 0.1 : 0.07),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? suffix;
  final Color waterColor;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.suffix,
    required this.waterColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppDimens.borderLg,
        border: Border.all(
          color: waterColor.withValues(alpha: isDark ? 0.2 : 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: waterColor),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: waterColor,
            ),
          ),
          if (suffix != null) ...[
            SizedBox(height: 2.h),
            Text(
              suffix!,
              style: TextStyle(
                fontSize: 10.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;

  const _WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.5);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.5 +
          math.sin(x / size.width * 2 * math.pi) * size.height * 0.2;
      path.lineTo(x, y);
    }

    path
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.color != color;
}
