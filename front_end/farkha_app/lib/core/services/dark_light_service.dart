import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DarkLightService extends GetxService {
  DarkLightService() : storage = Get.find<GetStorage>();

  final GetStorage storage;
  static const String _storageKey = 'theme_mode';
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    themeMode.value = _readSavedMode();
    Get.changeThemeMode(themeMode.value);
  }

  void toggleTheme() {
    final ThemeMode currentMode = themeMode.value;
    ThemeMode newMode;

    if (currentMode == ThemeMode.light) {
      newMode = ThemeMode.dark;
    } else if (currentMode == ThemeMode.dark) {
      newMode = ThemeMode.light;
    } else {
      // إذا كان system، نتحقق من الوضع الفعلي للهاتف
      final Brightness systemBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      newMode =
          systemBrightness == Brightness.dark
              ? ThemeMode.light
              : ThemeMode.dark;
    }

    _applyTheme(newMode);
  }

  ThemeMode _readSavedMode() {
    final String? savedMode = storage.read<String>(_storageKey);
    if (savedMode == ThemeMode.dark.name) {
      return ThemeMode.dark;
    }
    if (savedMode == ThemeMode.light.name) {
      return ThemeMode.light;
    }
    // إذا لم يكن هناك قيمة محفوظة، نستخدم وضع النظام
    return ThemeMode.system;
  }

  void _applyTheme(ThemeMode mode) {
    themeMode.value = mode;
    storage.write(_storageKey, mode.name);
    Get.changeThemeMode(mode);
  }
}
