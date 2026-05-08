import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../data/data_source/static/chicken_data.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';
import '../../../logic/controller/tools_controller/darkness_schedule_controller.dart';
import 'farm_darkness_section.dart';

class FarmTab extends StatelessWidget {
  const FarmTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final broilerCtrl = Get.find<BroilerController>();
    final scheduleCtrl = Get.isRegistered<DarknessScheduleController>()
        ? Get.find<DarknessScheduleController>()
        : null;

    return Obx(() {
      final requiredArea = broilerCtrl.requiredArea.value;
      final totalArea = broilerCtrl.collegeArea;

      final int age = broilerCtrl.selectedChickenAge.value == null
          ? 0
          : (broilerCtrl.selectedChickenAge.value as num).toInt();

      final int totalDarkHours =
          (age >= 1 && age <= darknessLevels.length)
              ? darknessLevels[age - 1]
              : 0;

      final bool manualActive =
          scheduleCtrl?.manualDarknessActive.value ?? false;
      final Duration? remaining =
          manualActive ? scheduleCtrl?.remainingManualDarkness : null;
      if (manualActive && scheduleCtrl != null) {
        scheduleCtrl.manualDarknessTicker.value;
      }
      scheduleCtrl?.phaseReminderUpdateTrigger.value;

      final int phases = scheduleCtrl?.numberOfPhasesForToday ?? 0;
      final int phasesCompleted = scheduleCtrl?.phasesCompletedToday.value ?? 0;
      final DateTime? nextAlarm = scheduleCtrl?.nextAlarmTime;

      final surfaceColor =
          isDark ? AppColors.darkSurfaceElevatedColor : AppColors.lightSurfaceColor;
      final dimColor = isDark ? AppColors.darkOutlineColor : AppColors.lightOutlineColor;
      final accentColor =
          isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
        child: Column(
          children: [
            _buildAreaSection(
              requiredArea: requiredArea,
              totalArea: totalArea,
              isDark: isDark,
              surfaceColor: surfaceColor,
              dimColor: dimColor,
              accentColor: accentColor,
            ),
            SizedBox(height: 16.h),
            FarmDarknessSection(
              totalHours: totalDarkHours,
              phases: phases,
              phasesCompleted: phasesCompleted,
              nextAlarm: nextAlarm,
              manualActive: manualActive,
              remaining: remaining,
              scheduleCtrl: scheduleCtrl,
              isDark: isDark,
              surfaceColor: surfaceColor,
              dimColor: dimColor,
              accentColor: accentColor,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAreaSection({
    required double requiredArea,
    required double totalArea,
    required bool isDark,
    required Color surfaceColor,
    required Color dimColor,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
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
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.crop_free_outlined, size: 18.sp, color: accentColor),
              ),
              SizedBox(width: 10.w),
              Text(
                'المساحة',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.grey[200] : Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _areaValue(
                  label: 'المطلوبة',
                  value: '${requiredArea.round()}',
                  unit: 'م²',
                  isDark: isDark,
                  accentColor: accentColor,
                  surfaceColor: surfaceColor,
                  dimColor: dimColor,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _areaValue(
                  label: 'الكلية',
                  value: '${totalArea.round()}',
                  unit: 'م²',
                  isDark: isDark,
                  accentColor: accentColor,
                  surfaceColor: surfaceColor,
                  dimColor: dimColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _areaValue({
    required String label,
    required String value,
    required String unit,
    required bool isDark,
    required Color accentColor,
    required Color surfaceColor,
    required Color dimColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: dimColor),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
