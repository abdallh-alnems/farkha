import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../logic/controller/price_controller/prices_stream/prices_stream_controller.dart';
import '../package/snackbar_message.dart';

class InternetController extends GetxController with WidgetsBindingObserver {
  bool _wasConnected = true;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    startCheckingInternet();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      startCheckingInternet();
    } else if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    }
  }

  void startCheckingInternet() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      checkInternetAndNotify();
    });
  }

  static Future<bool> checkInternet() async {
    try {
      var result = await InternetAddress.lookup("google.com");
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _showSnackbar(String message, IconData icon) {
    if (Get.context != null) {
      // استخدام AppColor.primaryColor مع الأيقونات المخصصة
      SnackbarMessage.show(Get.context!, message, icon: icon);
    }
  }

  void loadData() {
    Get.find<PricesStreamController>().getDataPricesStream();
  }

  Future<void> checkInternetAndNotify() async {
    bool isConnected = await checkInternet();
    if (isConnected) {
      if (!_wasConnected) {
        _showSnackbar("تم استعادة الاتصال", Icons.wifi);
        loadData();
      }
      _wasConnected = true;
    } else {
      if (_wasConnected) {
        _showSnackbar("لا يوجد اتصال", Icons.wifi_off);
      }
      _wasConnected = false;
    }
  }
}
