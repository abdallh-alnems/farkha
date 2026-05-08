import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';
import 'performance/consumption_row.dart';
import 'performance/growth_chart.dart';
import 'performance/metrics_grid.dart';
import 'performance/performance_calculations.dart';

class PerformanceTab extends StatelessWidget {
  const PerformanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cycleCtrl = Get.find<CycleController>();
    final broilerCtrl = Get.find<BroilerController>();

    return Obx(() {
      final ageDays = (broilerCtrl.selectedChickenAge.value as num?)?.toInt() ?? 0;
      final canFCR = ageDays >= 15;
      final showEarly = ageDays >= 15 && ageDays < 21;
      final fcr = canFCR ? calculateFCR(cycleCtrl, broilerCtrl) : 0.0;
      final currentWeight = getCurrentAverageWeight(cycleCtrl);
      final expectedWeight = getExpectedWeight(broilerCtrl);
      final epef = calculateProductionEfficiency(cycleCtrl, broilerCtrl);
      final cost = calculateCostPerChicken(cycleCtrl);

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
        child: Column(
          children: [
            PerformanceMetricsGrid(
              fcr: fcr,
              canFCR: canFCR,
              showEarly: showEarly,
              currentWeight: currentWeight,
              expectedWeight: expectedWeight,
              epef: epef,
              cost: cost,
              isDark: isDark,
            ),
            SizedBox(height: 16.h),
            GrowthChart(cycleCtrl: cycleCtrl, isDark: isDark),
            SizedBox(height: 16.h),
            ConsumptionRow(
              broilerCtrl: broilerCtrl,
              cycleCtrl: cycleCtrl,
              ageDays: ageDays,
              isDark: isDark,
            ),
          ],
        ),
      );
    });
  }
}
