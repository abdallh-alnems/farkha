import '../../../../data/data_source/static/chicken_data.dart';
import '../../../../logic/controller/tools_controller/darkness_schedule_controller.dart';
import 'cycle_notification_helpers.dart';

class DarknessNotifications {
  static Future<void> schedule(
    CycleNotificationHelpers service,
    int dayOfCycle,
    DateTime scheduledDate,
    String cycleName,
  ) async {
    // Check if darkness phases increase tomorrow
    // Note: darknessLevels is 0-indexed, so dayOfCycle-1 is today's index.
    // dayOfCycle is tomorrow's index relative to start.
    // Wait, dayOfCycle is 1-based index for 'date'.
    // 'date' is startDate + i days.
    // If i=0, dayOfCycle=1. date is Day 1.
    // We want to alert on dayOfCycle (Day X) about changes on Day X+1?
    // No, usually we alert "Tomorrow...".
    // So if today is Day X, we check Day X+1.

    if (dayOfCycle < darknessLevels.length) {
      // Today's phases (based on current loop day)
      // Actually, we want to schedule on Day X to alert about Day X+1.
      // So we need phases for Day X+1.
      final int nextDayIndex = dayOfCycle;
      final int todayIndex = dayOfCycle - 1;

      // Check bounds
      if (todayIndex < 0 ||
          todayIndex >= darknessLevels.length ||
          nextDayIndex >= darknessLevels.length) {
        return;
      }

      final int todayHours = darknessLevels[todayIndex];
      final int nextDayHours = darknessLevels[nextDayIndex];

      final int todayPhases = _calcDarknessPhases(todayHours);
      final int nextPhases = _calcDarknessPhases(nextDayHours);

      if (nextPhases > todayPhases) {
        // Schedule Pre-alert for Darkness Change
        String body;
        if (todayPhases == 0) {
          body =
              'غداً يبدأ تطبيق الإظلام ($nextPhases مراحل). يرجى ضبط مواعيد المنبه من صفحة الإظلام.';
        } else {
          body =
              'غداً تزيد مراحل الإظلام إلى $nextPhases مراحل. يرجى تعديل مواعيد المنبه.';
        }

        await service.scheduleOneCycleNotification(
          id: DarknessScheduleController.transitionReminderId(dayOfCycle),
          scheduledAt: scheduledDate, // 8:00 AM
          title: '$cycleName: تنبيه إظلام غداً',
          body: body,
          payloadMap: {'type': 'darkness_config'},
        );
      }
    }
  }

  static int _calcDarknessPhases(int hours) {
    if (hours <= 0) return 0;
    // Logic from DarknessScheduleController:
    // hours <= 2 -> hours (1 or 2 phases, 1h each implicitly or just hours count?)
    // Controller logic:
    // if (h <= 2) return h;
    // else ceil(hours * 60 / 120)
    final int h = hours.clamp(0, 24);
    if (h <= 0) return 0;
    if (h <= 2) return h;
    return (h * 60 / 120).ceil();
  }
}
