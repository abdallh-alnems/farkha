import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/shared/permissions_intro_dialog.dart';
import '../../core/shared/snackbar_message.dart';

class PermissionController extends GetxController {
  Future<void>? _ongoingRequest;

  final GetStorage _storage = GetStorage();

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
          'الإذن مرفوض دائمًا',
          'يرجى تمكين إذن الموقع من إعدادات الجهاز.',
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
          'إذن الإشعارات مرفوض دائمًا',
          'يرجى تمكين إذن الإشعارات من إعدادات الجهاز.',
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
    // Delay showing snackbar until the UI is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = Get.context;
      if (context != null && context.mounted) {
        SnackbarMessage.show(context, '$title: $message', icon: Icons.info);
      }
    });
  }

  /// Shows the intro dialogs in sequence: location, then notifications, then
  /// theme. Each step has its own message and "تفعيل" / "لاحقاً". Call from
  /// Home (or first screen) after UI is ready.
  Future<void> showPermissionsIntroIfNeeded(BuildContext? context) async {
    final ctx = context ?? Get.context;
    if (ctx == null || !ctx.mounted) return;

    final showLocation = await _shouldShowStep(
      PermissionsIntroDialog.locationIntroShownKey,
      Permission.location.status,
    );
    final showNotification = await _shouldShowStep(
      PermissionsIntroDialog.notificationIntroShownKey,
      Permission.notification.status,
    );
    final showTheme = kDebugMode ||
        _storage.read<bool>(PermissionsIntroDialog.themeIntroShownKey) != true;

    if (!showLocation && !showNotification && !showTheme) {
      return;
    }

    if (showLocation) {
      await Get.dialog<void>(
        LocationIntroDialog(
          onEnable: () {
            _storage.write(PermissionsIntroDialog.locationIntroShownKey, true);
            checkAndRequestLocationPermission();
          },
          onLater: () {
            _storage.write(PermissionsIntroDialog.locationIntroShownKey, true);
          },
        ),
        barrierDismissible: false,
      );
    }

    if (!ctx.mounted) return;
    if (showNotification) {
      await Get.dialog<void>(
        NotificationIntroDialog(
          onEnable: () {
            _storage.write(
              PermissionsIntroDialog.notificationIntroShownKey,
              true,
            );
            checkAndRequestNotificationPermission();
          },
          onLater: () {
            _storage.write(
              PermissionsIntroDialog.notificationIntroShownKey,
              true,
            );
          },
        ),
        barrierDismissible: false,
      );
    }

    if (!ctx.mounted) return;
    if (showTheme) {
      await Get.dialog<void>(
        ThemeIntroDialog(
          onDone: () {
            _storage.write(PermissionsIntroDialog.themeIntroShownKey, true);
          },
        ),
        barrierDismissible: false,
      );
    }
  }

  Future<bool> _shouldShowStep(String storageKey, Future<PermissionStatus> statusFuture) async {
    if (kDebugMode) return true;
    if (_storage.read<bool>(storageKey) == true) return false;
    final status = await statusFuture;
    return !status.isGranted;
  }

}
