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
