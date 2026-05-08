import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/theme/colors.dart';
import '../../../../data/data_source/static/chicken_data.dart';
import '../../../../logic/controller/cycle_controller.dart';
import 'performance_calculations.dart';

class GrowthChart extends StatelessWidget {
  const GrowthChart({
    super.key,
    required this.cycleCtrl,
    required this.isDark,
  });

  final CycleController cycleCtrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final startDateRaw = cycleCtrl.currentCycle['startDateRaw']?.toString() ?? '';
    final currentAgeDays = calcAgeDays(startDateRaw);
    if (currentAgeDays <= 0) return const SizedBox.shrink();

    final rawEntries = cycleCtrl.currentCycle['averageWeightEntries'] as List<dynamic>?;
    final maxDay = currentAgeDays.clamp(1, weightsList.length);

    final standardSpots = <FlSpot>[];
    for (int i = 0; i < maxDay; i++) {
      standardSpots.add(FlSpot((i + 1).toDouble(), weightsList[i].toDouble()));
    }

    final actualSpots = <FlSpot>[];
    if (rawEntries != null) {
      for (final raw in rawEntries) {
        final map = raw as Map<String, dynamic>;
        final entryDateStr = (map['date'] ?? '').toString();
        final rawWeight = ((map['weight'] ?? 0.0) as num).toDouble();
        final day = dayOfCycle(startDateRaw, entryDateStr);
        if (day >= 1 && day <= maxDay) {
          final grams = normalizeWeightToGrams(cycleCtrl, rawWeight);
          if (grams > 0) actualSpots.add(FlSpot(day.toDouble(), grams));
        }
      }
    }
    actualSpots.sort((a, b) => a.x.compareTo(b.x));

    double maxY = 100;
    for (final s in standardSpots) {
      if (s.y > maxY) maxY = s.y;
    }
    for (final s in actualSpots) {
      if (s.y > maxY && s.y <= maxY * 2.5) maxY = s.y;
    }
    maxY = (maxY * 1.15).ceilToDouble();

    final accentColor = isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
    final surfaceColor =
        isDark ? AppColors.darkSurfaceElevatedColor : AppColors.lightSurfaceColor;
    final dimColor = isDark ? AppColors.darkOutlineColor : AppColors.lightOutlineColor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: dimColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart_rounded, color: accentColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'منحنى النمو',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.grey[200] : Colors.grey[800],
                ),
              ),
              const Spacer(),
              if (actualSpots.isNotEmpty) ...[
                Container(
                  width: 14.w,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                SizedBox(width: 4.w),
                Text('الفعلي', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                SizedBox(width: 10.w),
              ],
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 5.w, height: 2, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  SizedBox(width: 2.w),
                  Container(width: 3.w, height: 2, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  SizedBox(width: 2.w),
                  Container(width: 5.w, height: 2, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                ],
              ),
              SizedBox(width: 4.w),
              Text('القياسي', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : Colors.grey[600])),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 200.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  verticalInterval: chartInterval(maxDay.toDouble()),
                  horizontalInterval: chartInterval(maxY),
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (v) => FlLine(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles()),
                  rightTitles: const AxisTitles(sideTitles: SideTitles()),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text('العمر (يوم)', style: TextStyle(fontSize: 10.sp, color: isDark ? Colors.grey[500] : Colors.grey[600], fontWeight: FontWeight.w600)),
                    ),
                    axisNameSize: 20.h,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22.h,
                      interval: maxDay <= 10 ? 1 : maxDay <= 20 ? 2 : maxDay <= 35 ? 5 : 7.0,
                      getTitlesWidget: (v, meta) => SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(v.toInt().toString(), style: TextStyle(fontSize: 9.sp, color: isDark ? Colors.grey[500] : Colors.grey[700], fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Text('جرام', style: TextStyle(fontSize: 10.sp, color: isDark ? Colors.grey[500] : Colors.grey[600], fontWeight: FontWeight.w600)),
                    ),
                    axisNameSize: 20.h,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38.w,
                      interval: maxY <= 200 ? 50.0 : maxY <= 500 ? 100.0 : maxY <= 1000 ? 200.0 : 500.0,
                      getTitlesWidget: (v, meta) {
                        final text = v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}ك' : v.toInt().toString();
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(text, style: TextStyle(fontSize: 9.sp, color: isDark ? Colors.grey[500] : Colors.grey[700], fontWeight: FontWeight.w500)),
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
                  LineChartBarData(
                    spots: standardSpots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    preventCurveOverShooting: true,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                    barWidth: 2,
                    dashArray: [6, 4],
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: (isDark ? Colors.grey[500] : Colors.grey[400])!.withValues(alpha: 0.05)),
                  ),
                  if (actualSpots.isNotEmpty)
                    LineChartBarData(
                      spots: actualSpots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      preventCurveOverShooting: true,
                      color: accentColor,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      isStrokeJoinRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                          radius: 3.5,
                          color: accentColor,
                          strokeWidth: 1.5,
                          strokeColor: isDark ? AppColors.darkSurfaceElevatedColor : AppColors.lightCardBackgroundColor,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [accentColor.withValues(alpha: 0.12), accentColor.withValues(alpha: 0.0)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      shadow: Shadow(color: accentColor.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2)),
                    ),
                ],
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 8.r,
                    tooltipPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    tooltipMargin: 8,
                    getTooltipColor: (_) => isDark ? const Color(0xff2C3A52) : Colors.white,
                    tooltipBorder: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                    getTooltipItems: (spots) => spots.map((s) {
                      final label = s.barIndex == 0 ? 'القياسي: ${s.y.toInt()} جم' : 'الفعلي: ${s.y.toInt()} جم';
                      final color = s.barIndex == 0 ? (isDark ? Colors.grey[400]! : Colors.grey[600]!) : accentColor;
                      return LineTooltipItem('يوم ${s.x.toInt()}\n$label', TextStyle(fontSize: 11.sp, color: color, fontWeight: FontWeight.w600), textDirection: TextDirection.rtl);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
