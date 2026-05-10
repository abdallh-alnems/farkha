import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/api/admin_api.dart';
import '../../core/routes/app_routes.dart';

class LoginController extends GetxController {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final errorMsg = ''.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    final username = usernameCtrl.text.trim();
    final password = passwordCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      errorMsg.value = 'أدخل اسم المستخدم وكلمة المرور';
      return;
    }

    isLoading.value = true;
    errorMsg.value = '';

    try {
      await AdminApi.login(username, password);
      Get.offAllNamed(AppRoutes.dashboard);
    } on AdminApiException catch (e) {
      errorMsg.value = e.message;
    } catch (e) {
      errorMsg.value = 'حدث خطأ غير متوقع';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
