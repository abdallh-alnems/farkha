import '../../../data/data_source/static/chicken_data.dart';
import 'darkness_schedule_models.dart';

const int kMaxDarknessBlockMinutes = 120;
const int kScheduleDayMinutes = 24 * 60;

int numberOfPhases(int totalDarknessHours) {
  final int h = totalDarknessHours.clamp(0, 24);
  if (h <= 0) return 0;
  if (h <= 2) return h;
  final int minutes = h * 60;
  return (minutes / kMaxDarknessBlockMinutes).ceil();
}

int effectiveAgeForNow({
  required String startDateRaw,
  required int ageInDays,
  required int dayStartHour,
}) {
  final DateTime? start = DateTime.tryParse(startDateRaw);
  if (start == null) return ageInDays;

  final DateTime farmDayStartCalc = farmDayStart(
    start: start,
    ageInDays: ageInDays,
    dayStartHour: dayStartHour,
  );

  if (DateTime.now().isBefore(farmDayStartCalc)) {
    return (ageInDays - 1).clamp(1, darknessLevels.length);
  }
  return ageInDays.clamp(1, darknessLevels.length);
}

DateTime farmDayStart({
  required DateTime start,
  required int ageInDays,
  required int dayStartHour,
}) {
  final DateTime dayDate = start.add(Duration(days: ageInDays - 1));
  return DateTime(dayDate.year, dayDate.month, dayDate.day, dayStartHour);
}

List<DarknessScheduleSegment> buildDailySchedule({
  required DateTime dayStart,
  required int totalDarknessHours,
}) {
  final int clampedDarkHours = totalDarknessHours.clamp(0, 24);
  final int darknessMinutes = clampedDarkHours * 60;
  final int lightMinutes = kScheduleDayMinutes - darknessMinutes;

  if (darknessMinutes <= 0) {
    return <DarknessScheduleSegment>[
      DarknessScheduleSegment(
        start: dayStart,
        end: dayStart.add(const Duration(minutes: kScheduleDayMinutes)),
        isDark: false,
      ),
    ];
  }

  final List<int> darkBlocks = _splitIntoMaxMinutes(
    totalMinutes: darknessMinutes,
    maxBlockMinutes: kMaxDarknessBlockMinutes,
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
    const Duration(minutes: kScheduleDayMinutes),
  );
  if (cursor.isBefore(expectedEnd)) {
    out.add(
      DarknessScheduleSegment(start: cursor, end: expectedEnd, isDark: false),
    );
  }

  return out;
}

DarknessScheduleSnapshot computeSnapshotNow({
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

List<int> _splitIntoMaxMinutes({
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

List<int> _distributeMinutesEvenly({
  required int totalMinutes,
  required int parts,
}) {
  if (parts <= 0) return <int>[];
  if (totalMinutes <= 0) return List<int>.filled(parts, 0);

  final int base = totalMinutes ~/ parts;
  final int remainder = totalMinutes % parts;
  return List<int>.generate(parts, (int i) => base + (i < remainder ? 1 : 0));
}

List<DateTime> transitionTimes(
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

bool isDarkAtOrAfter(
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

Duration? durationUntil(DateTime? target) {
  if (target == null) return null;
  final Duration d = target.difference(DateTime.now());
  return d.isNegative ? null : d;
}
