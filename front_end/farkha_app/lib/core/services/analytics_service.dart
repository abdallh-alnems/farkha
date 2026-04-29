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

  static const String appReviewScreenOpened = 'app_review_screen_opened';
  static const String appReviewSubmitted = 'app_review_submitted';
  static const String reviewPromptShown = 'review_prompt_shown';
  static const String reviewPromptAccepted = 'review_prompt_accepted';
  static const String reviewPromptDismissed = 'review_prompt_dismissed';
}
