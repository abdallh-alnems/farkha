import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/shared/snackbar_message.dart';

class PermissionController extends GetxController {
  Future<void>? _ongoingRequest;

  Future<bool> checkAndRequestLocationPermission() async {
    // Prevent overlapping permission requests
    if (_ongoingRequest != null) {
      await _ongoingRequest;
      return (await Permission.location.status).isGranted;
    }

    final completer = Completer<void>();
    _ongoingRequest = completer.future;
    try {
      final status = await Permission.location.status;

      if (status.isGranted) {
        return true;
      } else if (status.isDenied) {
        final result = await Permission.location.request();
        return result.isGranted;
      } else if (status.isPermanentlyDenied) {
        _showSettingsSnackbar(
          "الإذن مرفوض دائمًا",
          "يرجى تمكين إذن الموقع من إعدادات الجهاز.",
        );
        return false;
      }
      return false;
    } finally {
      completer.complete();
      _ongoingRequest = null;
    }
  }

  Future<bool> checkAndRequestNotificationPermission() async {
    // Prevent overlapping permission requests
    if (_ongoingRequest != null) {
      await _ongoingRequest;
      return (await Permission.notification.status).isGranted;
    }

    final completer = Completer<void>();
    _ongoingRequest = completer.future;
    try {
      final status = await Permission.notification.status;

      if (status.isGranted) {
        return true;
      } else if (status.isDenied) {
        final result = await Permission.notification.request();
        return result.isGranted;
      } else if (status.isPermanentlyDenied) {
        _showSettingsSnackbar(
          "إذن الإشعارات مرفوض دائمًا",
          "يرجى تمكين إذن الإشعارات من إعدادات الجهاز.",
        );
        return false;
      }
      return false;
    } finally {
      completer.complete();
      _ongoingRequest = null;
    }
  }

  Future<void> initializePermissionsLocation() async {
    await checkAndRequestLocationPermission();
  }

  Future<void> initializePermissionsNotification() async {
    await checkAndRequestNotificationPermission();
  }

  void _showSettingsSnackbar(String title, String message) {
    final context = Get.context;
    if (context != null) {
      SnackbarMessage.show(context, '$title: $message', icon: Icons.info);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeAllPermissions();
  }

  Future<void> _initializeAllPermissions() async {
    await initializePermissionsLocation();
    await initializePermissionsNotification();
  }
}
