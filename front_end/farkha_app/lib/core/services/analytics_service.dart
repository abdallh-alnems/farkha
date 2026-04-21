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

  Future<void> logToolPageView({required String toolName}) async {
    await logEvent(name: 'tool_page_view', parameters: {'tool_name': toolName});
  }

  Future<void> logPhoneOtpSent() async {
    await logEvent(name: 'phone_otp_sent', parameters: {'phone_country': 'EG'});
  }

  Future<void> logPhoneOtpVerified({required int attemptsUsed}) async {
    await logEvent(name: 'phone_otp_verified', parameters: {'attempts_used': attemptsUsed});
  }

  Future<void> logPhoneOtpFailed({required String reason}) async {
    await logEvent(name: 'phone_otp_failed', parameters: {'reason': reason});
  }

  Future<void> logPhoneOtpResent({required int resendNumber}) async {
    await logEvent(name: 'phone_otp_resent', parameters: {'resend_number': resendNumber});
  }

  Future<void> logPhoneChanged({required bool changedFromVerified}) async {
    await logEvent(name: 'phone_changed', parameters: {'changed_from_verified': changedFromVerified});
  }
}
