import 'dart:async';

import 'package:farkha_app/logic/controller/cycle_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/constant/storage_keys.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/permission.dart';
import '../../../core/shared/dialogs/app_alert_dialog.dart';
import '../../../view/widget/cycle/darkness_settings_sheet.dart';
import '../../../view/widget/cycle/time_sensitive_hint_sheet.dart';
import 'darkness_schedule_controller.dart';

class DarknessAlarmHelper {
  DarknessAlarmHelper(this._controller);

  final DarknessScheduleController _controller;
  final GetStorage _storage = GetStorage();

  static int phaseReminderId(int phaseIndex1Based) =>
      _phaseReminderIdStart + phaseIndex1Based;

  static int transitionReminderId(int index0Based) =>
      _transitionReminderIdStart + index0Based;

  static const int _phaseReminderIdStart = 5000;
  static const int _transitionReminderIdStart = 5500;

  Future<void> rescheduleAllNotifications() async {
    if (!_controller.notificationsEnabled ||
        !Get.isRegistered<NotificationService>()) {
      return;
    }

    await cancelDarknessNotifications();

    await _scheduleTransitionNotifications();
    await _schedulePhaseNotifications();

    unawaited(TimeSensitiveHintSheet.showIfNeeded());
  }

  Future<void> _schedulePhaseNotifications() async {
    final int n = _controller.numberOfPhasesForToday;
    if (n <= 0) return;

    final DateTime now = DateTime.now();
    for (int phase = 1; phase <= n; phase++) {
      final int? hour = _controller.getPhaseReminderHour(phase);
      final int? minute = _controller.getPhaseReminderMinute(phase);
      if (hour == null || minute == null) continue;

      final String todayStr = _controller.cycleDayKeyForToday;
      if (todayStr.isEmpty) continue;

      DateTime scheduledAt = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (!scheduledAt.isAfter(now)) {
        scheduledAt = scheduledAt.add(const Duration(days: 1));
      }

      String? cycleName;
      if (Get.isRegistered<CycleController>()) {
        cycleName =
            Get.find<CycleController>().currentCycle['name'] as String?;
      }

      final DateFormat fmt = DateFormat('h:mm a', 'ar');
      final String startTimeStr = fmt.format(scheduledAt);

      String? endTimeStr;
      String? durationStr;
      int? phaseDurationMinutes;

      final snapshot = _controller.snapshotRx.value;
      if (snapshot != null) {
        final darkSegments = snapshot.segments.where((s) => s.isDark).toList();
        if (phase <= darkSegments.length) {
          final seg = darkSegments[phase - 1];
          phaseDurationMinutes = seg.end.difference(seg.start).inMinutes;
          final DateTime endTime = scheduledAt.add(
            Duration(minutes: phaseDurationMinutes),
          );
          endTimeStr = fmt.format(endTime);
          final int dh = phaseDurationMinutes ~/ 60;
          final int dm = phaseDurationMinutes % 60;
          durationStr =
              dh > 0 ? '$dh ساعة${dm > 0 ? ' و $dm دقيقة' : ''}' : '$dm دقيقة';
        }
      }

      final int totalDarknessHours = _controller.darknessHoursForDayRx.value;
      final int totalPhases = n;

      await NotificationService.instance.scheduleDarknessNotification(
        id: phaseReminderId(phase),
        scheduledAt: scheduledAt,
        title: 'حان وقت مرحلة الإظلام $phase',
        body: 'ابدأ المرحلة $phase من الإظلام',
        phase: phase,
        cycleName: cycleName,
        startTime: startTimeStr,
        endTime: endTimeStr,
        duration: durationStr,
        totalPhases: totalPhases,
        age: _controller.lastAgeInDays,
        totalDarknessHours: totalDarknessHours,
      );
    }
  }

  Future<void> checkForegroundPhaseAlarm() async {
    if (!_controller.notificationsEnabled) return;
    final int totalPhases = _controller.numberOfPhasesForToday;
    if (totalPhases <= 0) return;

    final DateTime now = DateTime.now();
    final String todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final int? currentAge = _controller.lastAgeInDays;

    for (int phase = 1; phase <= totalPhases; phase++) {
      final int? h = _controller.getPhaseReminderHour(phase);
      final int? m = _controller.getPhaseReminderMinute(phase);
      if (h == null || m == null) continue;

      final DateTime scheduledToday = DateTime(
        now.year,
        now.month,
        now.day,
        h,
        m,
      );
      if (!now.isBefore(scheduledToday)) {
        final Duration diff = now.difference(scheduledToday);
        if (diff <= const Duration(minutes: 2)) {
          final String key =
              '$StorageKeys.darknessAlarmShownPrefix${todayStr}_$phase';
          if (_storage.read<bool>(key) != true) {
            _storage.write(key, true);

            if (GetPlatform.isAndroid) {
              try {
                const MethodChannel platform = MethodChannel(
                  'com.example.farkha_app/alarm',
                );
                await platform.invokeMethod('bringAppToForeground');
              } catch (e) {
                // Ignore platform channel errors
              }
            }

            String? cycleName;
            if (Get.isRegistered<CycleController>()) {
              cycleName =
                  Get.find<CycleController>().currentCycle['name'] as String?;
            }

            final DateFormat fmt = DateFormat('h:mm a', 'ar');
            final String startTimeStr = fmt.format(scheduledToday);

            String? endTimeStr;
            String? durationStr;
            int? phaseDurationMinutes;

            final snapshot = _controller.snapshotRx.value;
            if (snapshot != null) {
              final darkSegments =
                  snapshot.segments.where((s) => s.isDark).toList();
              if (phase <= darkSegments.length) {
                final seg = darkSegments[phase - 1];
                phaseDurationMinutes = seg.end.difference(seg.start).inMinutes;
                final DateTime endTime = scheduledToday.add(
                  Duration(minutes: phaseDurationMinutes),
                );
                endTimeStr = fmt.format(endTime);
                final int dh = phaseDurationMinutes ~/ 60;
                final int dm = phaseDurationMinutes % 60;
                durationStr =
                    dh > 0
                        ? '$dh ساعة${dm > 0 ? ' و $dm دقيقة' : ''}'
                        : '$dm دقيقة';
              }
            }

            final int totalDarknessHours = _controller.darknessHoursForDayRx.value;

            Get.toNamed<void>(
              AppRoute.darknessAlarm,
              arguments: <String, dynamic>{
                'type': 'darkness_alarm',
                'title': 'حان وقت مرحلة الإظلام $phase',
                'body': 'ابدأ المرحلة $phase من الإظلام',
                'phase': phase,
                if (cycleName != null) 'cycleName': cycleName,
                'startTime': startTimeStr,
                if (endTimeStr != null) 'endTime': endTimeStr,
                if (durationStr != null) 'duration': durationStr,
                if (phaseDurationMinutes != null)
                  'phaseDurationMinutes': phaseDurationMinutes,
                'totalPhases': totalPhases,
                if (currentAge != null) 'age': currentAge,
                'totalDarknessHours': totalDarknessHours,
              },
            );
          }
        }
      }
    }
  }

  Future<void> minimizeApp() async {
    if (GetPlatform.isAndroid) {
      try {
        const MethodChannel platform = MethodChannel(
          'com.example.farkha_app/alarm',
        );
        await platform.invokeMethod('moveTaskToBack');
      } catch (e) {
        // Ignore
      }
    }
  }

  Future<void> _scheduleTransitionNotifications() async {
    final DarknessScheduleSnapshot? snap = _controller.snapshotRx.value;
    if (snap == null) return;

    final int minutesBefore = _controller.alertMinutesBefore.clamp(0, 180);
    final DateTime now = DateTime.now();
    final List<DateTime> transitions = DarknessScheduleController
        .transitionTimes(snap.segments);

    for (int i = 0; i < transitions.length; i++) {
      final DateTime at = transitions[i];
      final DateTime scheduledAt =
          minutesBefore > 0
              ? at.subtract(Duration(minutes: minutesBefore))
              : at;
      if (!scheduledAt.isAfter(now)) continue;

      final bool isDarkStarting = DarknessScheduleController.isDarkAtOrAfter(
        at,
        snap.segments,
      );
      final String title =
          isDarkStarting ? 'سيبدأ الإظلام قريباً' : 'سيبدأ وقت الإضاءة قريباً';
      final String body =
          minutesBefore > 0 ? 'بعد $minutesBefore دقائق' : 'الآن';

      await NotificationService.instance.scheduleDarknessNotification(
        id: transitionReminderId(i),
        scheduledAt: scheduledAt,
        title: title,
        body: body,
      );
    }
  }

  Future<void> cancelDarknessNotifications() async {
    if (!Get.isRegistered<NotificationService>()) return;
    await NotificationService.instance.cancelDarknessNotifications();
  }

  List<DateTime> getPhaseReminderTimesNext() {
    final int n = _controller.numberOfPhasesForToday;
    if (n <= 0) return <DateTime>[];
    final DateTime? cycleDay = _controller.cycleDayDateForToday;
    if (cycleDay == null) return <DateTime>[];

    final DateTime now = DateTime.now();
    final List<DateTime> times = <DateTime>[];
    for (int phase = 1; phase <= n; phase++) {
      final int? hour = _controller.getPhaseReminderHour(phase);
      final int? minute = _controller.getPhaseReminderMinute(phase);
      if (hour == null || minute == null) continue;

      DateTime at = DateTime(
        cycleDay.year,
        cycleDay.month,
        cycleDay.day,
        hour,
        minute,
      );
      if (!at.isAfter(now)) {
        at = at.add(const Duration(days: 1));
      }
      times.add(at);
    }
    return times;
  }

  Future<bool> requirePermissions() async {
    bool granted = await _checkIfPermissionsGranted();
    if (granted) {
      _controller.notificationsEnabled = true;
      return true;
    }

    if (Get.isDialogOpen ?? false) return false;

    final bool? result = await Get.dialog<bool>(
      AppAlertDialog(
        icon: Icons.alarm_on_rounded,
        iconColor: Colors.deepPurple,
        title: 'تنبيهات الإظلام',
        description:
            'لضمان ظهور منبه الإظلام في الوقت المحدد، يرجى منح صلاحية "الظهور فوق التطبيقات".',
        primaryActionLabel: 'منح الصلاحيات',
        primaryAction: () async {
          if (Get.isDialogOpen ?? false) Get.back<bool>(result: true);
        },
        secondaryActionLabel: 'لاحقاً',
        secondaryAction: () {
          if (Get.isDialogOpen ?? false) Get.back<bool>(result: false);
        },
      ),
    );

    if (result == true) {
      await _requestMissingPermissions();
      granted = await _checkIfPermissionsGranted();
      if (granted) {
        _controller.notificationsEnabled = true;
        return true;
      }
    }

    _controller.notificationsEnabled = false;
    return false;
  }

  Future<void> checkDarknessFeatureSuggestion(int ageInDays) async {
    if (ageInDays != 5) return;

    if (_storage.read<bool>(StorageKeys.darknessSuggestionShown) == true) return;
    if (_controller.notificationsEnabled) return;

    if (Get.isDialogOpen ?? false) return;

    _storage.write(StorageKeys.darknessSuggestionShown, true);

    await Get.dialog<void>(
      AppAlertDialog(
        icon: Icons.lightbulb_outline_rounded,
        iconColor: Colors.amber,
        title: 'تنبيه الإظلام',
        description:
            'بدأ برنامج الإظلام اليوم! يمكنك ضبط منبه لتذكيرك بمواعيد الإضاءة والإظلام لضمان راحة الطيور.',
        primaryActionLabel: 'ضبط المنبه',
        primaryAction: () async {
          if (Get.isDialogOpen ?? false) Get.back<void>();

          final bool granted = await requirePermissions();
          if (granted) {
            Get.bottomSheet<void>(
              DarknessSettingsSheet(controller: _controller),
              isScrollControlled: true,
            );
          }
        },
        secondaryActionLabel: 'لاحقاً',
        secondaryAction: () {
          if (Get.isDialogOpen ?? false) Get.back<void>();
        },
      ),
    );
  }

  Future<bool> _checkIfPermissionsGranted() async {
    final bool notif = await Permission.notification.isGranted;
    bool exact = true;
    if (GetPlatform.isAndroid) {
      if (await Permission.scheduleExactAlarm.status.isDenied) {
        exact = false;
      }
      if (await Permission.systemAlertWindow.status.isDenied) {
        exact = false;
      }
    }
    _controller.permissionsGranted.value = notif && exact;
    return notif && exact;
  }

  Future<void> _requestMissingPermissions() async {
    final PermissionController permCtrl = Get.find<PermissionController>();

    if (!await Permission.notification.isGranted) {
      await permCtrl.checkAndRequestNotificationPermission();
    }

    if (GetPlatform.isAndroid) {
      if (!await Permission.scheduleExactAlarm.isGranted) {
        await permCtrl.checkAndRequestExactAlarmPermission();
      }
      if (!await Permission.systemAlertWindow.isGranted) {
        await permCtrl.checkAndRequestSystemAlertWindowPermission();
      }
    }

    _controller.refresh();
  }
}
