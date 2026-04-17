import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../data/data_source/static/chicken_data.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';
import '../../../logic/controller/tools_controller/darkness_schedule_controller.dart';
import 'darkness_settings_sheet.dart';

class DarknessScheduleCard extends StatelessWidget {
  const DarknessScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final BroilerController broilerCtrl = Get.find<BroilerController>();
    final DarknessScheduleController? scheduleCtrl =
        Get.isRegistered<DarknessScheduleController>()
            ? Get.find<DarknessScheduleController>()
            : null;

    return Obx(() {
      final int age =
          broilerCtrl.selectedChickenAge.value == null
              ? 0
              : (broilerCtrl.selectedChickenAge.value as num).toInt();

      final int totalHours =
          (age >= 1 && age <= darknessLevels.length)
              ? darknessLevels[age - 1]
              : 0;

      final bool manualActive =
          scheduleCtrl?.manualDarknessActive.value ?? false;
      final Duration? remaining =
          manualActive ? scheduleCtrl?.remainingManualDarkness : null;
      // Trigger update on tick
      if (manualActive && scheduleCtrl != null) {
        scheduleCtrl.manualDarknessTicker.value;
      }
      // Ensure update when settings change
      scheduleCtrl?.phaseReminderUpdateTrigger.value;

      final int phases = scheduleCtrl?.numberOfPhasesForToday ?? 0;
      final int phasesCompleted = scheduleCtrl?.phasesCompletedToday.value ?? 0;
      final double periodHours =
          scheduleCtrl?.periodLengthHoursForDisplay ?? 0.0;

      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color:
              isDark
                  ? AppColors.darkSurfaceElevatedColor
                  : AppColors.lightCardBackgroundColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color:
                isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context, isDark, scheduleCtrl),
            SizedBox(height: 20.h),
            if (manualActive && remaining != null)
              _buildActiveTimer(context, remaining, isDark)
            else
              _buildIdleView(
                context,
                totalHours,
                phases,
                periodHours,
                phasesCompleted,
                isDark,
              ),
            SizedBox(height: 20.h),
            _buildActionButtons(
              context,
              manualActive,
              scheduleCtrl,
              isDark,
              totalHours > 0,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    DarknessScheduleController? ctrl,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? Colors.deepPurple.withValues(alpha: 0.2)
                        : Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.nightlight_round,
                color:
                    isDark
                        ? Colors.deepPurple.shade200
                        : Colors.deepPurple.shade700,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'جدول الإظلام',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'تحكم أوتوماتيكي',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        if (ctrl != null)
          IconButton(
            onPressed:
                () => DarknessSettingsSheet.open(context, controller: ctrl),
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            tooltip: 'إعدادات الإظلام',
          ),
      ],
    );
  }

  Widget _buildIdleView(
    BuildContext context,
    int totalHours,
    int phases,
    double periodHours,
    int phasesCompleted,
    bool isDark,
  ) {
    final DarknessScheduleController? scheduleCtrl =
        Get.isRegistered<DarknessScheduleController>()
            ? Get.find<DarknessScheduleController>()
            : null;

    final DateTime? nextAlarm = scheduleCtrl?.nextAlarmTime;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'إجمالي الساعات',
                '$totalHours',
                'ساعة اليوم',
                Icons.access_time_filled,
                isDark,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildInfoCard(
                'المراحل',
                '$phases',
                'مراحل إظلام',
                Icons.layers,
                isDark,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        if (nextAlarm != null) ...[
          SizedBox(height: 12.h),
          _buildNextAlarmInfo(nextAlarm, isDark),
        ],
        SizedBox(height: 12.h),
        _buildProgressRow(phases, phasesCompleted, isDark),
      ],
    );
  }

  Widget _buildNextAlarmInfo(DateTime nextAlarm, bool isDark) {
    final int h = nextAlarm.hour;
    final int m = nextAlarm.minute;
    final String period = h < 12 ? 'ص' : 'م';
    final int h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final String timeStr =
        '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.teal.withValues(alpha: 0.1)
                : Colors.teal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.teal.withValues(alpha: isDark ? 0.3 : 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              color: Colors.teal,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المنبه القادم',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: timeStr,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    TextSpan(
                      text: ' $period',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          if (nextAlarm.day != DateTime.now().day)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'غداً',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    String unit,
    IconData icon,
    bool isDark, {
    required Color color,
  }) {
    final bgColor =
        isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.05);
    final iconColor = isDark ? color.withValues(alpha: 0.8) : color;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.2 : 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(int phases, int textphasesCompleted, bool isDark) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.grey[800]!.withValues(alpha: 0.3)
                : Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 20.sp,
                color: isDark ? Colors.green.shade300 : Colors.green.shade600,
              ),
              SizedBox(width: 8.w),
              Text(
                'تم إنجاز',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ],
          ),
          Text(
            '$textphasesCompleted / $phases',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTimer(
    BuildContext context,
    Duration remaining,
    bool isDark,
  ) {
    final int hours = remaining.inHours;
    final int minutes = remaining.inMinutes % 60;
    final int seconds = remaining.inSeconds % 60;

    final String formattedTime =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 32.w),
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark ? Colors.orange.shade900 : Colors.orange.shade200,
            ),
          ),
          child: Column(
            children: [
              Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 42.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color:
                      isDark ? Colors.orange.shade300 : Colors.orange.shade800,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'الوقت المتبقي',
                style: TextStyle(
                  fontSize: 14.sp,
                  color:
                      isDark ? Colors.orange.shade200 : Colors.orange.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'مرحلة الإظلام جارية...',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    bool manualActive,
    DarknessScheduleController? ctrl,
    bool isDark,
    bool hasHours,
  ) {
    if (ctrl == null || !hasHours) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: () {
          if (manualActive) {
            ctrl.stopManualDarkness();
          } else {
            ctrl.startManualDarkness();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              manualActive
                  ? (isDark
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.red.shade50)
                  : (isDark
                      ? AppColors.darkPrimaryColor
                      : AppColors.primaryColor),
          foregroundColor:
              manualActive
                  ? (isDark ? Colors.red.shade200 : Colors.red.shade700)
                  : Colors.white,
          elevation: manualActive ? 0 : 4,
          shadowColor:
              manualActive
                  ? Colors.transparent
                  : AppColors.primaryColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side:
                manualActive
                    ? BorderSide(
                      color: isDark ? Colors.red.shade300 : Colors.red.shade200,
                    )
                    : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(manualActive ? Icons.stop_rounded : Icons.play_arrow_rounded),
            SizedBox(width: 8.w),
            Text(
              manualActive ? 'إيقاف الإظلام' : 'بدء الإظلام الآن',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
