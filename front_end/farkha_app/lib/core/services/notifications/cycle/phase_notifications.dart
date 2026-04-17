import 'cycle_notification_helpers.dart';

class PhaseNotifications {
  static Future<void> schedule(
    CycleNotificationHelpers service,
    int dayOfCycle,
    DateTime scheduledDate,
    String cycleName,
  ) async {
    // --- Day 21 (Transition to Fattening Phase) ---
    if (dayOfCycle == 21) {
      await service.scheduleOneCycleNotification(
        id: 6021,
        scheduledAt: scheduledDate,
        title: '$cycleName: غداً تبدأ مرحلة التسمين',
        body:
            'يرجى متابعة التهوية والحرارة بدقة، وتوفير العلف بالكميات المناسبة لزيادة الوزن. راقب صحة القطيع.',
        payloadMap: {'type': 'cycle_update', 'day': 21},
      );
    }
    // --- Day 32 (Transition to Selling Phase) ---
    else if (dayOfCycle == 32) {
      await service.scheduleOneCycleNotification(
        id: 6032,
        scheduledAt: scheduledDate,
        title: '$cycleName: غداً تبدأ مرحلة البيع',
        body:
            'يرجى وقف المضادات الحيوية والالتزام بفترة السحب. قلل الإضاءة لتهدئة الطيور وتجنب الإجهاد.',
        payloadMap: {'type': 'cycle_update', 'day': 32},
      );
    }
  }
}
