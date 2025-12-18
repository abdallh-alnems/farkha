import 'package:get/get.dart';

import '../../../core/constant/id/tool_ids.dart';
import 'tool_usage_controller.dart';

class FeedCostPerBirdController extends GetxController {
  static const int toolId =
      ToolIds.feedCostPerBird; // Feed Cost per Bird tool ID = 16

  RxDouble totalFeedQuantity = 0.0.obs; // إجمالي كمية العلف بالطن
  RxDouble feedPricePerTon = 0.0.obs; // سعر الطن الواحد من العلف
  RxInt numberOfBirds = 0.obs; // عدد الطيور
  RxDouble feedCostPerBird = 0.0.obs; // تكلفة العلف لكل طائر
  RxBool hasCalculated = false.obs; // لتتبع ما إذا تم الحساب أم لا

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }

  void calculateFeedCostPerBird() {
    // حساب إجمالي تكلفة العلف
    double totalFeedCost = totalFeedQuantity.value * feedPricePerTon.value;

    // حساب تكلفة العلف لكل طائر
    feedCostPerBird.value = totalFeedCost / numberOfBirds.value;
    hasCalculated.value = true;
  }

  void resetCalculation() {
    hasCalculated.value = false;
  }

  String getFormattedResult() {
    if (!hasCalculated.value) return '';

    return feedCostPerBird.value.toStringAsFixed(1);
  }

  String getTotalFeedCostFormatted() {
    if (!hasCalculated.value) return '';

    double totalFeedCost = totalFeedQuantity.value * feedPricePerTon.value;
    return totalFeedCost.toStringAsFixed(1);
  }
}
