import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/constant/storage_keys.dart';
import '../../../core/constant/theme/theme.dart';
import '../../../logic/controller/tools_controller/darkness_schedule_controller.dart';
import '../../widget/cycle/darkness_alarm_list.dart';

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
    with TickerProviderStateMixin {
  final FlutterRingtonePlayer _ringtonePlayer = FlutterRingtonePlayer();
  late AnimationController _pulseController;
  late AnimationController _ringController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _ringScaleAnimation;

  static const _bgDark = Color(0xFF1C1916);
  static const _bgDeep = Color(0xFF15120F);
  static const _surfaceWarm = Color(0xFF2A2520);
  static const _textPrimary = Color(0xFFF0EAE0);
  static const _textSecondary = Color(0xFFB8AE9E);
  static const _textMuted = Color(0xFF7A7268);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutCubic),
    );

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _ringScaleAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOutQuart),
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
    _ringController.dispose();
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
      final ctrl =
          Get.isRegistered<DarknessScheduleController>()
              ? Get.find<DarknessScheduleController>()
              : Get.put(DarknessScheduleController());
      ctrl.minimizeApp();
    } else {
      Get.back<void>();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFinish = widget.title?.contains('انتهى') ?? false;
    final accentColor =
        isFinish ? AppColors.successColor : AppColors.accentColor;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _bgDark,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_bgDark, _bgDeep],
              stops: [0.0, 0.6],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenH,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                children: [
                  _buildTopBar(accentColor),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 40.h),
                          _buildAlarmIcon(isFinish, accentColor),
                          SizedBox(height: 32.h),
                          _buildTitle(isFinish),
                          SizedBox(height: 10.h),
                          _buildSubtitle(),
                          SizedBox(height: 32.h),
                          DarknessAlarmInfoPanel(
                            startTime: widget.startTime,
                            endTime: widget.endTime,
                            duration: widget.duration,
                            phase: widget.phase,
                            totalPhases: widget.totalPhases,
                            accentColor: accentColor,
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
                  DarknessAlarmActions(
                    accentColor: accentColor,
                    isFinish: isFinish,
                    onStart: _onStartDarkness,
                    onLater: _onLater,
                  ),
                  SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(Color accentColor) {
    if (widget.cycleName == null && widget.age == null) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _surfaceWarm.withValues(alpha: 0.6),
        borderRadius: AppDimens.borderMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.cycleName != null) ...[
            Icon(
              Icons.egg_outlined,
              size: 15.sp,
              color: accentColor.withValues(alpha: 0.8),
            ),
            SizedBox(width: 6.w),
            Text(
              widget.cycleName!,
              style: TextStyle(
                fontSize: 13.sp,
                color: _textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (widget.cycleName != null && widget.age != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                '·',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: _textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (widget.age != null)
            Text(
              'اليوم ${widget.age}',
              style: TextStyle(
                fontSize: 13.sp,
                color: _textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlarmIcon(bool isFinish, Color accentColor) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: SizedBox(
        width: 140.w,
        height: 140.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _ringController,
              builder: (context, child) {
                final progress = _ringController.value;
                final opacity = (1.0 - progress).clamp(0.0, 0.4);
                return Container(
                  width: 140.w * _ringScaleAnimation.value,
                  height: 140.w * _ringScaleAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withValues(alpha: opacity),
                      width: 2,
                    ),
                  ),
                );
              },
            ),
            Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.25),
                    accentColor.withValues(alpha: 0.05),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                isFinish
                    ? Icons.check_circle_outline_rounded
                    : Icons.dark_mode_rounded,
                size: 56.sp,
                color: accentColor.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(bool isFinish) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Text(
        widget.title ?? 'حان وقت مرحلة الإظلام',
        style: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.w800,
          color: _textPrimary,
          height: 1.3,
          letterSpacing: -0.3,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        widget.body ?? 'ابدأ مرحلة الإظلام',
        style: TextStyle(
          fontSize: 15.sp,
          color: _textSecondary,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
