import 'package:get/get.dart';

class RoiController extends GetxController {
  RxDouble investmentCost = 0.0.obs;
  RxDouble totalSale = 0.0.obs;
  RxDouble netProfit = 0.0.obs;
  RxDouble roi = 0.0.obs;
  RxBool hasCalculated = false.obs;

  void calculateROI() {
    if (investmentCost.value > 0) {
      // حساب ROI حتى لو كان الربح سالب (خسارة)
      roi.value = (netProfit.value / investmentCost.value) * 100;
      hasCalculated.value = true;
    } else {
      roi.value = 0;
      hasCalculated.value = false;
    }
  }

  void resetCalculation() {
    hasCalculated.value = false;
  }
}
