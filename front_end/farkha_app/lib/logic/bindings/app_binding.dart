import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/class/crud.dart';
import '../controller/auth/login_controller.dart';
import '../controller/price_controller/prices_card/prices_card_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // ================================ curd ===================================
    Get.put(Crud());

    // ================================ auth ===================================
    Get.put(LoginController(), permanent: true);

    // ================================ price ==================================
    Get.put(PricesCardController());

    // ================================ ads ====================================
    MobileAds.instance.initialize();
  }
}
