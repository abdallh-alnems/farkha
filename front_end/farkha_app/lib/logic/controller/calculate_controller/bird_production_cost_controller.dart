import 'package:get/get.dart';

class BirdProductionCostController extends GetxController {
  RxDouble totalCosts = 0.0.obs;
  RxInt liveBirds = 0.obs;
  RxDouble costPerBird = 0.0.obs;

  void calculateCostPerBird() {
    if (liveBirds.value > 0) {
      costPerBird.value = totalCosts.value / liveBirds.value;
    } else {
      costPerBird.value = 0;
    }
  }
}
