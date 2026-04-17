import 'cycle_notification_helpers.dart';

class VaccinationNotifications {
  static Future<void> schedule(
    CycleNotificationHelpers service,
    int dayOfCycle,
    DateTime scheduledDate,
    String cycleName,
  ) async {
    // --- Day 6 (Pre-alert for Day 7: B1) ---
    if (dayOfCycle == 6) {
      await service.scheduleOneCycleNotification(
        id: 3006,
        scheduledAt: scheduledDate,
        title: '$cycleName: تذكير تحصين غداً',
        body: 'غداً موعد لقاح B1. يرجى التجهيز.',
        payloadMap: {'type': 'cycle_update', 'day': 6},
      );
    }
    // --- Day 7 (B1 Vaccination) ---
    else if (dayOfCycle == 7) {
      await service.scheduleOneCycleNotification(
        id: 3007,
        scheduledAt: scheduledDate,
        title: '$cycleName: موعد التحصين اليوم',
        body: 'لقاح B1 - التحصين بلقاح B1 يفضل جرعة شرب + جرعة رش',
        payloadMap: {'type': 'cycle_update', 'day': 7},
      );
    }
    // --- Day 12 (Pre-alert for Day 13: Gumboro) ---
    else if (dayOfCycle == 12) {
      await service.scheduleOneCycleNotification(
        id: 3012,
        scheduledAt: scheduledDate,
        title: '$cycleName: تذكير تحصين غداً',
        body: 'غداً موعد تحصين جمبورو عترة خفيفة. يرجى التجهيز.',
        payloadMap: {'type': 'cycle_update', 'day': 12},
      );
    }
    // --- Day 13 (Gumboro Vaccination) ---
    else if (dayOfCycle == 13) {
      await service.scheduleOneCycleNotification(
        id: 3013,
        scheduledAt: scheduledDate,
        title: '$cycleName: موعد التحصين اليوم',
        body:
            'تحصين جمبورو عترة خفيفة - في ماء الشرب (ممكن جرعة أخرى تقطير بالعين)',
        payloadMap: {'type': 'cycle_update', 'day': 13},
      );
    }
    // --- Day 17 (Pre-alert for Day 18: Newcastle) ---
    else if (dayOfCycle == 17) {
      await service.scheduleOneCycleNotification(
        id: 3017,
        scheduledAt: scheduledDate,
        title: '$cycleName: تذكير تحصين غداً',
        body: 'غداً موعد تحصين ضد نيوكاسل. يرجى التجهيز.',
        payloadMap: {'type': 'cycle_update', 'day': 17},
      );
    }
    // --- Day 18 (Newcastle Vaccination) ---
    else if (dayOfCycle == 18) {
      await service.scheduleOneCycleNotification(
        id: 3018,
        scheduledAt: scheduledDate,
        title: '$cycleName: موعد التحصين اليوم',
        body: 'تحصين ضد نيوكاسل - جرعة مزدوجة شراب أو جرعة شراب + جرعة رش',
        payloadMap: {'type': 'cycle_update', 'day': 18},
      );
    }
    // --- Day 21 (Pre-alert for Day 22: Coccidiosis) ---
    else if (dayOfCycle == 21) {
      await service.scheduleOneCycleNotification(
        id: 3021,
        scheduledAt: scheduledDate,
        title: '$cycleName: تذكير تحصين غداً',
        body: 'غداً موعد تحصين كوكسيديا وكولسترديا. يرجى التجهيز.',
        payloadMap: {'type': 'cycle_update', 'day': 21},
      );
    }
    // --- Day 22 (Coccidiosis Vaccination) ---
    else if (dayOfCycle == 22) {
      await service.scheduleOneCycleNotification(
        id: 3022,
        scheduledAt: scheduledDate,
        title: '$cycleName: موعد التحصين اليوم',
        body: 'تحصين كوكسيديا وكولسترديا - في ماء الشرب',
        payloadMap: {'type': 'cycle_update', 'day': 22},
      );
    }
    // --- Day 27 (Pre-alert for Day 28: Lasota) ---
    else if (dayOfCycle == 27) {
      await service.scheduleOneCycleNotification(
        id: 3027,
        scheduledAt: scheduledDate,
        title: '$cycleName: تذكير تحصين غداً',
        body: 'غداً موعد لقاح لاسوتا. يرجى التجهيز.',
        payloadMap: {'type': 'cycle_update', 'day': 27},
      );
    }
    // --- Day 28 (Lasota Vaccination) ---
    else if (dayOfCycle == 28) {
      await service.scheduleOneCycleNotification(
        id: 3028,
        scheduledAt: scheduledDate,
        title: '$cycleName: موعد التحصين اليوم',
        body: 'لقاح لاسوتا - في ماء الشرب (أو بلقاح أفينيو) يفضل جرعة مزدوجة',
        payloadMap: {'type': 'cycle_update', 'day': 28},
      );
    }
  }
}
