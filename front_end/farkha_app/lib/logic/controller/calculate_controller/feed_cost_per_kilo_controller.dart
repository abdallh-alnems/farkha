import 'package:get/get.dart';

class FeedCostPerKiloController extends GetxController {
  RxDouble totalFeedConsumed = 0.0.obs; // كمية العلف الكلية المستهلكة (طن)
  RxDouble totalWeightSold = 0.0.obs; // الوزن الكلي المباع (طن)
  RxDouble feedPricePerTon = 0.0.obs; // سعر الطن علف (جنيه)
  RxDouble feedCostPerTon = 0.0.obs; // تكلفة العلف لكل طن وزن
  RxBool hasCalculated = false.obs; // لتتبع ما إذا تم الحساب أم لا

  void calculateFeedCostPerKilo() {
    if (totalFeedConsumed.value > 0 &&
        totalWeightSold.value > 0 &&
        feedPricePerTon.value > 0) {
      // حساب تكلفة العلف لكل طن وزن
      // المعادلة: (كمية العلف الكلية المستهلكة / الوزن الكلي المباع) × سعر الطن علف
      feedCostPerTon.value =
          (totalFeedConsumed.value / totalWeightSold.value) *
          feedPricePerTon.value;
      hasCalculated.value = true;
    } else {
      feedCostPerTon.value = 0;
      hasCalculated.value = false;
    }
  }

  void resetCalculation() {
    hasCalculated.value = false;
  }

  String getFormattedResult() {
    if (!hasCalculated.value) return '';

    return '${feedCostPerTon.value.toStringAsFixed(1)}';
  }

  String getTotalFeedCostFormatted() {
    if (!hasCalculated.value) return '';

    double totalFeedCost = totalFeedConsumed.value * feedPricePerTon.value;
    return '${totalFeedCost.toStringAsFixed(1)}';
  }
}
