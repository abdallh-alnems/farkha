import 'package:get/get.dart';

import '../controller/price_controller/prices_card/prices_card_controller.dart';
import '../controller/review_prompt_controller.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(PricesCardController());
    Get.put(ReviewPromptController(), permanent: true);
    Get.find<ReviewPromptController>().registerActivity();
  }
}
