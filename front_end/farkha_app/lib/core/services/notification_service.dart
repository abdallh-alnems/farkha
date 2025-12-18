import 'package:firebase_messaging/firebase_messaging.dart';
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
    await _restoreSubscriptions();

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
      // الاشتراك في لحم أبيض افتراضياً
      await subscribeToTopic('lhm_abyad');
      // حفظ الإعداد الافتراضي
      storage.write(_notificationTypesKey, ['lhm_abyad']);
    } else {
      // الاشتراك في جميع الـ topics المحفوظة
      for (var topic in savedNotifications) {
        await subscribeToTopic(topic.toString());
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
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
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

  /// إيقاف/تفعيل الإشعارات داخلياً
  Future<void> setNotificationsEnabled(bool enabled) async {
    final storage = GetStorage();
    storage.write(_notificationsEnabledKey, enabled);

    if (enabled) {
      // إعادة الاشتراك في جميع Topics المحفوظة
      final savedNotifications = storage.read<List<dynamic>>(
        _notificationTypesKey,
      );

      if (savedNotifications != null && savedNotifications.isNotEmpty) {
        for (var topic in savedNotifications) {
          await subscribeToTopic(topic.toString());
        }
      } else {
        // إذا لم تكن هناك topics محفوظة، الاشتراك في الافتراضي
        await subscribeToTopic('lhm_abyad');
        storage.write(_notificationTypesKey, ['lhm_abyad']);
      }
    } else {
      // إلغاء الاشتراك من جميع Topics
      final savedNotifications = storage.read<List<dynamic>>(
        _notificationTypesKey,
      );

      if (savedNotifications != null && savedNotifications.isNotEmpty) {
        for (var topic in savedNotifications) {
          await unsubscribeFromTopic(topic.toString());
        }
      }
    }
  }

  /// التحقق من حالة تفعيل الإشعارات
  bool isNotificationsEnabled() {
    final storage = GetStorage();
    return storage.read<bool>(_notificationsEnabledKey) ?? true;
  }
}
