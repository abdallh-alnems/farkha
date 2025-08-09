import 'package:get/get.dart';

class BirdNetProfitController extends GetxController {
  RxDouble totalSale = 0.0.obs;
  RxDouble totalCost = 0.0.obs;
  RxInt soldBirds = 0.obs;
  RxDouble netProfit = 0.0.obs;

  void calculateNetProfit() {
    if (soldBirds.value > 0) {
      final totalProfit = totalSale.value - totalCost.value;
      netProfit.value = totalProfit / soldBirds.value;
    } else {
      netProfit.value = 0.0;
    }
  }

  void calculate() {
    calculateNetProfit();
  }
}
