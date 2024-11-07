import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../logic/controller/ad_controller/ad_banner_controller.dart';
import '../../logic/controller/ad_controller/ad_native_controller.dart';
import '../../logic/controller/price_controller/farkh_abid_controller.dart';
import '../package/custom_snack_bar.dart';

class InternetController extends GetxController {
  bool _wasConnected = true;

  @override
  void onInit() {
    super.onInit();
    startCheckingInternet();
  }

  void startCheckingInternet() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      checkInternet(Get.context!);
    });
  }

  Future<void> checkInternet(BuildContext context) async {
    try {
      var result = await InternetAddress.lookup("google.com");
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (!_wasConnected) {
          CustomSnackbar(
            message: "تم استعادة الاتصال",
            icon: Icons.wifi,
          ).show(context);
          loadData();
        }
        _wasConnected = true;
      }
    } on SocketException catch (_) {
      if (_wasConnected) {
        CustomSnackbar(
          message: "لا يوجد اتصال",
          icon: Icons.wifi_off,
        ).show(context);
      }
      _wasConnected = false;
    }
  }
  
  void loadData() {
    Get.find<FarkhAbidController>().getDataFarkhAbid();
    Get.find<AdBannerController>().bannerFirstAd();
    Get.find<AdNativeController>().nativeFirstAd();
  }
}
