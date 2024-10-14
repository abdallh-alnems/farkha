import 'package:get/get.dart';

import '../controller/ad_controller/ad_banner_controller.dart';
import '../controller/ad_controller/ad_native_controller.dart';
import '../controller/price_controller/last_price/farkh_abid.dart';

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

    Get.put(
      LastPriceFarkhAbidController(),
    );
  }
}
