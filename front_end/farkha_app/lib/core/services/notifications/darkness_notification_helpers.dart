import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Mixin that encapsulates darkness-related notification scheduling
/// and cancellation.
///
/// Applied to [NotificationService] to keep the main file slim.
mixin DarknessNotificationHelpers {
  // ── Subclass must provide ──────────────────────────────────────────────
  FlutterLocalNotificationsPlugin get localNotifications;

  int get darknessNotificationIdMin;
  int get darknessNotificationIdMax;
  String get darknessChannelId;
  String get darknessChannelName;
  String get darknessChannelDescription;

  // ── Schedule ───────────────────────────────────────────────────────────

  /// Schedules a local notification for darkness/light reminder at [scheduledAt].
  /// When [phase] is set, payload opens the full-screen alarm page on tap or full-screen intent.
  Future<void> scheduleDarknessNotification({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
    int? phase,
    bool fullScreen = false,
    String? cycleName,
    String? duration,
    String? startTime,
    String? endTime,
    int? totalPhases,
    int? age,
    int? totalDarknessHours,
  }) async {
    if (id < darknessNotificationIdMin || id > darknessNotificationIdMax) {
      return;
    }
    try {
      final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledAt, tz.local);
      final bool shouldUseFullScreen = fullScreen || phase != null;
      final String? payload =
          shouldUseFullScreen
              ? jsonEncode({
                'type': 'darkness_alarm',
                'title': title,
                'body': body,
                if (phase != null) 'phase': phase,
                if (cycleName != null) 'cycleName': cycleName,
                if (duration != null) 'duration': duration,
                if (startTime != null) 'startTime': startTime,
                if (endTime != null) 'endTime': endTime,
                if (totalPhases != null) 'totalPhases': totalPhases,
                if (age != null) 'age': age,
                if (totalDarknessHours != null)
                  'totalDarknessHours': totalDarknessHours,
              })
              : null;

      final androidDetails = AndroidNotificationDetails(
        darknessChannelId,
        darknessChannelName,
        channelDescription: darknessChannelDescription,
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        sound: const RawResourceAndroidNotificationSound('notification_sound'),
        fullScreenIntent: shouldUseFullScreen,
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

      try {
        await localNotifications.zonedSchedule(
          id,
          title,
          body,
          tzDate,
          details,
          payload: payload,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } catch (_) {
        await localNotifications.zonedSchedule(
          id,
          title,
          body,
          tzDate,
          details,
          payload: payload,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('scheduleDarknessNotification failed: $e');
      }
    }
  }

  // ── Cancel ─────────────────────────────────────────────────────────────

  /// Cancels all scheduled darkness notifications (IDs 5000–5999).
  Future<void> cancelDarknessNotifications() async {
    for (
      var id = darknessNotificationIdMin;
      id <= darknessNotificationIdMax;
      id++
    ) {
      await localNotifications.cancel(id);
    }
  }
}
