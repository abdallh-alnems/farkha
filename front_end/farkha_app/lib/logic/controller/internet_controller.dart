import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/package/internet_checker.dart';
import '../../core/services/internet_data_loader_service.dart';

class InternetController extends GetxController with WidgetsBindingObserver {
  bool? _wasConnected;
  Timer? _timer;

  static const Duration _checkInterval = Duration(seconds: 3);
  static const Duration _initialDelay = Duration(milliseconds: 1000);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _startInitialCheck();
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
      _startPeriodicCheck();
    } else if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    }
  }

  void _startInitialCheck() {
    Future.delayed(_initialDelay, () {
      checkInternetAndNotify();
      _startPeriodicCheck();
    });
  }

  void _startPeriodicCheck() {
    _timer?.cancel();
    _timer = Timer.periodic(_checkInterval, (_) => checkInternetAndNotify());
  }

  Future<void> checkInternetAndNotify() async {
    final bool isConnected = await InternetChecker.checkConnection();

    if (isConnected) {
      await _handleConnected();
    } else {
      _handleDisconnected();
    }
  }

  Future<void> _handleConnected() async {
    if (_wasConnected == false) {
      InternetChecker.showConnected();
      await InternetDataLoaderService.reloadCurrentPageData();
    }
    _wasConnected = true;
  }

  void _handleDisconnected() {
    if (_wasConnected == true) {
      InternetChecker.showDisconnected();
    }
    _wasConnected = false;
  }
}
