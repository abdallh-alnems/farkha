import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/api/admin_api.dart';

class AdminsController extends GetxController {
  final admins = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMsg = ''.obs;
  final isSuperAdmin = false.obs;

  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final displayNameCtrl = TextEditingController();
  final selectedRole = 'readonly'.obs;

  @override
  void onInit() {
    super.onInit();
    _checkRole();
    fetchAdmins();
  }

  Future<void> _checkRole() async {
    final info = await AdminApi.getAdminInfo();
    isSuperAdmin.value = info?['role'] == 'superadmin';
  }

  Future<void> fetchAdmins() async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      final res = await AdminApi.post('/admin/admins/list.php');
      admins.value = (res['data'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } on AdminApiException catch (e) {
      errorMsg.value = e.message;
    } catch (e) {
      errorMsg.value = 'فشل تحميل البيانات';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAdmin() async {
    final username = usernameCtrl.text.trim();
    final password = passwordCtrl.text;
    final displayName = displayNameCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar('خطأ', 'اسم المستخدم وكلمة المرور مطلوبان',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (password.length < 6) {
      Get.snackbar('خطأ', 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      await AdminApi.post('/admin/admins/create.php', {
        'username': username,
        'password': password,
        'display_name': displayName,
        'role': selectedRole.value,
      });
      Get.back();
      Get.snackbar('تم', 'تم إنشاء الحساب بنجاح',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      _clearForm();
      fetchAdmins();
    } on AdminApiException catch (e) {
      Get.snackbar('خطأ', e.message,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> toggleActive(Map<String, dynamic> admin, bool value) async {
    try {
      await AdminApi.post('/admin/admins/update.php', {
        'id': admin['id'],
        'is_active': value ? 1 : 0,
      });
      fetchAdmins();
    } on AdminApiException catch (e) {
      Get.snackbar('خطأ', e.message,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> changeRole(Map<String, dynamic> admin, String newRole) async {
    try {
      await AdminApi.post('/admin/admins/update.php', {
        'id': admin['id'],
        'role': newRole,
      });
      Get.back();
      fetchAdmins();
      Get.snackbar('تم', 'تم تحديث الصلاحية',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } on AdminApiException catch (e) {
      Get.snackbar('خطأ', e.message,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> resetPassword(Map<String, dynamic> admin, String newPassword) async {
    if (newPassword.length < 6) {
      Get.snackbar('خطأ', 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    try {
      await AdminApi.post('/admin/admins/update.php', {
        'id': admin['id'],
        'password': newPassword,
      });
      Get.back();
      Get.snackbar('تم', 'تم إعادة تعيين كلمة المرور',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } on AdminApiException catch (e) {
      Get.snackbar('خطأ', e.message,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _clearForm() {
    usernameCtrl.clear();
    passwordCtrl.clear();
    displayNameCtrl.clear();
    selectedRole.value = 'readonly';
  }

  @override
  void onClose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    displayNameCtrl.dispose();
    super.onClose();
  }
}
