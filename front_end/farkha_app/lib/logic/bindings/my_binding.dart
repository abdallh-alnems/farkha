import 'package:get/get.dart';
import '../../core/class/crud.dart';
import '../../core/functions/check_internet.dart';
import '../../core/package/rating_app.dart';
import '../../core/package/upgrade/get_min_version.dart';
import '../../core/services/permission.dart';
import '../controller/ad_controller/banner_controller.dart';
import '../controller/ad_controller/native_controller.dart';
import '../controller/price_controller/farkh_abid_controller.dart';

class MyBindings extends Bindings {
  @override
  void dependencies() {
    // ================================ curd ===================================
    Get.put(Crud());

    // ================================== Ad ===================================
    Get.put(AdNativeController());
    Get.put(AdBannerController());

    // ================================ price ==================================
    Get.put(FarkhAbidController());

    // ================================ package ================================
    Get.put(InternetController());
    Get.lazyPut(() => RateMyAppController());
    Get.put(GetMinVersionController());

    // =============================== permission ==============================
    Get.put(PermissionController());
  }
}
