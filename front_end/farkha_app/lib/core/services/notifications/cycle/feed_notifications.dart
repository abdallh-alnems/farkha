import 'cycle_notification_helpers.dart';

class FeedNotifications {
  static Future<void> schedule(
    CycleNotificationHelpers service,
    int dayOfCycle,
    DateTime scheduledDate,
    String cycleName,
  ) async {
    // --- Day 12 (Pre-alert for Nami) ---
    if (dayOfCycle == 12) {
      await service.scheduleOneCycleNotification(
        id: 2012, // Unique ID for Day 12 Pre-Alert
        scheduledAt: scheduledDate,
        title: '$cycleName: تنبيه تغيير العلف غداً',
        body: 'غداً سيتم تغيير العلف من البادي إلى النامي. يرجى التجهيز لذلك.',
        payloadMap: {'type': 'cycle_update', 'day': 12},
      );
    }
    // --- Day 13 (Start Nami) ---
    else if (dayOfCycle == 13) {
      await service.scheduleOneCycleNotification(
        id: 2013, // Unique ID for Day 13 Alert
        scheduledAt: scheduledDate,
        title: '$cycleName: تنبيه تغيير العلف اليوم',
        body: 'اليوم يبدأ استخدام العلف النامي (بدلاً من البادي).',
        payloadMap: {'type': 'cycle_update', 'day': 13},
      );
    }
    // --- Day 24 (Pre-alert for Nahi) ---
    else if (dayOfCycle == 24) {
      await service.scheduleOneCycleNotification(
        id: 2024, // Unique ID for Day 24 Pre-Alert
        scheduledAt: scheduledDate,
        title: '$cycleName: تنبيه تغيير العلف غداً',
        body: 'غداً سيتم تغيير العلف من النامي إلى الناهي. يرجى التجهيز لذلك.',
        payloadMap: {'type': 'cycle_update', 'day': 24},
      );
    }
    // --- Day 25 (Start Nahi) ---
    else if (dayOfCycle == 25) {
      await service.scheduleOneCycleNotification(
        id: 2025, // Unique ID for Day 25 Alert
        scheduledAt: scheduledDate,
        title: '$cycleName: تنبيه تغيير العلف اليوم',
        body: 'اليوم يبدأ استخدام العلف الناهي (بدلاً من النامي).',
        payloadMap: {'type': 'cycle_update', 'day': 25},
      );
    }
  }
}
