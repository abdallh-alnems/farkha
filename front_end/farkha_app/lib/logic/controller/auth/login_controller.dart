import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;

  Future<void> onGoogleSignIn() async {
    isLoading.value = true;

    // Simulate Google sign-in delay for testing
    await Future.delayed(const Duration(seconds: 2));

    isLoading.value = false;

    // TODO: Implement actual Google sign-in logic
    Get.snackbar(
      'نجاح',
      'تم تسجيل الدخول بنجاح (تجريبي)',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }
}
