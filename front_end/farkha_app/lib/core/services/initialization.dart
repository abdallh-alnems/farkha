import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../logic/controller/get_min_version.dart';
import '../constant/firebase_options.dart';
import 'analytics_service.dart';
import 'dark_light_service.dart';
import 'notification_service.dart';

class MyServices extends GetxService {
  late GetStorage getStorage;

  Future<MyServices> init() async {
    await dotenv.load(fileName: ".env");

    await GetStorage.init();
    getStorage = GetStorage();
    Get.put<GetStorage>(getStorage, permanent: true);
    Get.put(DarkLightService(), permanent: true);

    // Initialize Firebase - handle if already initialized by native plugin
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // Firebase already initialized by google-services plugin, ignore
      debugPrint('Firebase already initialized: $e');
    }

    // Initialize Crashlytics
    await _initCrashlytics();

    await initializeDateFormatting('ar');

    // Initialize minimum version checker early to speed update prompt
    Get.put(GetMinVersionController(), permanent: true);

    // Initialize notification service
    await Get.putAsync(() => NotificationService().init());
    // Initialize analytics service
    await Get.putAsync(() => AnalyticsService().init());

    return this;
  }

  /// Initialize Firebase Crashlytics for crash reporting
  Future<void> _initCrashlytics() async {
    // Disable in debug mode to avoid noise during development
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );

    // Capture Flutter framework errors
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Capture async errors not caught by Flutter
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    debugPrint('✅ Firebase Crashlytics initialized');
  }
}

Future<void> initialServices() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => MyServices().init());

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Edge-to-edge is handled by native Android styles (values-v35/styles.xml)
}
