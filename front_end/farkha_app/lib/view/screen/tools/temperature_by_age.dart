import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/images.dart';
import '../../../core/constant/theme/theme.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/age_dropdown.dart';
import '../../../logic/controller/tools_controller/temperature_by_age_controller.dart';
import '../../../logic/controller/weather_controller.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tool_page_scaffold.dart';

class TemperatureByAgeScreen extends StatefulWidget {
  const TemperatureByAgeScreen({super.key});

  @override
  State<TemperatureByAgeScreen> createState() => _TemperatureByAgeScreenState();
}

class _TemperatureByAgeScreenState extends State<TemperatureByAgeScreen>
    with SingleTickerProviderStateMixin {
  late final TemperatureByAgeController controller;
  late final WeatherController weatherController;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  bool showResult = false;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<TemperatureByAgeController>()) {
      Get.put(TemperatureByAgeController());
    }
    if (!Get.isRegistered<WeatherController>()) {
      Get.put(WeatherController(), permanent: true);
    }
    controller = Get.find<TemperatureByAgeController>();
    weatherController = Get.find<WeatherController>();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _tempColor(int temp) {
    if (temp >= 33) return const Color(0xFFE85D3A);
    if (temp >= 29) return const Color(0xFFF0963C);
    if (temp >= 25) return const Color(0xFF6BAF5A);
    if (temp >= 21) return const Color(0xFF4A9BAF);
    return const Color(0xFF4A7AAF);
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: TemperatureByAgeScreen, toolId: 7);

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ToolPageScaffold(
      title: 'درجة الحرارة حسب العمر',
      inputChild: AgeDropdown(
        selectedAge: controller.selectedAge.value,
        onAgeChanged: (value) {
          controller.selectedAge.value = value;
          controller.calculateTemperature();
          setState(() {
            showResult = true;
          });
          _animController.forward(from: 0);
        },
      ),
      footerSections: [
        if (showResult)
          Obx(() {
            final temperature = controller.temperature.value;
            final ambientTemp = weatherController.currentTemperature.value;
            final weatherStatus = weatherController.statusRequest.value;
            if (temperature <= 0) return const SizedBox.shrink();

            final tempColor = _tempColor(temperature);
            final tempPercent =
                ((temperature - 15) / (35 - 15)).clamp(0.0, 1.0);

            return FadeTransition(
              opacity: _fadeAnim,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 12.h * (1 - _animController.value)),
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    _TempGaugeCard(
                      temperature: temperature,
                      tempColor: tempColor,
                      tempPercent: tempPercent,
                      age: controller.selectedAge.value,
                      isDark: isDark,
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: 14.h),
                    _AmbientCard(
                      tempColor: tempColor,
                      targetTemp: temperature,
                      ambientTemp: ambientTemp,
                      weatherStatus: weatherStatus,
                      hasWeatherData: weatherController.hasWeatherData,
                      isDark: isDark,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
            );
          }),
        const RelatedArticlesSection(relatedArticleIds: [14, 11]),
      ],
    );
  }
}

class _TempGaugeCard extends StatelessWidget {
  final int temperature;
  final Color tempColor;
  final double tempPercent;
  final int? age;
  final bool isDark;
  final ColorScheme colorScheme;

  const _TempGaugeCard({
    required this.temperature,
    required this.tempColor,
    required this.tempPercent,
    this.age,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 24.h, bottom: 20.h, left: 20.w, right: 20.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppDimens.borderXl,
        border: Border.all(
          color: tempColor.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1.5,
        ),
        boxShadow: isDark
            ? null
            : [
                AppElevation.shadow(opacity: 0.06),
                BoxShadow(
                  color: tempColor.withValues(alpha: 0.07),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 200.w,
            height: 108.h,
            child: CustomPaint(
              painter: _SemiGaugePainter(
                percent: tempPercent,
                color: tempColor,
                isDark: isDark,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '°$temperature',
            style: TextStyle(
              fontSize: 44.sp,
              fontWeight: FontWeight.w800,
              color: tempColor,
              height: 1.0,
              letterSpacing: -1.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'درجة الحرارة المطلوبة',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (age != null)
            Padding(
              padding: EdgeInsets.only(top: 3.h),
              child: Text(
                'اليوم $age',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AmbientCard extends StatelessWidget {
  final Color tempColor;
  final int targetTemp;
  final double ambientTemp;
  final StatusRequest weatherStatus;
  final bool hasWeatherData;
  final bool isDark;
  final ColorScheme colorScheme;

  const _AmbientCard({
    required this.tempColor,
    required this.targetTemp,
    required this.ambientTemp,
    required this.weatherStatus,
    required this.hasWeatherData,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: tempColor.withValues(alpha: isDark ? 0.1 : 0.06),
        borderRadius: AppDimens.borderLg,
        border: Border.all(
          color: tempColor.withValues(alpha: isDark ? 0.22 : 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.thermostat, color: tempColor, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(child: _ambientContent),
            ],
          ),
          if (hasWeatherData && weatherStatus != StatusRequest.loading) ...[
            SizedBox(height: 12.h),
            _diffIndicator,
          ],
        ],
      ),
    );
  }

  Widget get _ambientContent {
    if (weatherStatus == StatusRequest.loading) {
      return Row(
        children: [
          Text(
            'درجة حرارة الجو: ',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          Lottie.asset(AppImages.loading, width: 36.w, height: 36.h),
        ],
      );
    }
    if (hasWeatherData) {
      return Text(
        'درجة حرارة الجو: °${formatDecimal(ambientTemp, decimals: 0)}',
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      );
    }
    return Text(
      'درجة حرارة الجو: فعّل صلاحية الموقع',
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget get _diffIndicator {
    final diff = ambientTemp - targetTemp;
    final absDiff = diff.abs();

    String label;
    Color color;
    IconData icon;

    if (absDiff <= 2) {
      label = 'الحرارة مناسبة';
      color = const Color(0xFF4E7A3E);
      icon = Icons.check_circle_rounded;
    } else if (diff > 0) {
      label = 'الجو أسخن بـ ${formatDecimal(absDiff, decimals: 0)}°';
      color = const Color(0xFFE85D3A);
      icon = Icons.keyboard_arrow_up;
    } else {
      label = 'الجو أبرد بـ ${formatDecimal(absDiff, decimals: 0)}°';
      color = const Color(0xFF4A7AAF);
      icon = Icons.keyboard_arrow_down;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: AppDimens.borderMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SemiGaugePainter extends CustomPainter {
  final double percent;
  final Color color;
  final bool isDark;

  _SemiGaugePainter({
    required this.percent,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = math.min(size.width / 2, size.height) - 10;
    const strokeWidth = 14.0;

    final bgPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.07)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    // Tick marks
    final tickPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i <= 10; i++) {
      final angle = math.pi + (math.pi * i / 10);
      final innerR = radius - 10;
      final outerR = radius + 10;
      canvas.drawLine(
        Offset(
          center.dx + innerR * math.cos(angle),
          center.dy + innerR * math.sin(angle),
        ),
        Offset(
          center.dx + outerR * math.cos(angle),
          center.dy + outerR * math.sin(angle),
        ),
        tickPaint,
      );
    }

    // Active arc with gradient
    if (percent > 0) {
      final activePaint = Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;
      activePaint.shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.35),
          color,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      final sweepAngle = math.pi * percent;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        sweepAngle,
        false,
        activePaint,
      );

      // Indicator dot at the end of active arc
      final dotAngle = math.pi + (math.pi * percent);
      final dotX = center.dx + radius * math.cos(dotAngle);
      final dotY = center.dy + radius * math.sin(dotAngle);

      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 11, glowPaint);

      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 6, dotPaint);

      final innerPaint = Paint()
        ..color = isDark ? const Color(0xFF252118) : Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 3, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SemiGaugePainter old) =>
      old.percent != percent || old.color != color;
}
