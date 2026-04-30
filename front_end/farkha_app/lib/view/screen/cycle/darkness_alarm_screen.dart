import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/constant/storage_keys.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/tools_controller/darkness_schedule_controller.dart';

/// Full-screen alarm page for darkness phase reminders.
class DarknessAlarmScreen extends StatefulWidget {
  const DarknessAlarmScreen({
    super.key,
    this.title,
    this.body,
    this.phase,
    this.cycleName,
    this.duration,
    this.startTime,
    this.endTime,
    this.totalPhases,
    this.age,
    this.totalDarknessHours,
    this.fromBackground = false,
  });

  final String? title;
  final String? body;
  final int? phase;
  final String? cycleName;
  final String? duration;
  final String? startTime;
  final String? endTime;
  final int? totalPhases;
  final int? age;
  final int? totalDarknessHours;
  final bool fromBackground;

  static Map<String, dynamic>? argsFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>?;
      if (map?['type'] == 'darkness_alarm') {
        for (final key in [
          'age',
          'totalPhases',
          'totalDarknessHours',
          'phase',
        ]) {
          if (map![key] is String) {
            map[key] = int.tryParse(map[key] as String);
          }
        }
        return map;
      }
    } catch (_) {}
    return null;
  }

  @override
  State<DarknessAlarmScreen> createState() => _DarknessAlarmScreenState();
}

class _DarknessAlarmScreenState extends State<DarknessAlarmScreen>
    with SingleTickerProviderStateMixin {
  final FlutterRingtonePlayer _ringtonePlayer = FlutterRingtonePlayer();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startAlarmSound();
  }

  Future<void> _startAlarmSound() async {
    if (!mounted) return;
    try {
      await _ringtonePlayer.playAlarm(volume: 1.0);
    } catch (_) {}
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringtonePlayer.stop();
    super.dispose();
  }

  void _onStartDarkness() {
    _ringtonePlayer.stop();
    GetStorage().remove(StorageKeys.pendingDarknessAlarm);
    try {
      final isFinish = widget.title?.contains('انتهى') ?? false;
      if (!isFinish) {
        final ctrl =
            Get.isRegistered<DarknessScheduleController>()
                ? Get.find<DarknessScheduleController>()
                : Get.put(DarknessScheduleController());
        ctrl.startManualDarkness();
      }
    } catch (_) {}
    Get.back<void>();
  }

  void _onLater() {
    _ringtonePlayer.stop();
    GetStorage().remove(StorageKeys.pendingDarknessAlarm);
    if (widget.fromBackground) {
      // Alarm brought the app from background → minimize
      final ctrl =
          Get.isRegistered<DarknessScheduleController>()
              ? Get.find<DarknessScheduleController>()
              : Get.put(DarknessScheduleController());
      ctrl.minimizeApp();
    } else {
      // App was already open → just close alarm page
      Get.back<void>();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
    final isFinish = widget.title?.contains('انتهى') ?? false;

    // Gradient colors
    final gradientStart =
        isDark ? const Color(0xFF1A1A2E) : const Color(0xFF0D1B2A);
    final gradientEnd =
        isDark ? const Color(0xFF16213E) : const Color(0xFF1B2838);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [gradientStart, gradientEnd],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                children: [
                  // ── Top bar ──
                  if (widget.cycleName != null || widget.age != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.cycleName != null) ...[
                            Icon(
                              Icons.egg_outlined,
                              size: 16.sp,
                              color: Colors.white54,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              widget.cycleName!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          if (widget.cycleName != null && widget.age != null)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Container(
                                width: 4.w,
                                height: 4.w,
                                decoration: const BoxDecoration(
                                  color: Colors.white30,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          if (widget.age != null)
                            Text(
                              'اليوم ${widget.age}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),

                  // ── Scrollable content ──
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 24.h),

                          // ── Pulsing alarm icon ──
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              padding: EdgeInsets.all(28.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    primary.withValues(alpha: 0.3),
                                    primary.withValues(alpha: 0.05),
                                  ],
                                ),
                              ),
                              child: Icon(
                                isFinish
                                    ? Icons.check_circle_outline
                                    : Icons.alarm_rounded,
                                size: 72.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // ── Title ──
                          Text(
                            widget.title ?? 'حان وقت مرحلة الإظلام',
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 8.h),

                          Text(
                            widget.body ?? 'ابدأ مرحلة الإظلام',
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.white60,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 24.h),

                          // ── Info cards ──
                          _buildInfoCards(primary),

                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),

                  // ── Action buttons ──
                  _buildActionButtons(primary, isFinish),

                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCards(Color primary) {
    final bool hasTimeInfo = widget.startTime != null;
    final bool hasPhaseInfo =
        widget.phase != null && widget.totalPhases != null;
    final bool hasDuration = widget.duration != null;
    final bool hasTotalHours = widget.totalDarknessHours != null;

    if (!hasTimeInfo && !hasPhaseInfo && !hasDuration && !hasTotalHours) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Time row (from → to)
          if (hasTimeInfo) ...[
            Row(
              children: [
                _infoIcon(Icons.schedule_rounded, primary),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'وقت الإظلام',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white54,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          widget.endTime != null
                              ? '${widget.startTime}  →  ${widget.endTime}'
                              : widget.startTime!,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // Duration
          if (hasDuration) ...[
            if (hasTimeInfo) _divider(),
            Row(
              children: [
                _infoIcon(Icons.timelapse_rounded, primary),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مدة هذه المرحلة',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white54,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        widget.duration!,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // Phase progress
          if (hasPhaseInfo) ...[
            if (hasTimeInfo || hasDuration) _divider(),
            Row(
              children: [
                _infoIcon(Icons.layers_rounded, primary),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تقدم المراحل',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white54,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'المرحلة ${widget.phase} من ${widget.totalPhases}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Mini progress dots
                Row(
                  children: List.generate(
                    widget.totalPhases!,
                    (i) => Container(
                      margin: EdgeInsets.only(right: 4.w),
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            i < widget.phase!
                                ? primary
                                : Colors.white.withValues(alpha: 0.15),
                        border:
                            i + 1 == widget.phase
                                ? Border.all(color: primary, width: 2)
                                : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoIcon(IconData icon, Color primary) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(icon, size: 20.sp, color: primary),
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
    );
  }

  Widget _buildActionButtons(Color primary, bool isFinish) {
    return Column(
      children: [
        // Primary action
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: FilledButton.icon(
            onPressed: _onStartDarkness,
            icon: Icon(
              isFinish ? Icons.check_circle_outline : Icons.dark_mode_rounded,
              size: 22.sp,
            ),
            label: Text(
              isFinish ? 'حسناً' : 'ابدء الإظلام',
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // Secondary action
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: TextButton(
            onPressed: _onLater,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white60,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              'لاحقاً',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
