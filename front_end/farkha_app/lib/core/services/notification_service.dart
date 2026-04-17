import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;

import '../constant/headers.dart';
import '../constant/id/api.dart';
import '../constant/routes/route.dart';
import '../../logic/controller/cycle_controller.dart';
import 'notifications/cycle/cycle_notification_helpers.dart';
import 'notifications/darkness_notification_helpers.dart';
import 'notifications/price_notification_helpers.dart';

/// Background message handler — must be top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final storage = GetStorage();
  final enabled = storage.read<bool>('notifications_enabled') ?? true;
  if (enabled) {
    await NotificationService.instance.showNotification(message);
  }
}

class NotificationService extends GetxService
    with
        CycleNotificationHelpers,
        DarknessNotificationHelpers,
        PriceNotificationHelpers {
  static NotificationService get instance => Get.find();

  // ── Core instances ─────────────────────────────────────────────────────
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // ── Channel constants ──────────────────────────────────────────────────
  static const String _channelId = 'farkha_notifications_channel';
  static const String _channelName = 'إشعارات فرخة';
  static const String _channelDescription =
      'إشعارات تحديثات أسعار الدجاج والأخبار';

  static const String _notificationTypesKey = 'notification_enabled_types';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  // Darkness (IDs 5000–5999)
  static const int _darknessNotificationIdMin = 5000;
  static const int _darknessNotificationIdMax = 5999;
  static const String _darknessChannelId = 'farkha_darkness_channel';
  static const String _darknessChannelName = 'تنبيهات الإظلام';
  static const String _darknessChannelDescription =
      'تنبيهات أوقات الإضاءة والإظلام في المزرعة';

  // Cycle (IDs 1000–1100)
  static const int _cycleNotificationIdMin = 1000;
  static const int _cycleNotificationIdMax = 1100;
  static const String _cycleChannelId = 'farkha_cycle_channel';
  static const String _cycleChannelName = 'تنبيهات الدورة';
  static const String _cycleChannelDescription = 'تنبيهات يومية عن حالة الدورة';

  // ── Mixin getters ──────────────────────────────────────────────────────
  @override
  FlutterLocalNotificationsPlugin get localNotifications => _localNotifications;
  @override
  FirebaseMessaging get firebaseMessaging => _firebaseMessaging;

  // Price mixin
  @override
  String get channelId => _channelId;
  @override
  String get channelName => _channelName;
  @override
  String get channelDescription => _channelDescription;
  @override
  String get notificationTypesKey => _notificationTypesKey;
  @override
  String get notificationsEnabledKey => _notificationsEnabledKey;

  // Darkness mixin
  @override
  int get darknessNotificationIdMin => _darknessNotificationIdMin;
  @override
  int get darknessNotificationIdMax => _darknessNotificationIdMax;
  @override
  String get darknessChannelId => _darknessChannelId;
  @override
  String get darknessChannelName => _darknessChannelName;
  @override
  String get darknessChannelDescription => _darknessChannelDescription;

  // Cycle mixin
  @override
  int get cycleNotificationIdMin => _cycleNotificationIdMin;
  @override
  int get cycleNotificationIdMax => _cycleNotificationIdMax;
  @override
  String get cycleChannelId => _cycleChannelId;
  @override
  String get cycleChannelName => _cycleChannelName;
  @override
  String get cycleChannelDescription => _cycleChannelDescription;

  // ── Initialization ─────────────────────────────────────────────────────

  Future<NotificationService> init() async {
    tz_data.initializeTimeZones();
    if (tz.local.name == 'UTC') {
      try {
        tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
      } catch (_) {}
    }

    await _initializeLocalNotifications();
    await _checkAlarmLaunchFromNotification();
    await _createChannel(
      _channelId,
      _channelName,
      _channelDescription,
      Importance.high,
      enableVibration: false,
    );
    await _createChannel(
      _darknessChannelId,
      _darknessChannelName,
      _darknessChannelDescription,
      Importance.max,
    );
    await _createChannel(
      _cycleChannelId,
      _cycleChannelName,
      _cycleChannelDescription,
      Importance.high,
    );
    await _configureFirebaseMessaging();
    syncToken();

    // استعادة الاشتراكات في الخلفية لتجنب ANR
    unawaited(Future.microtask(() => restoreSubscriptions()));

    return this;
  }

  Future<void> syncToken() async {
    Future<void> sendToServer(String fToken, String dToken) async {
      try {
        final headers = getMyHeaders();
        headers['Content-Type'] = 'application/json';
        await http.post(
          Uri.parse(Api.updateFcmToken),
          headers: headers,
          body: jsonEncode({'token': fToken, 'fcm_token': dToken}),
        );
      } catch (_) {}
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final firebaseToken = await user.getIdToken();
      if (firebaseToken == null) return;

      final fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        await sendToServer(firebaseToken, fcmToken);
      }

      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
        if (idToken != null) {
          await sendToServer(idToken, newToken);
        }
      });
    } catch (_) {}
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _createChannel(
    String id,
    String name,
    String description,
    Importance importance, {
    bool enableVibration = true,
  }) async {
    final androidChannel = AndroidNotificationChannel(
      id,
      name,
      description: description,
      importance: importance,
      sound: const RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: enableVibration,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _configureFirebaseMessaging() async {
    FirebaseMessaging.onMessage.listen((message) {
      final storage = GetStorage();
      final enabled = storage.read<bool>(_notificationsEnabledKey) ?? true;
      if (enabled) showNotification(message);

      // Refresh invitations list transparently in background
      final type = message.data['type'];
      if (type == 'cycle_invitation' || type == 'invitation_response') {
        if (Get.isRegistered<CycleController>()) {
          Get.find<CycleController>().fetchInvitations();
        }
      }

      // العضو المحذوف: احذف الدورة من قائمته فوراً
      if (type == 'member_removed') {
        final cycleIdRaw = message.data['cycle_id'];
        final cycleId = cycleIdRaw != null ? int.tryParse(cycleIdRaw.toString()) : null;
        if (cycleId != null && Get.isRegistered<CycleController>()) {
          final ctrl = Get.find<CycleController>();
          ctrl.cycles.removeWhere((c) {
            final cId = c['cycle_id'];
            final cIdInt = cId is int ? cId : int.tryParse(cId?.toString() ?? '');
            return cIdInt == cycleId;
          });
          // إذا كانت currentCycle هي نفس الدورة المحذوفة، امسحها
          final currentId = ctrl.currentCycle['cycle_id'];
          final currentIdInt = currentId is int ? currentId : int.tryParse(currentId?.toString() ?? '');
          if (currentIdInt == cycleId) {
            ctrl.currentCycle.clear();
            if (ctrl.cycles.isNotEmpty) {
              ctrl.currentCycle.assignAll(ctrl.cycles.first);
            }
          }
        }
      }
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) _handleNotificationTap(initialMessage);
  }

  // ── Navigation handlers ────────────────────────────────────────────────

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    final darknessArgs = _parseDarknessAlarmPayload(payload);
    if (darknessArgs != null) {
      Get.toNamed<void>(AppRoute.darknessAlarm, arguments: darknessArgs);
      return;
    }

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _handlePayloadNavigation(data);
    } catch (e) {
      if (kDebugMode) debugPrint('Error parsing notification payload: $e');
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (message.data.isNotEmpty) _handlePayloadNavigation(message.data);
  }

  void _handlePayloadNavigation(Map<String, dynamic> data) {
    final type = data['type'];
    if (type == 'cycle_update') {
      Get.toNamed<void>(AppRoute.cycle);
    } else if (type == 'darkness_config') {
      Get.toNamed<void>(
        AppRoute.cycle,
        arguments: {'action': 'open_darkness_settings'},
      );
    } else if (type == 'cycle_invitation' || type == 'invitation_response') {
      Get.offAllNamed<void>(AppRoute.home);
      if (Get.isRegistered<CycleController>()) {
        Get.find<CycleController>().fetchInvitations();
      }
    } else if (type == 'member_removed') {
      // عند فتح التطبيق من الإشعار: تحديث قائمة الدورات
      if (Get.isRegistered<CycleController>()) {
        Get.find<CycleController>().fetchCyclesFromServer();
      }
      Get.offAllNamed<void>(AppRoute.home);
    }
  }

  Map<String, dynamic>? _parseDarknessAlarmPayload(String payload) {
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>?;
      if (map?['type'] == 'darkness_alarm') return map;
    } catch (_) {}
    return null;
  }

  Future<void> _checkAlarmLaunchFromNotification() async {
    final details = await _localNotifications.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return;
    final payload = details.notificationResponse?.payload;
    if (payload == null) return;

    final darknessArgs = _parseDarknessAlarmPayload(payload);
    if (darknessArgs != null) {
      await GetStorage().write('pending_darkness_alarm', darknessArgs);
    }
  }
}
