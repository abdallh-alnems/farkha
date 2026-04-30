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
import '../../../data/data_source/static/chicken_data.dart';
import '../../../core/shared/dialogs/app_alert_dialog.dart';
import '../../../view/widget/cycle/darkness_settings_sheet.dart';

class DarknessScheduleSegment {
  const DarknessScheduleSegment({
    required this.start,
    required this.end,
    required this.isDark,
  });

  final DateTime start;
  final DateTime end;
  final bool isDark;
}

class DarknessScheduleSnapshot {
  const DarknessScheduleSnapshot({
    required this.totalDarknessHours,
    required this.dayStart,
    required this.dayEnd,
    required this.segments,
    required this.isDarkNow,
    required this.remainingInCurrentSegment,
    required this.nextSegmentStart,
    required this.nextIsDark,
  });

  final int totalDarknessHours;
  final DateTime dayStart;
  final DateTime dayEnd;
  final List<DarknessScheduleSegment> segments;

  final bool isDarkNow;
  final Duration remainingInCurrentSegment;
  final DateTime? nextSegmentStart;
  final bool? nextIsDark;
}

class DarknessScheduleController extends GetxController {
  static const int _maxDarknessBlockMinutes = 120; // 2 hours
  static const int _scheduleDayMinutes = 24 * 60;

  // Keep the old IDs style for phase alarms (5001..5199), and use a separate
  // range for transition reminders (5500..5599) to avoid collisions.
  static int phaseReminderId(int phaseIndex1Based) =>
      _phaseReminderIdStart + phaseIndex1Based;

  static int transitionReminderId(int index0Based) =>
      _transitionReminderIdStart + index0Based;

  static const int _phaseReminderIdStart = 5000;
  static const int _transitionReminderIdStart = 5500;

  // ── Defaults ──
  static const int _kDefaultDayStartHour = 6;
  static const int _kDefaultAlertMinutesBefore = 10;
  static const bool _kDefaultNotificationsEnabled = true;

  final GetStorage _storage = GetStorage();

  final Rx<DarknessScheduleSnapshot?> snapshotRx =
      Rx<DarknessScheduleSnapshot?>(null);
  final RxInt darknessHoursForDayRx = 0.obs;

  final RxInt dayStartHourRx = RxInt(_kDefaultDayStartHour);
  final RxInt alertMinutesBeforeRx = RxInt(_kDefaultAlertMinutesBefore);
  final RxBool notificationsEnabledRx = RxBool(_kDefaultNotificationsEnabled);

  /// Triggers UI rebuilds for phase reminder list.
  final RxInt phaseReminderUpdateTrigger = 0.obs;

  /// Manual "start darkness" countdown: active and end time.
  final RxBool manualDarknessActive = false.obs;
  final Rx<DateTime?> manualDarknessEndTime = Rx<DateTime?>(null);

  /// Ticks every second when manual darkness is active so UI updates countdown.
  final RxInt manualDarknessTicker = 0.obs;

  /// عدد مراحل الإظلام المكتملة اليوم (يُحدَّث عند انتهاء العدّ).
  final RxInt phasesCompletedToday = 0.obs;

  Timer? _ticker;
  String? _lastStartDateRaw;
  int? _lastAgeInDays;

  // Tracks if darkness permissions are granted (Notification + Exact Alarm)
  final RxBool permissionsGranted = false.obs;

  /// Remaining time when manual darkness is active; null when inactive or expired.
  Duration? get remainingManualDarkness {
    final DateTime? end = manualDarknessEndTime.value;
    if (end == null || !manualDarknessActive.value) return null;
    final Duration d = end.difference(DateTime.now());
    return d.isNegative ? null : d;
  }

  int get dayStartHour => dayStartHourRx.value;

  set dayStartHour(int value) {
    final int clamped = value.clamp(0, 23);
    dayStartHourRx.value = clamped;
    _storage.write(StorageKeys.darknessDayStartHour, clamped);
    _refresh();
  }

  int get alertMinutesBefore => alertMinutesBeforeRx.value;

  set alertMinutesBefore(int value) {
    final int clamped = value.clamp(0, 180);
    alertMinutesBeforeRx.value = clamped;
    _storage.write(StorageKeys.darknessAlertMinutesBefore, clamped);
    _refresh();
  }

  bool get notificationsEnabled => notificationsEnabledRx.value;

  set notificationsEnabled(bool value) {
    notificationsEnabledRx.value = value;
    _storage.write(StorageKeys.darknessNotificationsEnabled, value);
    if (!value) {
      unawaited(_cancelDarknessNotifications());
    } else {
      _refresh();
    }
  }

  @override
  void onInit() {
    super.onInit();
    dayStartHourRx.value =
        _storage.read<int>(StorageKeys.darknessDayStartHour) ?? _kDefaultDayStartHour;
    alertMinutesBeforeRx.value =
        _storage.read<int>(StorageKeys.darknessAlertMinutesBefore) ?? _kDefaultAlertMinutesBefore;
    notificationsEnabledRx.value =
        _storage.read<bool>(StorageKeys.darknessNotificationsEnabled) ??
        _kDefaultNotificationsEnabled;
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }

  void updateSchedule({required String startDateRaw, required int ageInDays}) {
    final DateTime? start = DateTime.tryParse(startDateRaw);
    if (start == null || ageInDays < 1 || ageInDays > darknessLevels.length) {
      _lastStartDateRaw = null;
      _lastAgeInDays = null;
      darknessHoursForDayRx.value = 0;
      snapshotRx.value = null;
      phasesCompletedToday.value = 0;
      _ticker?.cancel();
      unawaited(_cancelDarknessNotifications());
      return;
    }

    _lastStartDateRaw = startDateRaw;
    _lastAgeInDays = ageInDays;

    final int effectiveAge = _effectiveAgeForNow(
      startDateRaw: startDateRaw,
      ageInDays: ageInDays,
      dayStartHour: dayStartHour,
    );

    final int darknessHours = darknessLevels[effectiveAge - 1];
    darknessHoursForDayRx.value = darknessHours;

    _loadPhasesCompletedForToday();
    _recomputeSnapshot();
    _startTicker();
    unawaited(_rescheduleAllNotifications());
  }

  void _refresh() {
    if (_lastStartDateRaw == null || _lastAgeInDays == null) return;
    _recomputeSnapshot();
    unawaited(_rescheduleAllNotifications());
  }

  void _startTicker() {
    _ticker?.cancel();
    void onTick() {
      if (manualDarknessActive.value) {
        final DateTime? end = manualDarknessEndTime.value;
        if (end != null && DateTime.now().isAfter(end)) {
          manualDarknessActive.value = false;
          manualDarknessEndTime.value = null;
          _storage.remove(StorageKeys.darknessPausedEndTime);
          _ticker?.cancel();
          _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
            _recomputeSnapshot();
            _checkForegroundPhaseAlarm();
          });
          return;
        }
        manualDarknessTicker.value++;
        return;
      }
      _recomputeSnapshot();
      _checkForegroundPhaseAlarm();
    }

    if (manualDarknessActive.value) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => onTick());
    } else {
      _ticker = Timer.periodic(const Duration(minutes: 1), (_) => onTick());
    }
  }

  /// Start manual darkness: one period (from total hours / phases, max 2h). Countdown runs until stop or end.
  void startManualDarkness() {
    if (manualDarknessActive.value) return;

    final int totalHours = darknessHoursForDayRx.value;
    final double periodHours =
        totalHours <= 0
            ? 2.0
            : (totalHours / _numberOfPhases(totalHours))
                .clamp(0.5, 2.0)
                .toDouble();
    final int periodMinutes = (periodHours * 60).round().clamp(
      1,
      _maxDarknessBlockMinutes,
    );
    final DateTime endTime = DateTime.now().add(
      Duration(minutes: periodMinutes),
    );

    manualDarknessEndTime.value = endTime;
    manualDarknessActive.value = true;

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final DateTime? end = manualDarknessEndTime.value;
      if (end == null || !manualDarknessActive.value) return;
      if (DateTime.now().isAfter(end)) {
        manualDarknessActive.value = false;
        manualDarknessEndTime.value = null;
        _storage.remove(StorageKeys.darknessPausedEndTime);
        final int n = numberOfPhasesForToday;
        phasesCompletedToday.value = (phasesCompletedToday.value + 1).clamp(
          0,
          n > 0 ? n : 999,
        );
        _savePhasesCompletedForToday();

        // Trigger finish notification/alarm
        if (notificationsEnabled) {
          Get.toNamed<void>(
            AppRoute.darknessAlarm,
            arguments: <String, dynamic>{
              'type': 'darkness_alarm',
              'title': 'انتهى وقت الإظلام',
              'body': 'لقد انتهت فترة الإظلام المحددة',
              'phase': phasesCompletedToday.value,
            },
          );
        }

        _ticker?.cancel();
        _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
          _recomputeSnapshot();
          _checkForegroundPhaseAlarm();
        });
        return;
      }
      manualDarknessTicker.value++;
    });
  }

  void stopManualDarkness() {
    if (!manualDarknessActive.value) return;
    manualDarknessActive.value = false;
    manualDarknessEndTime.value = null;
    _storage.remove(StorageKeys.darknessPausedEndTime);
    _ticker?.cancel();
    _startTicker();
  }

  void _recomputeSnapshot() {
    final String? startDateRaw = _lastStartDateRaw;
    final int? ageInDays = _lastAgeInDays;
    if (startDateRaw == null || ageInDays == null) {
      snapshotRx.value = null;
      return;
    }

    final DateTime? start = DateTime.tryParse(startDateRaw);
    if (start == null) {
      snapshotRx.value = null;
      return;
    }

    final int effectiveAge = _effectiveAgeForNow(
      startDateRaw: startDateRaw,
      ageInDays: ageInDays,
      dayStartHour: dayStartHour,
    );

    final int totalDarknessHours = darknessLevels[effectiveAge - 1];
    final DateTime farmDayStart = _farmDayStart(
      start: start,
      ageInDays: effectiveAge,
      dayStartHour: dayStartHour,
    );
    final DateTime farmDayEnd = farmDayStart.add(const Duration(hours: 24));

    final List<DarknessScheduleSegment> segments = buildDailySchedule(
      dayStart: farmDayStart,
      totalDarknessHours: totalDarknessHours,
    );

    snapshotRx.value = computeSnapshotNow(
      now: DateTime.now(),
      totalDarknessHours: totalDarknessHours,
      dayStart: farmDayStart,
      dayEnd: farmDayEnd,
      segments: segments,
    );
  }

  int get numberOfPhasesForToday {
    final int h = darknessHoursForDayRx.value;
    return _numberOfPhases(h);
  }

  /// Returns the next scheduled alarm time (sorted earliest first).
  DateTime? get nextAlarmTime {
    if (!notificationsEnabled) return null;
    final List<DateTime> times = _getPhaseReminderTimesNext();
    if (times.isEmpty) return null;
    times.sort();
    return times.first;
  }

  /// مدة كل مرحلة بالساعات (للعرض)، أقصاها 2 ساعة.
  double get periodLengthHoursForDisplay {
    final int h = darknessHoursForDayRx.value;
    if (h <= 0) return 0;
    final int n = _numberOfPhases(h);
    if (n <= 0) return 0;
    return (h / n).clamp(0.5, 2.0).toDouble();
  }

  static int _numberOfPhases(int totalDarknessHours) {
    final int h = totalDarknessHours.clamp(0, 24);
    if (h <= 0) return 0;
    if (h <= 2) return h; // 1h => 1 phase, 2h => 2 phases
    final int minutes = h * 60;
    return (minutes / _maxDarknessBlockMinutes).ceil();
  }

  int? getPhaseReminderHour(int phase1Based) {
    final List<dynamic>? list = _storage.read<List<dynamic>>(
      StorageKeys.darknessPhaseReminderHours,
    );
    if (list != null && phase1Based <= list.length) {
      final Object? v = list[phase1Based - 1];
      // Check for null or invalid value explicitly if needed, but here we expect valid ints or nulls in list
      if (v == null) return null;
      final int? h = (v is num) ? v.toInt() : int.tryParse(v.toString());
      if (h != null && h >= 0 && h <= 23) return h;
    }
    // Return null instead of default to indicate "not set"
    return null;
  }

  int? getPhaseReminderMinute(int phase1Based) {
    final List<dynamic>? list = _storage.read<List<dynamic>>(
      StorageKeys.darknessPhaseReminderMinutes,
    );
    if (list != null && phase1Based <= list.length) {
      final Object? v = list[phase1Based - 1];
      if (v == null) return null;
      final int? m = (v is num) ? v.toInt() : int.tryParse(v.toString());
      if (m != null && m >= 0 && m <= 59) return m;
    }
    return null;
  }

  void setPhaseReminderTime(int phase1Based, int hour, int minute) {
    final int h = hour.clamp(0, 23);
    final int m = minute.clamp(0, 59);

    final List<dynamic> hoursList =
        _storage.read<List<dynamic>>(StorageKeys.darknessPhaseReminderHours) ?? <dynamic>[];
    final List<dynamic> minutesList =
        _storage.read<List<dynamic>>(StorageKeys.darknessPhaseReminderMinutes) ?? <dynamic>[];

    final List<int?> intHours =
        hoursList
            .map(
              (dynamic e) =>
                  (e == null)
                      ? null
                      : ((e is num) ? e.toInt() : int.tryParse(e.toString())),
            )
            .toList();
    final List<int?> intMinutes =
        minutesList
            .map(
              (dynamic e) =>
                  (e == null)
                      ? null
                      : ((e is num) ? e.toInt() : int.tryParse(e.toString())),
            )
            .toList();

    while (intHours.length < phase1Based) {
      // Add nulls for unset phases
      intHours.add(null);
      intMinutes.add(null);
    }

    intHours[phase1Based - 1] = h;
    intMinutes[phase1Based - 1] = m;

    _storage.write(StorageKeys.darknessPhaseReminderHours, intHours);
    _storage.write(StorageKeys.darknessPhaseReminderMinutes, intMinutes);

    phaseReminderUpdateTrigger.value++;
    _refresh();
  }

  void clearPhaseReminderTime(int phase1Based) {
    final List<dynamic> hoursList =
        _storage.read<List<dynamic>>(StorageKeys.darknessPhaseReminderHours) ?? <dynamic>[];
    final List<dynamic> minutesList =
        _storage.read<List<dynamic>>(StorageKeys.darknessPhaseReminderMinutes) ?? <dynamic>[];

    final List<int?> intHours =
        hoursList
            .map(
              (dynamic e) =>
                  (e == null)
                      ? null
                      : ((e is num) ? e.toInt() : int.tryParse(e.toString())),
            )
            .toList();
    final List<int?> intMinutes =
        minutesList
            .map(
              (dynamic e) =>
                  (e == null)
                      ? null
                      : ((e is num) ? e.toInt() : int.tryParse(e.toString())),
            )
            .toList();

    while (intHours.length < phase1Based) {
      intHours.add(null);
      intMinutes.add(null);
    }

    intHours[phase1Based - 1] = null;
    intMinutes[phase1Based - 1] = null;

    _storage.write(StorageKeys.darknessPhaseReminderHours, intHours);
    _storage.write(StorageKeys.darknessPhaseReminderMinutes, intMinutes);

    phaseReminderUpdateTrigger.value++;
    _refresh();
  }

  DateTime? _cycleDayDateForToday() {
    final String? raw = _lastStartDateRaw;
    final int? age = _lastAgeInDays;
    if (raw == null || age == null) return null;
    final DateTime? start = DateTime.tryParse(raw);
    if (start == null) return null;

    final int effectiveAge = _effectiveAgeForNow(
      startDateRaw: raw,
      ageInDays: age,
      dayStartHour: dayStartHour,
    );
    final DateTime date = start.add(Duration(days: effectiveAge - 1));
    return DateTime(date.year, date.month, date.day);
  }

  String _cycleDayKeyForToday() {
    final DateTime? d = _cycleDayDateForToday();
    if (d == null) return '';
    return '${d.year}-${d.month}-${d.day}';
  }

  void _loadPhasesCompletedForToday() {
    final String key = _cycleDayKeyForToday();
    if (key.isEmpty) return;
    phasesCompletedToday.value =
        _storage.read<int>('$StorageKeys.darknessPhasesDonePrefix$key') ?? 0;
  }

  void _savePhasesCompletedForToday() {
    final String key = _cycleDayKeyForToday();
    if (key.isEmpty) return;
    _storage.write('$StorageKeys.darknessPhasesDonePrefix$key', phasesCompletedToday.value);
  }

  List<DateTime> _getPhaseReminderTimesNext() {
    final int n = numberOfPhasesForToday;
    if (n <= 0) return <DateTime>[];
    final DateTime? cycleDay = _cycleDayDateForToday();
    if (cycleDay == null) return <DateTime>[];

    final DateTime now = DateTime.now();
    final List<DateTime> times = <DateTime>[];
    for (int phase = 1; phase <= n; phase++) {
      final int? hour = getPhaseReminderHour(phase);
      final int? minute = getPhaseReminderMinute(phase);
      if (hour == null || minute == null) continue; // Skip if not set

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

  Future<void> _rescheduleAllNotifications() async {
    if (!notificationsEnabled || !Get.isRegistered<NotificationService>()) {
      return;
    }

    await _cancelDarknessNotifications();

    await _scheduleTransitionNotifications();
    await _schedulePhaseNotifications();
  }

  Future<void> _schedulePhaseNotifications() async {
    final int n = numberOfPhasesForToday;
    if (n <= 0) return;

    final DateTime now = DateTime.now();
    for (int phase = 1; phase <= n; phase++) {
      final int? hour = getPhaseReminderHour(phase);
      final int? minute = getPhaseReminderMinute(phase);
      if (hour == null || minute == null) continue;

      final String todayStr = _cycleDayKeyForToday();
      if (todayStr.isEmpty) continue; // Should not happen if n > 0

      // Calculate scheduled time for today
      // NOTE: We assume cycle day = today. If cycle day != today (e.g. historical viewing), we probably shouldn't schedule real alarms?
      // But numberOfPhasesForToday checks _effectiveAgeForNow.
      // If effectiveAge is for today, then we schedule for today (or tomorrow).

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
        cycleName = Get.find<CycleController>().currentCycle['name'] as String?;
      }

      // Use alarm set time as startTime
      final DateFormat fmt = DateFormat('h:mm a', 'ar');
      final String startTimeStr = fmt.format(scheduledAt);

      String? endTimeStr;
      String? durationStr;
      int? phaseDurationMinutes;

      final snapshot = snapshotRx.value;
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

      final int totalDarknessHours = darknessHoursForDayRx.value;
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
        age: _lastAgeInDays,
        totalDarknessHours: totalDarknessHours,
      );
    }
  }

  Future<void> _checkForegroundPhaseAlarm() async {
    if (!notificationsEnabled) return;
    final int totalPhases = numberOfPhasesForToday;
    if (totalPhases <= 0) return;

    final DateTime now = DateTime.now();
    final String todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final int? currentAge = _lastAgeInDays;

    for (int phase = 1; phase <= totalPhases; phase++) {
      final int? h = getPhaseReminderHour(phase);
      final int? m = getPhaseReminderMinute(phase);
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
          final String key = '$StorageKeys.darknessAlarmShownPrefix${todayStr}_$phase';
          if (_storage.read<bool>(key) != true) {
            _storage.write(key, true);

            // Invoke background launch
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

            // Use alarm set time as startTime
            final DateFormat fmt = DateFormat('h:mm a', 'ar');
            final String startTimeStr = fmt.format(scheduledToday);

            // Calculate phase duration and end time from dark segments
            String? endTimeStr;
            String? durationStr;
            int? phaseDurationMinutes;

            final snapshot = snapshotRx.value;
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

            final int totalDarknessHours = darknessHoursForDayRx.value;

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

  static int _effectiveAgeForNow({
    required String startDateRaw,
    required int ageInDays,
    required int dayStartHour,
  }) {
    final DateTime? start = DateTime.tryParse(startDateRaw);
    if (start == null) return ageInDays;

    final DateTime farmDayStart = _farmDayStart(
      start: start,
      ageInDays: ageInDays,
      dayStartHour: dayStartHour,
    );

    if (DateTime.now().isBefore(farmDayStart)) {
      return (ageInDays - 1).clamp(1, darknessLevels.length);
    }
    return ageInDays.clamp(1, darknessLevels.length);
  }

  static DateTime _farmDayStart({
    required DateTime start,
    required int ageInDays,
    required int dayStartHour,
  }) {
    final DateTime dayDate = start.add(Duration(days: ageInDays - 1));
    return DateTime(dayDate.year, dayDate.month, dayDate.day, dayStartHour);
  }

  /// Builds the 24h schedule starting at [dayStart].
  /// Darkness is split into blocks of max 2 hours, then distributed across the day.
  static List<DarknessScheduleSegment> buildDailySchedule({
    required DateTime dayStart,
    required int totalDarknessHours,
  }) {
    final int clampedDarkHours = totalDarknessHours.clamp(0, 24);
    final int darknessMinutes = clampedDarkHours * 60;
    final int lightMinutes = _scheduleDayMinutes - darknessMinutes;

    if (darknessMinutes <= 0) {
      return <DarknessScheduleSegment>[
        DarknessScheduleSegment(
          start: dayStart,
          end: dayStart.add(const Duration(minutes: _scheduleDayMinutes)),
          isDark: false,
        ),
      ];
    }

    final List<int> darkBlocks = _splitIntoMaxMinutes(
      totalMinutes: darknessMinutes,
      maxBlockMinutes: _maxDarknessBlockMinutes,
    );

    final int gapCount = darkBlocks.length + 1;
    final List<int> lightGaps = _distributeMinutesEvenly(
      totalMinutes: lightMinutes,
      parts: gapCount,
    );

    final List<DarknessScheduleSegment> out = <DarknessScheduleSegment>[];
    DateTime cursor = dayStart;

    for (int i = 0; i < gapCount; i++) {
      final int gapMinutes = lightGaps[i];
      if (gapMinutes > 0) {
        final DateTime end = cursor.add(Duration(minutes: gapMinutes));
        out.add(
          DarknessScheduleSegment(start: cursor, end: end, isDark: false),
        );
        cursor = end;
      }

      if (i < darkBlocks.length) {
        final int darkMinutes = darkBlocks[i];
        if (darkMinutes > 0) {
          final DateTime end = cursor.add(Duration(minutes: darkMinutes));
          out.add(
            DarknessScheduleSegment(start: cursor, end: end, isDark: true),
          );
          cursor = end;
        }
      }
    }

    final DateTime expectedEnd = dayStart.add(
      const Duration(minutes: _scheduleDayMinutes),
    );
    if (cursor.isBefore(expectedEnd)) {
      out.add(
        DarknessScheduleSegment(start: cursor, end: expectedEnd, isDark: false),
      );
    }

    return out;
  }

  static DarknessScheduleSnapshot computeSnapshotNow({
    required DateTime now,
    required int totalDarknessHours,
    required DateTime dayStart,
    required DateTime dayEnd,
    required List<DarknessScheduleSegment> segments,
  }) {
    DarknessScheduleSegment? current;
    for (final DarknessScheduleSegment s in segments) {
      final bool inRange =
          (now.isAtSameMomentAs(s.start) || now.isAfter(s.start)) &&
          now.isBefore(s.end);
      if (inRange) {
        current = s;
        break;
      }
    }

    final DarknessScheduleSegment currentSafe =
        current ??
        (segments.isNotEmpty
            ? segments.first
            : DarknessScheduleSegment(
              start: dayStart,
              end: dayEnd,
              isDark: false,
            ));

    final Duration remaining =
        currentSafe.end.isAfter(now)
            ? currentSafe.end.difference(now)
            : Duration.zero;

    DarknessScheduleSegment? next;
    for (final DarknessScheduleSegment s in segments) {
      if (s.start.isAfter(now) &&
          (next == null || s.start.isBefore(next.start))) {
        next = s;
      }
    }

    return DarknessScheduleSnapshot(
      totalDarknessHours: totalDarknessHours,
      dayStart: dayStart,
      dayEnd: dayEnd,
      segments: segments,
      isDarkNow: currentSafe.isDark,
      remainingInCurrentSegment: remaining,
      nextSegmentStart: next?.start,
      nextIsDark: next?.isDark,
    );
  }

  static List<int> _splitIntoMaxMinutes({
    required int totalMinutes,
    required int maxBlockMinutes,
  }) {
    if (totalMinutes <= 0) return <int>[];
    final int maxMin = maxBlockMinutes <= 0 ? totalMinutes : maxBlockMinutes;

    int remaining = totalMinutes;
    final List<int> blocks = <int>[];
    while (remaining > 0) {
      final int block = remaining > maxMin ? maxMin : remaining;
      blocks.add(block);
      remaining -= block;
    }
    return blocks;
  }

  static List<int> _distributeMinutesEvenly({
    required int totalMinutes,
    required int parts,
  }) {
    if (parts <= 0) return <int>[];
    if (totalMinutes <= 0) return List<int>.filled(parts, 0);

    final int base = totalMinutes ~/ parts;
    final int remainder = totalMinutes % parts;
    return List<int>.generate(parts, (int i) => base + (i < remainder ? 1 : 0));
  }

  Future<void> _scheduleTransitionNotifications() async {
    final DarknessScheduleSnapshot? snap = snapshotRx.value;
    if (snap == null) return;

    final int minutesBefore = alertMinutesBefore.clamp(0, 180);
    final DateTime now = DateTime.now();
    final List<DateTime> transitions = _transitionTimes(snap.segments);

    for (int i = 0; i < transitions.length; i++) {
      final DateTime at = transitions[i];
      final DateTime scheduledAt =
          minutesBefore > 0
              ? at.subtract(Duration(minutes: minutesBefore))
              : at;
      if (!scheduledAt.isAfter(now)) continue;

      final bool isDarkStarting = _isDarkAtOrAfter(at, snap.segments);
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

  static List<DateTime> _transitionTimes(
    List<DarknessScheduleSegment> segments,
  ) {
    if (segments.length < 2) return <DateTime>[];
    final List<DateTime> out = <DateTime>[];
    for (int i = 1; i < segments.length; i++) {
      final DarknessScheduleSegment prev = segments[i - 1];
      final DarknessScheduleSegment cur = segments[i];
      if (prev.isDark != cur.isDark) {
        out.add(cur.start);
      }
    }
    return out;
  }

  static bool _isDarkAtOrAfter(
    DateTime at,
    List<DarknessScheduleSegment> segments,
  ) {
    final DarknessScheduleSegment? match = segments
        .where(
          (DarknessScheduleSegment s) =>
              (at.isAtSameMomentAs(s.start) || at.isAfter(s.start)) &&
              at.isBefore(s.end),
        )
        .fold<DarknessScheduleSegment?>(
          null,
          (DarknessScheduleSegment? acc, DarknessScheduleSegment s) => acc ?? s,
        );
    if (match != null) return match.isDark;

    final DarknessScheduleSegment? next = segments
        .where((DarknessScheduleSegment s) => s.start.isAfter(at))
        .fold<DarknessScheduleSegment?>(null, (
          DarknessScheduleSegment? acc,
          DarknessScheduleSegment s,
        ) {
          if (acc == null) return s;
          return s.start.isBefore(acc.start) ? s : acc;
        });
    return next?.isDark ?? false;
  }

  Future<void> _cancelDarknessNotifications() async {
    if (!Get.isRegistered<NotificationService>()) return;
    await NotificationService.instance.cancelDarknessNotifications();
  }

  static Duration? durationUntil(DateTime? target) {
    if (target == null) return null;
    final Duration d = target.difference(DateTime.now());
    return d.isNegative ? null : d;
  }
  // ── Permissions Logic ──

  /// Checks if permissions are granted. If not, shows dialog. If granted, enables notifications.
  /// Checks if permissions are granted. If not, shows dialog. If granted, enables notifications.
  Future<bool> requirePermissions() async {
    bool permissionsGranted = await _checkIfPermissionsGranted();
    if (permissionsGranted) {
      notificationsEnabled = true;
      return true;
    }

    if (Get.isDialogOpen ?? false) return false;

    // Wait for dialog result: true = enabled/requested, false = later/dismissed
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
      // Check again after request
      permissionsGranted = await _checkIfPermissionsGranted();
      if (permissionsGranted) {
        notificationsEnabled = true;
        return true;
      }
    }

    // If we are here, either dismissed or permissions still denied
    notificationsEnabled = false;
    return false;
  }

  /// Checks if we should suggest the darkness alarm feature (Day 5).
  Future<void> checkDarknessFeatureSuggestion(int ageInDays) async {
    // Only suggest on the first day of darkness (Day 5, index 4)
    if (ageInDays != 5) return;

    // Check if already shown or alarms already enabled
    if (_storage.read<bool>(StorageKeys.darknessSuggestionShown) == true) return;
    if (notificationsEnabled) return;

    if (Get.isDialogOpen ?? false) return;

    // Mark as shown so we don't annoy user every time they enter screen on Day 5
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
              DarknessSettingsSheet(controller: this),
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
    permissionsGranted.value = notif && exact;
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

    _refresh();
  }
}
