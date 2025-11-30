import 'package:get/get.dart';

import '../../core/class/crud.dart';
import '../controller/price_controller/prices_card/prices_card_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // ================================ curd ===================================
    Get.put(Crud());

    // ================================ price ==================================
    Get.put(PricesCardController());
  }
}
