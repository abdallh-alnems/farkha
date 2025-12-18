import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AnalyticsService extends GetxService {
  late final FirebaseAnalytics analytics;

  Future<AnalyticsService> init() async {
    analytics = FirebaseAnalytics.instance;

    // Enable analytics collection
    await analytics.setAnalyticsCollectionEnabled(true);

    // Log app open once during initialization
    await analytics.logAppOpen();

    // Set user properties for better tracking
    final packageInfo = await PackageInfo.fromPlatform();
    await analytics.setUserProperty(
      name: 'app_version',
      value: packageInfo.version,
    );

    debugPrint('✅ Firebase Analytics initialized');
    return this;
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await analytics.logEvent(name: name, parameters: parameters);
    debugPrint('📊 Analytics Event: $name');
  }

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }
}
