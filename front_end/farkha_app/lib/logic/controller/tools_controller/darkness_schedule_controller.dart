import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/constant/storage_keys.dart';
import '../../../data/data_source/static/chicken_data.dart';
import 'darkness_alarm_helper.dart';
import 'darkness_schedule_models.dart';
import 'darkness_schedule_utils.dart';

export 'darkness_schedule_models.dart';

class DarknessScheduleController extends GetxController {
  static int phaseReminderId(int phaseIndex1Based) =>
      DarknessAlarmHelper.phaseReminderId(phaseIndex1Based);

  static int transitionReminderId(int index0Based) =>
      DarknessAlarmHelper.transitionReminderId(index0Based);

  static const int _kDefaultDayStartHour = 6;
  static const int _kDefaultAlertMinutesBefore = 10;
  static const bool _kDefaultNotificationsEnabled = true;

  final GetStorage _storage = GetStorage();

  late final DarknessAlarmHelper _alarmHelper;

  final Rx<DarknessScheduleSnapshot?> snapshotRx =
      Rx<DarknessScheduleSnapshot?>(null);
  final RxInt darknessHoursForDayRx = 0.obs;

  final RxInt dayStartHourRx = RxInt(_kDefaultDayStartHour);
  final RxInt alertMinutesBeforeRx = RxInt(_kDefaultAlertMinutesBefore);
  final RxBool notificationsEnabledRx = RxBool(_kDefaultNotificationsEnabled);

  final RxInt phaseReminderUpdateTrigger = 0.obs;

  final RxBool manualDarknessActive = false.obs;
  final Rx<DateTime?> manualDarknessEndTime = Rx<DateTime?>(null);

  final RxInt manualDarknessTicker = 0.obs;

  final RxInt phasesCompletedToday = 0.obs;

  Timer? _ticker;
  String? _lastStartDateRaw;
  int? _lastAgeInDays;

  final RxBool permissionsGranted = false.obs;

  int? get lastAgeInDays => _lastAgeInDays;

  String get cycleDayKeyForToday => _cycleDayKeyForToday();

  DateTime? get cycleDayDateForToday => _cycleDayDateForToday();

  DarknessAlarmHelper get alarmHelper => _alarmHelper;

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
      unawaited(_alarmHelper.cancelDarknessNotifications());
    } else {
      _refresh();
    }
  }

  @override
  void onInit() {
    super.onInit();
    _alarmHelper = DarknessAlarmHelper(this);
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
      unawaited(_alarmHelper.cancelDarknessNotifications());
      return;
    }

    _lastStartDateRaw = startDateRaw;
    _lastAgeInDays = ageInDays;

    final int effectiveAge = effectiveAgeForNow(
      startDateRaw: startDateRaw,
      ageInDays: ageInDays,
      dayStartHour: dayStartHour,
    );

    final int darknessHours = darknessLevels[effectiveAge - 1];
    darknessHoursForDayRx.value = darknessHours;

    _loadPhasesCompletedForToday();
    _recomputeSnapshot();
    _startTicker();
    unawaited(_alarmHelper.rescheduleAllNotifications());
  }

  void _refresh() {
    if (_lastStartDateRaw == null || _lastAgeInDays == null) return;
    _recomputeSnapshot();
    unawaited(_alarmHelper.rescheduleAllNotifications());
  }

  @override
  void refresh() {
    _refresh();
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
            _alarmHelper.checkForegroundPhaseAlarm();
          });
          return;
        }
        manualDarknessTicker.value++;
        return;
      }
      _recomputeSnapshot();
      _alarmHelper.checkForegroundPhaseAlarm();
    }

    if (manualDarknessActive.value) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => onTick());
    } else {
      _ticker = Timer.periodic(const Duration(minutes: 1), (_) => onTick());
    }
  }

  void startManualDarkness() {
    if (manualDarknessActive.value) return;

    final int totalHours = darknessHoursForDayRx.value;
    final double periodHours =
        totalHours <= 0
            ? 2.0
            : (totalHours / numberOfPhases(totalHours))
                .clamp(0.5, 2.0)
                .toDouble();
    final int periodMinutes = (periodHours * 60).round().clamp(
      1,
      kMaxDarknessBlockMinutes,
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

        if (notificationsEnabled) {
          _alarmHelper.checkForegroundPhaseAlarm();
        }

        _ticker?.cancel();
        _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
          _recomputeSnapshot();
          _alarmHelper.checkForegroundPhaseAlarm();
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

    final int effectiveAge = effectiveAgeForNow(
      startDateRaw: startDateRaw,
      ageInDays: ageInDays,
      dayStartHour: dayStartHour,
    );

    final int totalDarknessHours = darknessLevels[effectiveAge - 1];
    final DateTime farmDayStartCalc = farmDayStart(
      start: start,
      ageInDays: effectiveAge,
      dayStartHour: dayStartHour,
    );
    final DateTime farmDayEnd = farmDayStartCalc.add(const Duration(hours: 24));

    final List<DarknessScheduleSegment> segments = buildDailySchedule(
      dayStart: farmDayStartCalc,
      totalDarknessHours: totalDarknessHours,
    );

    snapshotRx.value = computeSnapshotNow(
      now: DateTime.now(),
      totalDarknessHours: totalDarknessHours,
      dayStart: farmDayStartCalc,
      dayEnd: farmDayEnd,
      segments: segments,
    );
  }

  int get numberOfPhasesForToday {
    final int h = darknessHoursForDayRx.value;
    return numberOfPhases(h);
  }

  DateTime? get nextAlarmTime {
    if (!notificationsEnabled) return null;
    final List<DateTime> times = _alarmHelper.getPhaseReminderTimesNext();
    if (times.isEmpty) return null;
    times.sort();
    return times.first;
  }

  double get periodLengthHoursForDisplay {
    final int h = darknessHoursForDayRx.value;
    if (h <= 0) return 0;
    final int n = numberOfPhases(h);
    if (n <= 0) return 0;
    return (h / n).clamp(0.5, 2.0).toDouble();
  }

  int? getPhaseReminderHour(int phase1Based) {
    final List<dynamic>? list = _storage.read<List<dynamic>>(
      StorageKeys.darknessPhaseReminderHours,
    );
    if (list != null && phase1Based <= list.length) {
      final Object? v = list[phase1Based - 1];
      if (v == null) return null;
      final int? h = (v is num) ? v.toInt() : int.tryParse(v.toString());
      if (h != null && h >= 0 && h <= 23) return h;
    }
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

    final int effectiveAge = effectiveAgeForNow(
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

  Future<bool> requirePermissions() => _alarmHelper.requirePermissions();

  Future<void> checkDarknessFeatureSuggestion(int ageInDays) =>
      _alarmHelper.checkDarknessFeatureSuggestion(ageInDays);

  Future<void> minimizeApp() => _alarmHelper.minimizeApp();
}
