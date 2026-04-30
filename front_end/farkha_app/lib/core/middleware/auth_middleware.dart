import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/routes/route.dart';
import '../constant/storage_keys.dart';
import '../services/initialization.dart';

class AuthMiddleware extends GetMiddleware {
  MyServices myServices = Get.find();

  @override
  RouteSettings? redirect(String? route) {
    final isLoggedIn =
        myServices.getStorage.read<bool>(StorageKeys.isLoggedIn) ?? false;

    // إذا لم يكن المستخدم مسجل الدخول، توجيهه إلى صفحة تسجيل الدخول
    if (!isLoggedIn) {
      return const RouteSettings(name: AppRoute.login);
    }

    return null; // السماح بالوصول
  }
}
