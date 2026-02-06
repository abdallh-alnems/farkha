import 'package:get/get.dart';

import '../../../core/functions/number_format.dart';

class FeedCostPerBirdController extends GetxController {
  RxDouble totalFeedQuantity = 0.0.obs; // إجمالي كمية العلف بالطن
  RxDouble feedPricePerTon = 0.0.obs; // سعر الطن الواحد من العلف
  RxInt numberOfBirds = 0.obs; // عدد الطيور
  RxDouble feedCostPerBird = 0.0.obs; // تكلفة العلف لكل طائر
  RxBool hasCalculated = false.obs; // لتتبع ما إذا تم الحساب أم لا


  void calculateFeedCostPerBird() {
    // حساب إجمالي تكلفة العلف
    final double totalFeedCost = totalFeedQuantity.value * feedPricePerTon.value;

    // حساب تكلفة العلف لكل طائر
    feedCostPerBird.value = totalFeedCost / numberOfBirds.value;
    hasCalculated.value = true;
  }

  void resetCalculation() {
    hasCalculated.value = false;
  }

  String getFormattedResult() {
    if (!hasCalculated.value) return '';

    return formatDecimal(feedCostPerBird.value);
  }

  String getTotalFeedCostFormatted() {
    if (!hasCalculated.value) return '';

    final double totalFeedCost = totalFeedQuantity.value * feedPricePerTon.value;
    return formatDecimal(totalFeedCost);
  }
}
