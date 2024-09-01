import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MyServices extends GetxService {

  Future<MyServices> init() async {
    return this;
  }
}

initialServices() async {
  await Get.putAsync(() => MyServices().init());

//  WidgetsFlutterBinding.ensureInitialized();
}
