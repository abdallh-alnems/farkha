import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';

/// Mixin that encapsulates price / FCM-based notifications:
/// showing, subscribing, unsubscribing, and restoring topic subscriptions.
///
/// Applied to [NotificationService] to keep the main file slim.
mixin PriceNotificationHelpers {
  // ── Subclass must provide ──────────────────────────────────────────────
  FlutterLocalNotificationsPlugin get localNotifications;
  FirebaseMessaging get firebaseMessaging;

  String get channelId;
  String get channelName;
  String get channelDescription;

  String get notificationTypesKey;
  String get notificationsEnabledKey;

  // ── Show ────────────────────────────────────────────────────────────────

  Future<void> showNotification(RemoteMessage message) async {
    // التحقق من حالة الإشعارات المحلية
    final storage = GetStorage();
    final isNotificationsEnabled =
        storage.read<bool>(notificationsEnabledKey) ?? true;

    if (!isNotificationsEnabled) {
      return; // لا نعرض الإشعار إذا كانت الإشعارات معطلة
    }

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: android?.smallIcon ?? '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      sound: const RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: false,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification_sound.caf',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  // ── Subscribe / Unsubscribe ────────────────────────────────────────────

  Future<void> subscribeToTopic(String topic) async {
    try {
      await firebaseMessaging
          .subscribeToTopic(topic)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              if (kDebugMode) {
                debugPrint('Timeout subscribing to topic: $topic');
              }
              throw TimeoutException('Subscription timeout for topic: $topic');
            },
          );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error subscribing to topic $topic: $e');
      }
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await firebaseMessaging
          .unsubscribeFromTopic(topic)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              if (kDebugMode) {
                debugPrint('Timeout unsubscribing from topic: $topic');
              }
              throw TimeoutException(
                'Unsubscription timeout for topic: $topic',
              );
            },
          );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error unsubscribing from topic $topic: $e');
      }
    }
  }

  // ── Restore ────────────────────────────────────────────────────────────

  Future<void> restoreSubscriptions() async {
    final storage = GetStorage();
    final isNotificationsEnabled =
        storage.read<bool>(notificationsEnabledKey) ?? true;

    // إذا كانت الإشعارات معطلة، لا نعيد الاشتراك
    if (!isNotificationsEnabled) {
      return;
    }

    final savedNotifications = storage.read<List<dynamic>>(
      notificationTypesKey,
    );

    // إذا كانت أول مرة (لا توجد إعدادات محفوظة)
    if (savedNotifications == null || savedNotifications.isEmpty) {
      // الاشتراك في لحم أبيض افتراضياً بدون انتظار
      unawaited(
        subscribeToTopic('lhm_abyad').catchError((Object error) {
          if (kDebugMode) {
            debugPrint('Error subscribing to lhm_abyad: $error');
          }
        }),
      );
      // حفظ الإعداد الافتراضي
      unawaited(storage.write(notificationTypesKey, ['lhm_abyad']));
    } else {
      // الاشتراك في جميع الـ topics المحفوظة بدون انتظار
      for (var topic in savedNotifications) {
        unawaited(
          subscribeToTopic(topic.toString()).catchError((Object error) {
            if (kDebugMode) {
              debugPrint('Error subscribing to $topic: $error');
            }
          }),
        );
      }
    }
  }
}
