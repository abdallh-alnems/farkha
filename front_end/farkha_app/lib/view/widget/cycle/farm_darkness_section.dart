import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../logic/controller/tools_controller/darkness_schedule_controller.dart';
import 'darkness_settings_sheet.dart';

class FarmDarknessSection extends StatelessWidget {
  final int totalHours;
  final int phases;
  final int phasesCompleted;
  final DateTime? nextAlarm;
  final bool manualActive;
  final Duration? remaining;
  final DarknessScheduleController? scheduleCtrl;
  final bool isDark;
  final Color surfaceColor;
  final Color dimColor;
  final Color accentColor;

  const FarmDarknessSection({
    super.key,
    required this.totalHours,
    required this.phases,
    required this.phasesCompleted,
    this.nextAlarm,
    required this.manualActive,
    this.remaining,
    this.scheduleCtrl,
    required this.isDark,
    required this.surfaceColor,
    required this.dimColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.nightlight_round,
                        size: 18.sp,
                        color: isDark
                            ? Colors.deepPurple.shade200
                            : Colors.deepPurple.shade700),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'جدول الإظلام',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.grey[200] : Colors.grey[800],
                        ),
                      ),
                      Text(
                        'تحكم أوتوماتيكي',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (scheduleCtrl != null)
                IconButton(
                  onPressed: () =>
                      DarknessSettingsSheet.open(context, controller: scheduleCtrl!),
                  icon: Icon(Icons.settings_outlined,
                      size: 20.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          if (manualActive && remaining != null)
            _buildActiveTimer()
          else
            _buildIdleInfo(),
          if (scheduleCtrl != null && totalHours > 0) ...[
            SizedBox(height: 16.h),
            _buildDarknessAction(),
          ],
        ],
      ),
    );
  }

  Widget _buildIdleInfo() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _darkStat(
                icon: Icons.access_time_filled,
                value: '$totalHours',
                label: 'ساعة اليوم',
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _darkStat(
                icon: Icons.layers,
                value: '$phases',
                label: 'مراحل إظلام',
                color: Colors.purple,
              ),
            ),
          ],
        ),
        if (nextAlarm != null) ...[
          SizedBox(height: 12.h),
          _buildNextAlarm(),
        ],
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey[800]!.withValues(alpha: 0.3)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 18.sp,
                      color: isDark
                          ? Colors.green.shade300
                          : Colors.green.shade600),
                  SizedBox(width: 8.w),
                  Text('تم إنجاز',
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? Colors.grey[300] : Colors.grey[700])),
                ],
              ),
              Text('$phasesCompleted / $phases',
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _darkStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.2 : 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: isDark ? color.withValues(alpha: 0.8) : color, size: 24.sp),
          SizedBox(height: 6.h),
          Text(value,
              style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87)),
          Text(label,
              style: TextStyle(
                  fontSize: 11.sp,
                  color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildNextAlarm() {
    final h = nextAlarm!.hour;
    final m = nextAlarm!.minute;
    final period = h < 12 ? 'ص' : 'م';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final timeStr =
        '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.teal.withValues(alpha: 0.1)
            : Colors.teal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.teal.withValues(alpha: isDark ? 0.3 : 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_active_outlined,
                color: Colors.teal, size: 18.sp),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('المنبه القادم',
                  style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600])),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: timeStr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    TextSpan(
                      text: ' $period',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          if (nextAlarm!.day != DateTime.now().day)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text('غداً',
                  style: TextStyle(
                      fontSize: 10.sp,
                      color: isDark ? Colors.grey[300] : Colors.grey[700])),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveTimer() {
    final h = remaining!.inHours;
    final m = remaining!.inMinutes % 60;
    final s = remaining!.inSeconds % 60;
    final formatted =
        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 28.w),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.orange.withValues(alpha: 0.1)
                : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
                color: isDark ? Colors.orange.shade900 : Colors.orange.shade200),
          ),
          child: Column(
            children: [
              Text(formatted,
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: isDark ? Colors.orange.shade300 : Colors.orange.shade800,
                  )),
              SizedBox(height: 6.h),
              Text('الوقت المتبقي',
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark
                          ? Colors.orange.shade200
                          : Colors.orange.shade900)),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Text('مرحلة الإظلام جارية...',
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87)),
      ],
    );
  }

  Widget _buildDarknessAction() {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: () {
          if (manualActive) {
            scheduleCtrl!.stopManualDarkness();
          } else {
            scheduleCtrl!.startManualDarkness();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: manualActive
              ? (isDark
                  ? Colors.red.withValues(alpha: 0.2)
                  : Colors.red.shade50)
              : accentColor,
          foregroundColor: manualActive
              ? (isDark ? Colors.red.shade200 : Colors.red.shade700)
              : Colors.white,
          elevation: manualActive ? 0 : 4,
          shadowColor:
              manualActive ? Colors.transparent : accentColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: manualActive
                ? BorderSide(
                    color: isDark ? Colors.red.shade300 : Colors.red.shade200)
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
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
