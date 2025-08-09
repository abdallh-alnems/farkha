import 'package:get/get.dart';

class AdgController extends GetxController {
  static const double initialWeight = 45; // جرام

  RxInt days = 0.obs;
  RxDouble currentWeight = 0.0.obs;
  RxDouble adg = 0.0.obs;

  void calculateADG() {
    if (days.value > 0 && currentWeight.value > initialWeight) {
      adg.value = (currentWeight.value - initialWeight) / days.value;
    } else {
      adg.value = 0.0;
    }
  }

  void reset() {
    days.value = 0;
    currentWeight.value = 0.0;
    adg.value = 0.0;
  }
}
