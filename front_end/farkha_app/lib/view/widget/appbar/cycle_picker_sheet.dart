import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';

void showCyclePickerSheet(
  BuildContext context,
  CycleController controller,
  bool isDark,
  void Function(int index)? onCycleSwitch,
) {
  final cycles = controller.cycles;
  if (cycles.length <= 1) return;

  final accentColor =
      isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
  final surfaceColor =
      isDark ? AppColors.darkSurfaceElevatedColor : AppColors.lightSurfaceColor;
  final onSurface = isDark ? Colors.white : Colors.black87;

  Get.bottomSheet<void>(
    Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(Icons.swap_horiz_rounded, size: 20.sp, color: accentColor),
                SizedBox(width: 8.w),
                Text(
                  'التنقل بين الدورات',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: onSurface,
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(cycles.length, (i) {
            final cycle = cycles[i];
            final isActive = cycle['cycle_id'] == controller.currentCycle['cycle_id'];
            final name = (cycle['name'] ?? 'دورة').toString();
            final chickCount = cycle['chickCount']?.toString() ?? '0';

            return ListTile(
              leading: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: isActive
                      ? accentColor
                      : accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: isActive
                      ? Icon(Icons.check_rounded,
                          size: 18.sp,
                          color: isDark ? AppColors.darkBackGroundColor : Colors.white)
                      : Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                ),
              ),
              title: Text(
                name,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: onSurface,
                ),
              ),
              subtitle: Text(
                '$chickCount طائر',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              trailing: isActive
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'الحالية',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    )
                  : null,
              onTap: () {
                Get.back<void>();
                if (!isActive) {
                  onCycleSwitch?.call(i);
                }
              },
            );
          }),
          SizedBox(height: 16.h),
        ],
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
  );
}
