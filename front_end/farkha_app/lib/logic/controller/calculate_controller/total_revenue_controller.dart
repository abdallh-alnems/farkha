import 'package:get/get.dart';

class TotalRevenueController extends GetxController {
  RxDouble birdsCount = 0.0.obs;
  RxDouble averageWeight = 0.0.obs;
  RxDouble pricePerKg = 0.0.obs;
  RxDouble totalRevenue = 0.0.obs;

  void calculateTotalRevenue() {
    if (birdsCount.value > 0 &&
        averageWeight.value > 0 &&
        pricePerKg.value > 0) {
      totalRevenue.value =
          birdsCount.value * averageWeight.value * pricePerKg.value;
    } else {
      totalRevenue.value = 0.0;
    }
  }

  void updateBirdsCount(String value) {
    birdsCount.value = double.tryParse(value) ?? 0.0;
  }

  void updateAverageWeight(String value) {
    averageWeight.value = double.tryParse(value) ?? 0.0;
  }

  void updatePricePerKg(String value) {
    pricePerKg.value = double.tryParse(value) ?? 0.0;
  }

  void calculate() {
    calculateTotalRevenue();
  }
}
