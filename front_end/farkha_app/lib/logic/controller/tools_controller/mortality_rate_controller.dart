import 'package:get/get.dart';

class MortalityRateController extends GetxController {
  final RxInt initialCount = 0.obs;
  final RxInt deaths = 0.obs;
  final RxDouble mortalityRate = 0.0.obs;


  void calculateMortalityRate() {
    if (initialCount.value > 0) {
      mortalityRate.value = (deaths.value / initialCount.value) * 100;
    } else {
      mortalityRate.value = 0.0;
    }
  }

  void reset() {
    initialCount.value = 0;
    deaths.value = 0;
    mortalityRate.value = 0.0;
  }
}
