import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';

class AnalyticsService extends GetxService {
  late final FirebaseAnalytics analytics;

  Future<AnalyticsService> init() async {
    analytics = FirebaseAnalytics.instance;
    await analytics.setAnalyticsCollectionEnabled(true);
    return this;
  }

  Future<void> logAppOpen() async {
    await analytics.logAppOpen();
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
