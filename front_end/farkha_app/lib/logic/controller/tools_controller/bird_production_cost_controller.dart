import 'package:get/get.dart';

import '../../../core/constant/id/tool_ids.dart';
import 'tool_usage_controller.dart';

class BirdProductionCostController extends GetxController {
  static const int toolId =
      ToolIds.birdProductionCost; // Bird Production Cost tool ID = 15

  final RxDouble totalCosts = 0.0.obs;
  final RxInt liveBirds = 0.obs;
  final RxDouble costPerBird = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }

  void calculateCostPerBird() {
    if (liveBirds.value > 0) {
      costPerBird.value = totalCosts.value / liveBirds.value;
    } else {
      costPerBird.value = 0.0;
    }
  }

  void reset() {
    totalCosts.value = 0.0;
    liveBirds.value = 0;
    costPerBird.value = 0.0;
  }
}
