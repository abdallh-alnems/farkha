import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Firebase Cloud Messaging Notification Service for Android
/// Handles notification channel creation and message processing
///
/// Background message handler
/// Must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // التحقق من حالة الإشعارات قبل العرض
  final storage = GetStorage();
  final isNotificationsEnabled =
      storage.read<bool>('notifications_enabled') ?? true;

  if (isNotificationsEnabled) {
    await NotificationService.instance.showNotification(message);
  }
}

class NotificationService extends GetxService {
  static NotificationService get instance => Get.find();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Notification channel details
  static const String _channelId = 'farkha_notifications_channel';
  static const String _channelName = 'إشعارات فرخة';
  static const String _channelDescription =
      'إشعارات تحديثات أسعار الدجاج والأخبار';

  static const String _notificationTypesKey = 'notification_enabled_types';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  Future<NotificationService> init() async {
    await _initializeLocalNotifications();
    await _requestPermissions();
    await _createNotificationChannel();
    await _configureFirebaseMessaging();

    // تشغيل الاشتراك في background بدون انتظار لتجنب ANR
    Future.microtask(() => _restoreSubscriptions());

    return this;
  }

  Future<void> _restoreSubscriptions() async {
    final storage = GetStorage();
    final isNotificationsEnabled =
        storage.read<bool>(_notificationsEnabledKey) ?? true;

    // إذا كانت الإشعارات معطلة، لا نعيد الاشتراك
    if (!isNotificationsEnabled) {
      return;
    }

    final savedNotifications = storage.read<List<dynamic>>(
      _notificationTypesKey,
    );

    // إذا كانت أول مرة (لا توجد إعدادات محفوظة)
    if (savedNotifications == null || savedNotifications.isEmpty) {
      // الاشتراك في لحم أبيض افتراضياً بدون انتظار
      subscribeToTopic('lhm_abyad').catchError((error) {
        if (kDebugMode) {
          debugPrint('Error subscribing to lhm_abyad: $error');
        }
      });
      // حفظ الإعداد الافتراضي
      storage.write(_notificationTypesKey, ['lhm_abyad']);
    } else {
      // الاشتراك في جميع الـ topics المحفوظة بدون انتظار
      for (var topic in savedNotifications) {
        subscribeToTopic(topic.toString()).catchError((error) {
          if (kDebugMode) {
            debugPrint('Error subscribing to $topic: $error');
          }
        });
      }
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _requestPermissions() async {
    // Note: Permission requests are handled by PermissionController
    // No need to request permissions here for Android
  }

  Future<void> _createNotificationChannel() async {
    final androidChannel = const AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: false,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _configureFirebaseMessaging() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      // التحقق من حالة الإشعارات قبل العرض
      final storage = GetStorage();
      final isNotificationsEnabled =
          storage.read<bool>(_notificationsEnabledKey) ?? true;
      if (isNotificationsEnabled) {
        showNotification(message);
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle notification tap when app is terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    // التحقق من حالة الإشعارات المحلية
    final storage = GetStorage();
    final isNotificationsEnabled =
        storage.read<bool>(_notificationsEnabledKey) ?? true;

    if (!isNotificationsEnabled) {
      return; // لا نعرض الإشعار إذا كانت الإشعارات معطلة
    }

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: android?.smallIcon ?? '@mipmap/ic_launcher',
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: false,
      showWhen: true,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging
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
      // لا نرمي الخطأ، فقط نسجله لتجنب تعطيل التطبيق
      // الخطأ سيتم التعامل معه في catchError في الأماكن التي تستدعي هذه الدالة
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging
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
      // لا نرمي الخطأ، فقط نسجله لتجنب تعطيل التطبيق
      // الخطأ سيتم التعامل معه في catchError في الأماكن التي تستدعي هذه الدالة
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Handle notification tap with payload
      // You can navigate to specific screens based on payload
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    if (data.isNotEmpty) {
      // Handle notification tap with data
      // You can navigate to specific screens based on data
    }
  }
}
