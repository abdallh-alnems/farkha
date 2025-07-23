import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarUtils {
  static bool _isSnackbarVisible = false;
  static const String _defaultMessage = 'قريبا';

  static void showSnackbar([String? message]) {
    // Check if a snackbar is already visible
    if (_isSnackbarVisible) return;

    _isSnackbarVisible = true;

    // Show the snackbar
    Get.snackbar(
      '',
      '',
      titleText: const Text(
        '',
        style: TextStyle(fontSize: 0),
        textAlign: TextAlign.center,
      ),
      messageText: Text(
        message ?? _defaultMessage, // Use default if message is null
        style: const TextStyle(fontSize: 23),
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 3),
      isDismissible: true,
    );

    // Reset visibility after the duration
    Future.delayed(const Duration(seconds: 3), () {
      _isSnackbarVisible = false;
    });
  }
}
