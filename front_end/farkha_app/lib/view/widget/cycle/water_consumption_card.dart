import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';

class WaterConsumptionCard extends StatelessWidget {
  const WaterConsumptionCard({super.key});

  static const Color _waterColor = Color(0xFF2196F3);

  String _formatValue(num value) {
    final d = value.toDouble();
    if (d == d.roundToDouble()) return d.round().toString();
    return d.toStringAsFixed(1);
  }

  String _formatDaily(int dailyConsumptionMl) {
    if (dailyConsumptionMl < 1000) return _formatValue(dailyConsumptionMl);
    return _formatValue(dailyConsumptionMl / 1000.0);
  }

  String _getDailyUnit(int dailyConsumptionMl) {
    return dailyConsumptionMl < 1000 ? 'مل' : 'لتر';
  }

  String _formatTotal(double totalLiters) {
    if (totalLiters < 1) return _formatValue(totalLiters * 1000);
    if (totalLiters < 1000) return _formatValue(totalLiters);
    return _formatValue(totalLiters / 1000.0);
  }

  String _getTotalUnit(double totalLiters) {
    if (totalLiters < 1) return 'مل';
    if (totalLiters < 1000) return 'لتر';
    return 'م³';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final broilerCtrl = Get.find<BroilerController>();

    return Obx(() {
      final dailyConsumptionMl =
          broilerCtrl.showData.value ? broilerCtrl.dailyWaterConsumption : 0;
      final totalConsumption =
          broilerCtrl.showData.value
              ? broilerCtrl.totalWaterConsumption
              : 0.0;

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color:
              isDark
                  ? AppColors.darkSurfaceElevatedColor
                  : AppColors.lightCardBackgroundColor,
          borderRadius: BorderRadius.circular(11.r),
          border: Border.all(),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
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
                  'استهلاك المياه',
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
                    color: _waterColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: _waterColor, width: 1.5),
                  ),
                  child: Icon(
                    Icons.water_drop,
                    size: 16.sp,
                    color: _waterColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildItem(
                    label: 'اليومي',
                    value: _formatDaily(dailyConsumptionMl),
                    unit: _getDailyUnit(dailyConsumptionMl),
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
                  child: _buildItem(
                    label: 'التراكمي',
                    value: _formatTotal(totalConsumption),
                    unit: _getTotalUnit(totalConsumption),
                    icon: Icons.water_drop,
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

  Widget _buildItem({
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
              color: _waterColor.withValues(alpha: 0.8),
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
                  color: _waterColor,
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
