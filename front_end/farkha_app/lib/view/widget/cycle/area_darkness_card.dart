import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../data/data_source/static/chicken_data.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';

class AreaDarknessCard extends StatelessWidget {
  const AreaDarknessCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final broilerCtrl = Get.find<BroilerController>();

    return Obx(() {
      final requiredArea = broilerCtrl.requiredArea.value;
      final totalArea = broilerCtrl.collegeArea;
      final selectedAge = broilerCtrl.selectedChickenAge.value;
      final darkness = selectedAge != null && selectedAge > 0 && selectedAge <= darknessLevels.length
          ? darknessLevels[selectedAge - 1]
          : 0;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color:
              isDark
                  ? AppColors.darkSurfaceElevatedColor
                  : AppColors.lightCardBackgroundColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المزرعة',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkPrimaryColor : Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    label: 'المساحة المطلوبة',
                    value: '${requiredArea.round()} م²',
                    color: AppColors.primaryColor,
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildInfoItem(
                    label: 'المساحة الكلية',
                    value: '${totalArea.round()} م²',
                    color: AppColors.primaryColor,
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildInfoItem(
                    label: 'الإظلام',
                    value: '$darkness ساعة',
                    color: AppColors.primaryColor,
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

  Widget _buildInfoItem({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      height: 85.h,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [
                    color.withValues(alpha: 0.18),
                    color.withValues(alpha: 0.12),
                    color.withValues(alpha: 0.06),
                  ]
                  : [
                    color.withValues(alpha: 0.25),
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.08),
                  ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.1 : 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: value.length > 15 ? 11.sp : 17.sp,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark
                            ? AppColors.darkPrimaryColor
                            : AppColors.primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
