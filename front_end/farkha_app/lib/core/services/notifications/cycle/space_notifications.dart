import 'cycle_notification_helpers.dart';

class SpaceNotifications {
  static Future<void> schedule(
    CycleNotificationHelpers service,
    int dayOfCycle,
    DateTime scheduledDate,
    String cycleName,
  ) async {
    // --- Days 7, 14, 21, 28 (Alert for expansion tomorrow) ---
    if (dayOfCycle == 7 ||
        dayOfCycle == 14 ||
        dayOfCycle == 21 ||
        dayOfCycle == 28) {
      await service.scheduleOneCycleNotification(
        id: 4000 + dayOfCycle,
        scheduledAt: scheduledDate,
        title: '$cycleName: تنبيه توسيع المساحة',
        body:
            'غداً يزيد عمر الكتاكيت وتحتاج لتوسيع مساحة التحضين لضمان التهوية والنمو السليم.',
        payloadMap: {'type': 'cycle_update', 'day': dayOfCycle},
      );
    }
  }
}
