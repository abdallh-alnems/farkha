import 'cycle_notification_helpers.dart';

class CareNotifications {
  static Future<void> schedule(
    CycleNotificationHelpers service,
    int dayOfCycle,
    DateTime scheduledDate,
    String cycleName,
  ) async {
    // Schedule Weekly Weight Check
    if (dayOfCycle == 7 ||
        dayOfCycle == 14 ||
        dayOfCycle == 21 ||
        dayOfCycle == 28 ||
        dayOfCycle == 35) {
      await service.scheduleOneCycleNotification(
        id: 7000 + dayOfCycle,
        scheduledAt: scheduledDate,
        title: '$cycleName: وزن الفراخ الأسبوعي',
        body:
            'اليوم $dayOfCycle من الدورة. يرجى وزن عينة من الفراخ للتأكد من مطابقة الوزن للمعدل الطبيعي واكتشاف أي مشاكل.',
        payloadMap: {'type': 'cycle_update', 'day': dayOfCycle},
      );
    }

    // Schedule Temperature Adjustment
    if (dayOfCycle == 4 ||
        dayOfCycle == 10 ||
        dayOfCycle == 18 ||
        dayOfCycle == 25 ||
        dayOfCycle == 30) {
      await service.scheduleOneCycleNotification(
        id: 8000 + dayOfCycle,
        scheduledAt: scheduledDate,
        title: '$cycleName: تنبيه ضبط الحرارة',
        body:
            'عمر الكتاكيت الآن $dayOfCycle أيام. يرجى مراجعة درجة الحرارة وتخفيضها تدريجياً لتناسب العمر الحالي.',
        payloadMap: {'type': 'cycle_update', 'day': dayOfCycle},
      );
    }

    // Schedule General Care Tips
    if (dayOfCycle == 10) {
      await service.scheduleOneCycleNotification(
        id: 9010,
        scheduledAt: scheduledDate,
        title: '$cycleName: نصيحة اليوم (فرش العنبر)',
        body:
            'تأكد من تقليب الفرشة جيداً ومنع الرطوبة للحفاظ على صحة الكتاكيت وتجنب الأمراض.',
        payloadMap: {'type': 'cycle_update', 'day': 10},
      );
    } else if (dayOfCycle == 30) {
      await service.scheduleOneCycleNotification(
        id: 9030,
        scheduledAt: scheduledDate,
        title: 'نصيحة اليوم: التهوية',
        body:
            'مع زيادة الأوزان، تأكد من زيادة معدل التهوية لتقليل الأمونيا وتوفير هواء نقي.',
        payloadMap: {'type': 'cycle_update', 'day': 30},
      );
    }

    // Schedule Water Line Cleaning
    if (dayOfCycle == 10 ||
        dayOfCycle == 20 ||
        dayOfCycle == 30 ||
        dayOfCycle == 40) {
      await service.scheduleOneCycleNotification(
        id: 9500 + dayOfCycle,
        scheduledAt: scheduledDate,
        title: '$cycleName: نصيحة وقائية (غسيل المياه)',
        body:
            'تتراكم البكتيريا (البيوفيلم) في المواسير وتقلل كفاءة الأدوية. يفضل غسيل الخطوط اليوم لضمان نظافة المياه.',
        payloadMap: {'type': 'cycle_update', 'day': dayOfCycle},
      );
    }

    // Schedule Daily Data Entry Reminder (at 9 PM)
    // scheduledDate is currently at 8 AM. We need 9 PM (21:00).
    final dataEntryTime = scheduledDate.add(const Duration(hours: 13));
    await service.scheduleOneCycleNotification(
      id: 10000 + dayOfCycle,
      scheduledAt: dataEntryTime,
      title: '$cycleName: تسجيل البيانات',
      body: 'يرجى تسجيل بيانات الدورة لليوم للحفاظ على دقة التقارير.',
      payloadMap: {'type': 'cycle_update', 'day': dayOfCycle},
    );
  }
}
