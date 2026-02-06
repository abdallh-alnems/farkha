import 'package:get/get.dart';

import '../../core/package/rating_app.dart';
import '../../core/services/permission.dart';
import '../controller/internet_controller.dart';
import '../controller/price_controller/prices_card/prices_card_controller.dart';
import '../controller/tools_controller/favorite_tools_controller.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    // =============================== permission ==============================
    Get.put(PermissionController(), permanent: true);

    // ================================ Internet Controller ====================
    Get.put(InternetController(), permanent: true);

    // =============================== Rating Controller =======================
    Get.put(RateMyAppController(), permanent: true);

    // ================================ price (Home) ===========================
    Get.put(PricesCardController());

    // ================================ tools (Home) ============================
    Get.put(FavoriteToolsController(), permanent: true);
  }
}
