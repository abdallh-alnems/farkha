import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

class MyServices extends GetxService {
  Future<MyServices> init() async {
    return this;
  }
}

initialServices() async {
  await Get.putAsync(() => MyServices().init());


  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ar');
}
