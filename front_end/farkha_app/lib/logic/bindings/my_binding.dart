import 'package:get/get.dart';

import '../controller/ad_controller/ad_banner_controller.dart';
import '../controller/ad_controller/ad_native_controller.dart';

class MyBindings extends Bindings {
  @override
  void dependencies() {
    // ================================== Ad ===================================

    Get.put(
      AdNativeController(),
    );
    Get.put(
      AdBannerController(),
    );
  }
}
