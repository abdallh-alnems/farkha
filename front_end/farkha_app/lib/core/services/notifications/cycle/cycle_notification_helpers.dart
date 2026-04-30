import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../../data/data_source/static/chicken_data.dart';
import 'care_notifications.dart';
import 'darkness_notifications.dart';
import 'feed_notifications.dart';
import 'phase_notifications.dart';
import 'space_notifications.dart';
import 'vaccination_notifications.dart';

/// Mixin that encapsulates cycle notification scheduling, cancellation,
/// and testing helpers.
///
/// Applied to [NotificationService] to keep the main file slim.
mixin CycleNotificationHelpers {
  // ── Subclass must provide ──────────────────────────────────────────────
  FlutterLocalNotificationsPlugin get localNotifications;

  String get cycleChannelId;
  String get cycleChannelName;
  String get cycleChannelDescription;

  int get cycleNotificationIdMin;
  int get cycleNotificationIdMax;

  // ── Schedule All ──────────────────────────────────────────────────────

  /// Schedules daily notifications for the entire cycle.
  Future<void> scheduleCycleNotifications(
    DateTime startDate, [
    String cycleName = '',
  ]) async {
    await cancelCycleNotifications();

    final maxDays = temperatureList.length;

    for (int i = 0; i < maxDays; i++) {
      final dayOfCycle = i + 1;
      final date = startDate.add(Duration(days: i));
      final scheduledDate = DateTime(date.year, date.month, date.day, 8);

      if (scheduledDate.isBefore(DateTime.now())) continue;

      await FeedNotifications.schedule(
        this,
        dayOfCycle,
        scheduledDate,
        cycleName,
      );
      await VaccinationNotifications.schedule(
        this,
        dayOfCycle,
        scheduledDate,
        cycleName,
      );
      await SpaceNotifications.schedule(
        this,
        dayOfCycle,
        scheduledDate,
        cycleName,
      );
      await PhaseNotifications.schedule(
        this,
        dayOfCycle,
        scheduledDate,
        cycleName,
      );
      await CareNotifications.schedule(
        this,
        dayOfCycle,
        scheduledDate,
        cycleName,
      );
      await DarknessNotifications.schedule(
        this,
        dayOfCycle,
        scheduledDate,
        cycleName,
      );
    }
  }

  // ── Schedule One ──────────────────────────────────────────────────────

  /// Schedules a single cycle notification at [scheduledAt].
  Future<void> scheduleOneCycleNotification({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
    Map<String, dynamic>? payloadMap,
  }) async {
    try {
      final tzDate = tz.TZDateTime.from(scheduledAt, tz.local);

      final androidDetails = AndroidNotificationDetails(
        cycleChannelId,
        cycleChannelName,
        channelDescription: cycleChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        sound: const RawResourceAndroidNotificationSound('notification_sound'),
        styleInformation: BigTextStyleInformation(body),
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound.caf',
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      final payloadJson = jsonEncode(
        payloadMap ??
            {'type': 'cycle_update', 'day': id - cycleNotificationIdMin + 1},
      );

      try {
        await localNotifications.zonedSchedule(
          id,
          title,
          body,
          tzDate,
          details,
          payload: payloadJson,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } catch (_) {
        await localNotifications.zonedSchedule(
          id,
          title,
          body,
          tzDate,
          details,
          payload: payloadJson,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('scheduleOneCycleNotification failed: $e');
      }
    }
  }

  // ── Cancel ─────────────────────────────────────────────────────────────

  /// Cancels all scheduled cycle notifications (IDs 1000–1100)
  /// plus every extended-range ID used by the modular schedulers.
  Future<void> cancelCycleNotifications() async {
    final futures = <Future<void>>[];

    for (var id = cycleNotificationIdMin; id <= cycleNotificationIdMax; id++) {
      futures.add(localNotifications.cancel(id));
    }

    // Feed notifications
    for (final id in [2012, 2013, 2024, 2025]) {
      futures.add(localNotifications.cancel(id));
    }

    // Vaccination notifications
    for (final id in [
      3006,
      3007,
      3012,
      3013,
      3017,
      3018,
      3021,
      3022,
      3027,
      3028,
    ]) {
      futures.add(localNotifications.cancel(id));
    }

    // Space expansion notifications
    for (final id in [4007, 4014, 4021, 4028]) {
      futures.add(localNotifications.cancel(id));
    }

    // Phase transition notifications
    for (final id in [6021, 6032]) {
      futures.add(localNotifications.cancel(id));
    }

    // Weekly Weight
    for (final id in [7007, 7014, 7021, 7028, 7035]) {
      futures.add(localNotifications.cancel(id));
    }

    // Temperature Adjustment
    for (final id in [8004, 8010, 8018, 8025, 8030]) {
      futures.add(localNotifications.cancel(id));
    }

    // General Tips
    for (final id in [9010, 9030]) {
      futures.add(localNotifications.cancel(id));
    }

    // Water Line Cleaning
    for (final id in [9510, 9520, 9530, 9540]) {
      futures.add(localNotifications.cancel(id));
    }

    // Daily Data Reminder (10001 - 10050)
    for (int i = 1; i <= 50; i++) {
      futures.add(localNotifications.cancel(10000 + i));
    }

    // Darkness Transition Reminders (5500 - 5600)
    for (int i = 0; i < 100; i++) {
      futures.add(localNotifications.cancel(5500 + i));
    }

    await Future.wait(futures);
  }

  /// Cancel specific daily data notification for a given day.
  Future<void> cancelDailyDataNotification(int dayOfCycle) async {
    await localNotifications.cancel(10000 + dayOfCycle);
  }

  // ── Test helpers ───────────────────────────────────────────────────────

  /// Shows an immediate notification for testing purposes.
  Future<void> testShowCycleNotification(int dayOfCycle) async {
    // Feed change alerts
    if (dayOfCycle == 12) {
      await _showTestNotification(
        9998,
        'تنبيه تغيير العلف غداً',
        'غداً سيتم تغيير العلف من البادي إلى النامي. يرجى التجهيز لذلك.',
      );
    } else if (dayOfCycle == 13) {
      await _showTestNotification(
        9998,
        'تنبيه تغيير العلف اليوم',
        'اليوم يبدأ استخدام العلف النامي (بدلاً من البادي).',
      );
    } else if (dayOfCycle == 24) {
      await _showTestNotification(
        9998,
        'تنبيه تغيير العلف غداً',
        'غداً سيتم تغيير العلف من النامي إلى الناهي. يرجى التجهيز لذلك.',
      );
    } else if (dayOfCycle == 25) {
      await _showTestNotification(
        9998,
        'تنبيه تغيير العلف اليوم',
        'اليوم يبدأ استخدام العلف الناهي (بدلاً من النامي).',
      );
    }

    // Vaccination alerts
    if (dayOfCycle == 6) {
      await _showTestNotification(
        9997,
        'تذكير: تحصين غداً',
        'غداً موعد لقاح B1. يرجى التجهيز.',
      );
    } else if (dayOfCycle == 7) {
      await _showTestNotification(
        9997,
        'تذكير: موعد التحصين اليوم',
        'لقاح B1 - التحصين بلقاح B1 يفضل جرعة شرب + جرعة رش',
      );
    } else if (dayOfCycle == 17) {
      await _showTestNotification(
        9997,
        'تذكير: تحصين غداً',
        'غداً موعد تحصين ضد نيوكاسل. يرجى التجهيز.',
      );
    } else if (dayOfCycle == 18) {
      await _showTestNotification(
        9997,
        'تذكير: موعد التحصين اليوم',
        'تحصين ضد نيوكاسل - جرعة مزدوجة شراب أو جرعة شراب + جرعة رش',
      );
    } else if (dayOfCycle == 21) {
      await _showTestNotification(
        9997,
        'تذكير: تحصين غداً',
        'غداً موعد تحصين كوكسيديا وكولسترديا. يرجى التجهيز.',
      );
    } else if (dayOfCycle == 22) {
      await _showTestNotification(
        9997,
        'تذكير: موعد التحصين اليوم',
        'تحصين كوكسيديا وكولسترديا - في ماء الشرب',
      );
    } else if (dayOfCycle == 27) {
      await _showTestNotification(
        9997,
        'تذكير: تحصين غداً',
        'غداً موعد لقاح لاسوتا. يرجى التجهيز.',
      );
    } else if (dayOfCycle == 28) {
      await _showTestNotification(
        9997,
        'تذكير: موعد التحصين اليوم',
        'لقاح لاسوتا - في ماء الشرب (أو بلقاح أفينيو) يفضل جرعة مزدوجة',
      );
    }

    // Space expansion alerts
    if (dayOfCycle == 7 ||
        dayOfCycle == 14 ||
        dayOfCycle == 21 ||
        dayOfCycle == 28) {
      await _showTestNotification(
        4000 + dayOfCycle,
        'تنبيه: توسيع المساحة غداً',
        'غداً يزيد عمر الكتاكيت وتحتاج لتوسيع مساحة التحضين لضمان التهوية والنمو السليم.',
      );
    }

    // Phase transition alerts
    if (dayOfCycle == 21) {
      await _showTestNotification(
        6021,
        'غداً تبدأ مرحلة التسمين',
        'يرجى متابعة التهوية والحرارة بدقة، وتوفير العلف بالكميات المناسبة لزيادة الوزن. راقب صحة القطيع.',
      );
    } else if (dayOfCycle == 32) {
      await _showTestNotification(
        6032,
        'غداً تبدأ مرحلة البيع',
        'يرجى وقف المضادات الحيوية والالتزام بفترة السحب. قلل الإضاءة لتهدئة الطيور وتجنب الإجهاد.',
      );
    }

    // Weekly Weight
    if ([7, 14, 21, 28, 35].contains(dayOfCycle)) {
      await _showTestNotification(
        7000 + dayOfCycle,
        'تنبيه: وزن الفراخ الأسبوعي',
        'اليوم $dayOfCycle من الدورة. يرجى وزن عينة من الفراخ للتأكد من مطابقة الوزن للمعدل الطبيعي واكتشاف أي مشاكل.',
      );
    }

    // Temperature Adjustment
    if ([4, 10, 18, 25, 30].contains(dayOfCycle)) {
      await _showTestNotification(
        8000 + dayOfCycle,
        'تنبيه: ضبط درجة الحرارة',
        'عمر الكتاكيت الآن $dayOfCycle أيام. يرجى مراجعة درجة الحرارة وتخفيضها تدريجياً لتناسب العمر الحالي.',
      );
    }

    // General Tips
    if (dayOfCycle == 10) {
      await _showTestNotification(
        9010,
        'نصيحة اليوم: فرش العنبر',
        'تأكد من تقليب الفرشة جيداً ومنع الرطوبة للحفاظ على صحة الكتاكيت وتجنب الأمراض.',
      );
    } else if (dayOfCycle == 30) {
      await _showTestNotification(
        9030,
        'نصيحة اليوم: التهوية',
        'مع زيادة الأوزان، تأكد من زيادة معدل التهوية لتقليل الأمونيا وتوفير هواء نقي.',
      );
    }

    // Water Line Cleaning
    if ([10, 20, 30, 40].contains(dayOfCycle)) {
      await _showTestNotification(
        9500 + dayOfCycle,
        'نصيحة وقائية: غسيل خطوط المياه',
        'تتراكم البكتيريا (البيوفيلم) في المواسير وتقلل كفاءة الأدوية. يفضل غسيل الخطوط اليوم لضمان نظافة المياه.',
      );
    }

    // Daily Data Entry Reminder (test only)
    if (dayOfCycle == -1) {
      await _showTestNotification(
        10001,
        'تذكير: تسجيل بيانات اليوم',
        'يرجى تسجيل استهلاك العلف والوفيات اليوم للحصول على حسابات دقيقة ومتابعة أداء الدورة.',
        payload: {'type': 'cycle_update'},
      );
    }

    // Darkness Transition Test
    if (dayOfCycle == -2) {
      await _showTestNotification(
        5505,
        'تنبيه: إظلام غداً (تجربة)',
        'غداً يبدأ تطبيق الإظلام (1 مراحل). يرجى ضبط مواعيد المنبه من صفحة الإظلام.',
        payload: {'type': 'darkness_config'},
      );
    }
  }

  /// Shows an immediate (non-scheduled) notification — used for smart alerts.
  Future<void> showImmediateAlertNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    await _showTestNotification(id, title, body, payload: payload);
  }

  Future<void> _showTestNotification(
    int id,
    String title,
    String body, {
    Map<String, dynamic>? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      cycleChannelId,
      cycleChannelName,
      channelDescription: cycleChannelDescription,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      sound: const RawResourceAndroidNotificationSound('notification_sound'),
      styleInformation: BigTextStyleInformation(body),
      importance: Importance.max,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );
    final payloadJson = jsonEncode(
      payload ?? {'type': 'cycle_update', 'day': 1},
    );

    await localNotifications.show(
      id,
      title,
      body,
      details,
      payload: payloadJson,
    );
  }
}
