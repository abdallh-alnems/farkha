import 'package:get/get.dart';

import '../../core/class/crud.dart';
import '../../core/package/upgrade/check_min_version.dart';
import '../../core/package/rating_app.dart';
import '../controller/ad_controller/ad_banner_controller.dart';
import '../controller/ad_controller/ad_native_controller.dart';
import '../controller/price_controller/last_price/farkh_abid_controller.dart';

class MyBindings extends Bindings {
  @override
  void dependencies() {
    
    // ================================== Ad ===================================
    Get.put(AdNativeController());
    Get.put(AdBannerController());

    // ================================ price ==================================
    Get.put(LastPriceFarkhAbidController());

    // ================================ curd ==================================
    Get.put(Crud());

    Get.lazyPut(
      () => RateMyAppController(),
    );
     Get.lazyPut(
      () => MinVersionController(),
    );
  
  }
}
