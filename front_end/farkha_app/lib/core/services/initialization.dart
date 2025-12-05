import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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

    // Defer ads SDK initialization to after first frame to avoid blocking startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MobileAds.instance.initialize();
    });

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await initializeDateFormatting('ar');

    // Initialize minimum version checker early to speed update prompt
    Get.put(GetMinVersionController(), permanent: true);

    // Initialize notification service
    await Get.putAsync(() => NotificationService().init());
    // Initialize analytics service
    await Get.putAsync(() => AnalyticsService().init());

    return this;
  }
}

Future<void> initialServices() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => MyServices().init());

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Enable modern edge-to-edge UI for Flutter
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}
