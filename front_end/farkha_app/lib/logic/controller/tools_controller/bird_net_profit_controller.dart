import 'package:get/get.dart';

import '../../../core/constant/id/tool_ids.dart';
import 'tool_usage_controller.dart';

class BirdNetProfitController extends GetxController {
  static const int toolId =
      ToolIds.birdNetProfit; // Bird Net Profit tool ID = 18

  RxDouble totalSale = 0.0.obs;
  RxDouble totalCost = 0.0.obs;
  RxInt soldBirds = 0.obs;
  RxDouble netProfit = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }

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
