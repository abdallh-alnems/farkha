import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../data/data_source/static/chicken_data.dart';
import '../../../logic/controller/cycle_controller.dart';

class GrowthCurveCard extends StatelessWidget {
  const GrowthCurveCard({super.key});

  static const double _maxReasonableGramsPerBird = 5000;

  double _normalizeWeightToGrams(CycleController cycleCtrl, double rawWeight) {
    if (rawWeight <= 0) return 0;

    if (rawWeight > 10.0) {
      final cycle = cycleCtrl.currentCycle;
      final chickCount =
          int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0;
      final mortality =
          int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
      final aliveChickens = chickCount - mortality;
      if (aliveChickens > 0) {
        final perBirdGrams = (rawWeight / aliveChickens) * 1000;
        if (perBirdGrams <= _maxReasonableGramsPerBird) return perBirdGrams;
      }
      if (rawWeight <= _maxReasonableGramsPerBird) return rawWeight;
      return 0;
    }
    return rawWeight * 1000;
  }

  DateTime? _parseFlexibleDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    var parsed = DateTime.tryParse(dateStr);
    if (parsed != null) return parsed;
    parsed = DateTime.tryParse(dateStr.replaceAll('/', '-'));
    return parsed;
  }

  int _calculateAgeInDays(String? startDateRaw) {
    if (startDateRaw == null || startDateRaw.isEmpty) return 0;
    final startDate = _parseFlexibleDate(startDateRaw);
    if (startDate == null) return 0;
    final ageDays = DateTime.now().difference(startDate).inDays + 1;
    return ageDays.clamp(0, weightsList.length);
  }

  int _dayOfCycle(String? startDateRaw, String entryDateStr) {
    if (startDateRaw == null || startDateRaw.isEmpty) return 0;
    final startDate = _parseFlexibleDate(startDateRaw);
    if (startDate == null) return 0;
    final entryDate = _parseFlexibleDate(entryDateStr);
    if (entryDate == null) return 0;
    final day = entryDate.difference(startDate).inDays + 1;
    return day.clamp(1, weightsList.length);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cycleCtrl = Get.find<CycleController>();

    return Obx(() {
      final startDateRaw =
          cycleCtrl.currentCycle['startDateRaw']?.toString() ?? '';
      final currentAgeDays = _calculateAgeInDays(startDateRaw);

      if (currentAgeDays <= 0) return const SizedBox.shrink();

      final rawEntries =
          cycleCtrl.currentCycle['averageWeightEntries'] as List<dynamic>?;

      final maxDay = currentAgeDays.clamp(1, weightsList.length);

      final standardSpots = <FlSpot>[];
      for (int i = 0; i < maxDay; i++) {
        standardSpots
            .add(FlSpot((i + 1).toDouble(), weightsList[i].toDouble()));
      }

      final actualSpots = <FlSpot>[];
      if (rawEntries != null) {
        for (final raw in rawEntries) {
          final map = raw as Map<String, dynamic>;
          final entryDateStr = (map['date'] ?? '').toString();
          final rawWeight =
              ((map['weight'] ?? 0.0) as num).toDouble();
          final day = _dayOfCycle(startDateRaw, entryDateStr);
          if (day >= 1 && day <= maxDay) {
            final grams = _normalizeWeightToGrams(cycleCtrl, rawWeight);
            if (grams > 0) {
              actualSpots.add(FlSpot(day.toDouble(), grams));
            }
          }
        }
      }
      actualSpots.sort((a, b) => a.x.compareTo(b.x));

      final maxY = _calculateMaxY(standardSpots, actualSpots);

      final hasActualData = actualSpots.isNotEmpty;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceElevatedColor
              : AppColors.lightCardBackgroundColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.show_chart_rounded,
                  color: isDark
                      ? AppColors.darkPrimaryColor
                      : AppColors.primaryColor,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'منحنى النمو',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkPrimaryColor : Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                _buildLegend(isDark, hasActualData),
              ],
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 220.h,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    verticalInterval: _calculateInterval(maxDay.toDouble()),
                    horizontalInterval: _calculateInterval(maxY),
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.06),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.06),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          'العمر (يوم)',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color:
                                isDark ? Colors.grey[400] : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      axisNameSize: 22.h,
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24.h,
                        interval: _calculateXLabelInterval(maxDay),
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Text(
                          'جرام',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color:
                                isDark ? Colors.grey[400] : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      axisNameSize: 22.h,
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42.w,
                        interval: _calculateYLabelInterval(maxY),
                        getTitlesWidget: (value, meta) {
                          String text;
                          if (value >= 1000) {
                            text = '${(value / 1000).toStringAsFixed(1)}ك';
                          } else {
                            text = value.toInt().toString();
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: maxDay.toDouble(),
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    _buildStandardLine(standardSpots, isDark),
                    if (hasActualData) _buildActualLine(actualSpots, isDark),
                  ],
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipRoundedRadius: 8.r,
                      tooltipPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      tooltipMargin: 8,
                      getTooltipColor: (spot) => isDark
                          ? const Color(0xff2C3A52)
                          : Colors.white,
                      tooltipBorder: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                      ),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final dayNum = spot.x.toInt();
                          final weightGrams = spot.y.toInt();
                          String label;
                          Color color;
                          if (spot.barIndex == 0) {
                            label = 'القياسي: $weightGrams جم';
                            color = isDark
                                ? Colors.grey[400]!
                                : Colors.grey[600]!;
                          } else {
                            label = 'الفعلي: $weightGrams جم';
                            color = AppColors.primaryColor;
                          }
                          return LineTooltipItem(
                            'يوم $dayNum\n$label',
                            TextStyle(
                              fontSize: 11.sp,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                            textDirection: TextDirection.rtl,
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLegend(bool isDark, bool hasActualData) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasActualData) ...[
          _legendItem(
            color: AppColors.primaryColor,
            label: 'الفعلي',
            isDark: isDark,
            isDashed: false,
          ),
          SizedBox(width: 10.w),
        ],
        _legendItem(
          color: isDark ? Colors.grey[500]! : Colors.grey[400]!,
          label: 'القياسي',
          isDark: isDark,
          isDashed: true,
        ),
      ],
    );
  }

  Widget _legendItem({
    required Color color,
    required String label,
    required bool isDark,
    required bool isDashed,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDashed)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6.w, height: 2, color: color),
              SizedBox(width: 2.w),
              Container(width: 4.w, height: 2, color: color),
              SizedBox(width: 2.w),
              Container(width: 6.w, height: 2, color: color),
            ],
          )
        else
          Container(
            width: 16.w,
            height: 2.5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  LineChartBarData _buildStandardLine(List<FlSpot> spots, bool isDark) {
    final color = isDark ? Colors.grey[500]! : Colors.grey[400]!;
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      preventCurveOverShooting: true,
      color: color,
      barWidth: 2,
      dashArray: [6, 4],
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: isDark ? 0.04 : 0.06),
      ),
    );
  }

  LineChartBarData _buildActualLine(List<FlSpot> spots, bool isDark) {
    final color = isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      preventCurveOverShooting: true,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      isStrokeJoinRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 3.5,
            color: color,
            strokeWidth: 1.5,
            strokeColor: isDark
                ? AppColors.darkSurfaceElevatedColor
                : AppColors.lightCardBackgroundColor,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: isDark ? 0.15 : 0.12),
            color.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      shadow: Shadow(
        color: color.withValues(alpha: 0.2),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    );
  }

  double _calculateMaxY(List<FlSpot> standard, List<FlSpot> actual) {
    double maxVal = 100;
    for (final s in standard) {
      if (s.y > maxVal) maxVal = s.y;
    }
    final ceiling = maxVal * 2.5;
    for (final s in actual) {
      if (s.y > maxVal && s.y <= ceiling) maxVal = s.y;
    }
    return (maxVal * 1.15).ceilToDouble();
  }

  double _calculateInterval(double max) {
    if (max <= 0) return 100;
    final raw = max / 5;
    final logVal = log(raw) / ln10;
    final magnitude = pow(10, logVal.floor()).toDouble();
    final residual = raw / magnitude;
    double nice;
    if (residual <= 1.5) {
      nice = 1;
    } else if (residual <= 3) {
      nice = 2;
    } else if (residual <= 7) {
      nice = 5;
    } else {
      nice = 10;
    }
    return nice * magnitude;
  }

  double _calculateXLabelInterval(int maxDay) {
    if (maxDay <= 10) return 1;
    if (maxDay <= 20) return 2;
    if (maxDay <= 35) return 5;
    return 7;
  }

  double _calculateYLabelInterval(double maxY) {
    if (maxY <= 200) return 50;
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    if (maxY <= 2000) return 500;
    return 500;
  }
}
