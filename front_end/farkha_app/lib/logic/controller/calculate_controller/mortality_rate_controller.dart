import 'package:get/get.dart';

class MortalityRateController extends GetxController {
  RxInt initialCount = 0.obs;
  RxInt deaths = 0.obs;
  RxDouble mortalityRate = 0.0.obs;

  void calculateMortalityRate() {
    if (initialCount.value > 0 && deaths.value >= 0) {
      mortalityRate.value = (deaths.value / initialCount.value) * 100;
    } else {
      mortalityRate.value = 0;
    }
  }
}
