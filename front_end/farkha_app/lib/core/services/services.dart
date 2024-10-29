import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:upgrader/upgrader.dart';
import '../constant/firebase_options.dart';

class MyServices extends GetxService {
  Future<MyServices> init() async {
    return this;
  }
}

initialServices() async {
  await Get.putAsync(() => MyServices().init());
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Upgrader.clearSavedSettings();
  await initializeDateFormatting('ar');
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
