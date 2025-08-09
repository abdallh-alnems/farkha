import 'package:get/get.dart';

class FeedCostPerBirdController extends GetxController {
  RxDouble totalFeedQuantity = 0.0.obs; // إجمالي كمية العلف بالطن
  RxDouble feedPricePerTon = 0.0.obs; // سعر الطن الواحد من العلف
  RxInt numberOfBirds = 0.obs; // عدد الطيور
  RxDouble feedCostPerBird = 0.0.obs; // تكلفة العلف لكل طائر
  RxBool hasCalculated = false.obs; // لتتبع ما إذا تم الحساب أم لا

  void calculateFeedCostPerBird() {
    if (totalFeedQuantity.value > 0 &&
        feedPricePerTon.value > 0 &&
        numberOfBirds.value > 0) {
      // حساب إجمالي تكلفة العلف
      double totalFeedCost = totalFeedQuantity.value * feedPricePerTon.value;

      // حساب تكلفة العلف لكل طائر
      feedCostPerBird.value = totalFeedCost / numberOfBirds.value;
      hasCalculated.value = true;
    } else {
      feedCostPerBird.value = 0;
      hasCalculated.value = false;
    }
  }

  void resetCalculation() {
    hasCalculated.value = false;
  }

  String getFormattedResult() {
    if (!hasCalculated.value) return '';

    return '${feedCostPerBird.value.toStringAsFixed(1)}';
  }

  String getTotalFeedCostFormatted() {
    if (!hasCalculated.value) return '';

    double totalFeedCost = totalFeedQuantity.value * feedPricePerTon.value;
    return '${totalFeedCost.toStringAsFixed(1)}';
  }
}
