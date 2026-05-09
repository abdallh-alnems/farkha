import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/theme/colors.dart';
import '../../../../logic/controller/cycle_controller.dart';
import '../../../../logic/controller/tools_controller/broiler_controller.dart';

class ConsumptionRow extends StatelessWidget {
  const ConsumptionRow({
    super.key,
    required this.broilerCtrl,
    required this.cycleCtrl,
    required this.ageDays,
    required this.isDark,
  });

  final BroilerController broilerCtrl;
  final CycleController cycleCtrl;
  final int ageDays;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final surfaceColor =
        isDark ? AppColors.darkSurfaceElevatedColor : AppColors.lightSurfaceColor;
    final dimColor = isDark ? AppColors.darkOutlineColor : AppColors.lightOutlineColor;
    final accentColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    String feedType(int age) {
      if (age < 13) return 'بادي';
      if (age < 25) return 'نامي';
      return 'ناهي';
    }

    final dailyFeedG = broilerCtrl.showData.value ? broilerCtrl.dailyFeedConsumption : 0;
    final totalFeed = broilerCtrl.showData.value ? broilerCtrl.totalFeedConsumption : 0.0;
    final consumedSoFar = _calcConsumedFeed();
    final dailyWaterMl = broilerCtrl.showData.value ? broilerCtrl.dailyWaterConsumption : 0;
    final totalWater = broilerCtrl.showData.value ? broilerCtrl.totalWaterConsumption : 0.0;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: dimColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.grain_outlined, size: 16.sp, color: accentColor),
                    SizedBox(width: 6.w),
                    Text('العلف', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: isDark ? Colors.grey[200] : Colors.grey[800])),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: AppColors.successColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(feedType(ageDays), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppColors.successColor)),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _consumptionRow('يومي', dailyFeedG < 1000 ? dailyFeedG.toString() : (dailyFeedG / 1000).round().toString(), dailyFeedG < 1000 ? 'جرام' : 'كيلو', accentColor),
                SizedBox(height: 8.h),
                _consumptionRow('حتى الآن', consumedSoFar.toStringAsFixed(0), 'كيلو', accentColor),
                SizedBox(height: 8.h),
                _consumptionRow('الكلي', totalFeed < 1000 ? totalFeed.round().toString() : (totalFeed / 1000).toStringAsFixed(1), totalFeed < 1000 ? 'كيلو' : 'طن', accentColor),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: dimColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.water_drop_outlined, size: 16.sp, color: const Color(0xFF5B8A7A)),
                    SizedBox(width: 6.w),
                    Text('المياه', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: isDark ? Colors.grey[200] : Colors.grey[800])),
                  ],
                ),
                SizedBox(height: 12.h),
                _consumptionRow('يومي', dailyWaterMl < 1000 ? dailyWaterMl.toString() : (dailyWaterMl / 1000).round().toString(), dailyWaterMl < 1000 ? 'مل' : 'لتر', const Color(0xFF5B8A7A)),
                SizedBox(height: 8.h),
                _consumptionRow(
                  'تراكمي',
                  totalWater < 1 ? (totalWater * 1000).round().toString() : totalWater < 1000 ? totalWater.toStringAsFixed(1) : (totalWater / 1000).toStringAsFixed(1),
                  totalWater < 1 ? 'مل' : totalWater < 1000 ? 'لتر' : 'م³',
                  const Color(0xFF5B8A7A),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _consumptionRow(String label, String value, String unit, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: color)),
            SizedBox(width: 3.w),
            Text(unit, style: TextStyle(fontSize: 10.sp, color: isDark ? Colors.grey[500] : Colors.grey[500])),
          ],
        ),
      ],
    );
  }

  double _calcConsumedFeed() {
    final entries = cycleCtrl.getFeedConsumptionEntries();
    double total = 0.0;
    for (var e in entries) {
      total += e.amount;
    }
    return total;
  }
}
