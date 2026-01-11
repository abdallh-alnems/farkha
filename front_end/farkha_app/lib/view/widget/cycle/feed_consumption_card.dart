import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';

class FeedConsumptionCard extends StatelessWidget {
  const FeedConsumptionCard({super.key});

  // لون ثابت لجميع أنواع العلف
  static const Color _feedTypeColor = Color(0xFF4CAF50); // أخضر

  String _getFeedType(int ageDays) {
    if (ageDays < 13) {
      return 'بادي';
    } else if (ageDays < 25) {
      return 'نامي';
    } else {
      return 'ناهي';
    }
  }

  Color _getFeedTypeColor(String type) {
    return _feedTypeColor;
  }

  String _formatDailyConsumption(int dailyConsumptionGrams) {
    if (dailyConsumptionGrams < 1000) {
      return dailyConsumptionGrams.toString();
    } else {
      final kg = (dailyConsumptionGrams / 1000.0).round();
      return kg.toString();
    }
  }

  String _getDailyConsumptionUnit(int dailyConsumptionGrams) {
    return dailyConsumptionGrams < 1000 ? 'جرام' : 'كيلو';
  }

  String _formatTotalConsumption(double totalConsumptionKg) {
    if (totalConsumptionKg < 1000) {
      return totalConsumptionKg.round().toString();
    } else {
      final ton = totalConsumptionKg / 1000.0;
      return ton.toStringAsFixed(1);
    }
  }

  String _getTotalConsumptionUnit(double totalConsumptionKg) {
    return totalConsumptionKg < 1000 ? 'كيلو' : 'طن';
  }

  double _calculateConsumedFeedSoFar(CycleController cycleCtrl) {
    final entries = cycleCtrl.getFeedConsumptionEntries();
    double total = 0.0;
    for (var entry in entries) {
      total += entry.amount;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final broilerCtrl = Get.find<BroilerController>();
    final cycleCtrl = Get.find<CycleController>();

    return Obx(() {
      final ageDays = broilerCtrl.selectedChickenAge.value ?? 0;
      final feedType = _getFeedType(ageDays);
      final feedTypeColor = _getFeedTypeColor(feedType);
      // dailyFeedConsumption بالجرام
      final dailyConsumptionGrams =
          broilerCtrl.showData.value ? broilerCtrl.dailyFeedConsumption : 0;
      final totalConsumption =
          broilerCtrl.showData.value ? broilerCtrl.totalFeedConsumption : 0.0;

      final consumedSoFar = _calculateConsumedFeedSoFar(cycleCtrl);

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color:
              isDark
                  ? AppColors.darkSurfaceElevatedColor
                  : AppColors.lightCardBackgroundColor,
          borderRadius: BorderRadius.circular(11.r),
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'استهلاك العلف',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark
                            ? AppColors.darkPrimaryColor
                            : AppColors.primaryColor,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: feedTypeColor.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: feedTypeColor, width: 1.5),
                  ),
                  child: Text(
                    feedType,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: feedTypeColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildConsumptionItem(
                    label: 'اليومي',
                    value: _formatDailyConsumption(dailyConsumptionGrams),
                    unit: _getDailyConsumptionUnit(dailyConsumptionGrams),
                    icon: Icons.today,
                    isDark: isDark,
                  ),
                ),
                Container(
                  width: 1.w,
                  height: 50.h,
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  color:
                      isDark
                          ? AppColors.darkOutlineColor
                          : AppColors.lightOutlineColor,
                ),
                Expanded(
                  child: _buildConsumptionItem(
                    label: 'حتى الآن',
                    value: consumedSoFar.toStringAsFixed(0),
                    unit: 'كيلو',
                    icon: Icons.timeline,
                    isDark: isDark,
                  ),
                ),
                Container(
                  width: 1.w,
                  height: 50.h,
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  color:
                      isDark
                          ? AppColors.darkOutlineColor
                          : AppColors.lightOutlineColor,
                ),
                Expanded(
                  child: _buildConsumptionItem(
                    label: 'الكلي',
                    value: _formatTotalConsumption(totalConsumption),
                    unit: _getTotalConsumptionUnit(totalConsumption),
                    icon: Icons.inventory_2,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildConsumptionItem({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18.sp,
              color:
                  isDark
                      ? AppColors.darkPrimaryColor.withOpacity(0.8)
                      : AppColors.primaryColor.withOpacity(0.7),
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? Colors.grey[300] : Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color:
                      isDark
                          ? AppColors.darkPrimaryColor
                          : AppColors.primaryColor,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
