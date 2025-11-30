import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constant/id/tool_ids.dart';
import 'tool_usage_controller.dart';

class TotalRevenueController extends GetxController {
  static const int toolId = ToolIds.totalRevenue; // Total Revenue tool ID = 22

  RxDouble birdsCount = 0.0.obs;
  RxDouble averageWeight = 0.0.obs;
  RxDouble pricePerKg = 0.0.obs;
  RxDouble totalRevenue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }

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

  String getFormattedRevenue() {
    if (totalRevenue.value <= 0) return '';
    final formatter = NumberFormat('#,##0');
    return formatter.format(totalRevenue.value.toInt());
  }
}
