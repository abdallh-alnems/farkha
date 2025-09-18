import 'package:get/get.dart';

class BirdProductionCostController extends GetxController {
  final RxDouble totalCosts = 0.0.obs;
  final RxInt liveBirds = 0.obs;
  final RxDouble costPerBird = 0.0.obs;

  void calculateCostPerBird() {
    if (liveBirds.value > 0) {
      costPerBird.value = totalCosts.value / liveBirds.value;
    } else {
      costPerBird.value = 0.0;
    }
  }

  void reset() {
    totalCosts.value = 0.0;
    liveBirds.value = 0;
    costPerBird.value = 0.0;
  }
}
