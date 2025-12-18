import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/theme/colors.dart';

class InternetChecker {
  static Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup("google.com");
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> checkConnectionAndShowStatus() async {
    final isConnected = await checkConnection();
    if (isConnected) {
      _showConnectedMessage();
    } else {
      _showDisconnectedMessage();
    }
    return isConnected;
  }

  static void showConnected() {
    _showConnectedMessage();
  }

  static void showDisconnected() {
    _showDisconnectedMessage();
  }

  static void _showConnectedMessage() {
    _showMessage("تم استعادة الاتصال", Icons.wifi);
  }

  static void _showDisconnectedMessage() {
    _showMessage("لا يوجد اتصال", Icons.wifi_off);
  }

  static void _showMessage(String message, IconData icon) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 21),
            const SizedBox(width: 15),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryColor,
        margin: const EdgeInsets.symmetric(vertical: 111, horizontal: 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
    );
  }
}