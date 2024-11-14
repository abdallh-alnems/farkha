import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constant/firebase_options.dart';

class MyServices extends GetxService {
  late GetStorage getStorage;

  Future<MyServices> init() async {
    await dotenv.load(fileName: ".env");

    await GetStorage.init();
    getStorage = GetStorage();

    MobileAds.instance.initialize();

    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    await initializeDateFormatting('ar');

    return this;
  }
}

Future<void> initialServices() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => MyServices().init());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
}
