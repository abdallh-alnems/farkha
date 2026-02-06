import 'package:get/get.dart';

class FeedCostPerKiloController extends GetxController {
  RxDouble totalFeedConsumed = 0.0.obs; // كمية العلف الكلية المستهلكة (طن)
  RxDouble totalWeightSold = 0.0.obs; // الوزن الكلي المباع (طن)
  RxDouble feedPricePerTon = 0.0.obs; // سعر الطن علف (جنيه)
  RxDouble feedCostPerKilo = 0.0.obs; // تكلفة العلف لكل كيلو وزن
  RxBool hasCalculated = false.obs; // لتتبع ما إذا تم الحساب أم لا


  void calculateFeedCostPerKilo() {
    // حساب تكلفة العلف لكل كيلو وزن
    // المعادلة: (كمية العلف الكلية المستهلكة / الوزن الكلي المباع) × سعر الطن علف / 1000
    // النتيجة بالجنيه لكل كيلو جرام
    feedCostPerKilo.value =
        ((totalFeedConsumed.value / totalWeightSold.value) *
            feedPricePerTon.value) /
        1000;
    hasCalculated.value = true;
  }

  void resetCalculation() {
    hasCalculated.value = false;
  }

  String getFormattedResult() {
    if (!hasCalculated.value) return '';

    return feedCostPerKilo.value.toStringAsFixed(1);
  }

  String getTotalFeedCostFormatted() {
    if (!hasCalculated.value) return '';

    final double totalFeedCost = totalFeedConsumed.value * feedPricePerTon.value;
    return totalFeedCost.toStringAsFixed(0);
  }
}
