import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/initialization.dart';

class MyMiddleWare extends GetMiddleware {
  MyServices myServices = Get.find();

  @override
  RouteSettings? redirect(String? route) {
    // إذا كان المستخدم لم يكمل الـ onboarding بعد
    if (myServices.getStorage.read("step") != "1") {
      return const RouteSettings(name: "/onboarding");
    }

    // إذا كان المستخدم يحاول الوصول إلى الـ onboarding بعد إكماله
    if (route == "/onboarding" && myServices.getStorage.read("step") == "1") {
      return const RouteSettings(name: "/");
    }

    return null;
  }
}
