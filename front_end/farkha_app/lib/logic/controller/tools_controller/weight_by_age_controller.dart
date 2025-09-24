import 'package:get/get.dart';

import '../../../core/constant/tool_ids.dart';
import '../../../data/data_source/static/growth_parameters.dart';
import '../tool_usage_controller.dart';

class WeightByAgeController extends GetxController {
  static const int toolId = ToolIds.weightByAge; // Weight by Age tool ID = 6

  RxInt selectedAge = 1.obs;
  RxInt weight = 0.obs;

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }

  void calculateWeight() {
    if (selectedAge.value > 0 && selectedAge.value <= weightsList.length) {
      weight.value = weightsList[selectedAge.value - 1];
    } else {
      weight.value = 0;
    }
  }
}
