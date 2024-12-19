import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionController extends GetxController {
  Future<bool> checkAndRequestLocationPermission() async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final result = await Permission.location.request();
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      _showSettingsSnackbar();
      return false;
    }
    return false;
  }

  Future<void> initializePermissionsLocation() async {
    final status = await Permission.location.status;

    if (status.isDenied || status.isRestricted) {
      await Permission.location.request();
    }
  }

  void _showSettingsSnackbar() {
    Get.snackbar(
      "الإذن مرفوض دائمًا",
      "يرجى تمكين الإذن من إعدادات الجهاز.",
      snackPosition: SnackPosition.BOTTOM,
      mainButton: TextButton(
        onPressed: openAppSettings,
        child: const Text("فتح الإعدادات"),
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    initializePermissionsLocation();
  }
}
