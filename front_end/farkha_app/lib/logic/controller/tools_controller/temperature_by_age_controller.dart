import 'package:get/get.dart';

import '../../../core/constant/tool_ids.dart';
import '../../../data/data_source/static/growth_parameters.dart';
import '../tool_usage_controller.dart';

class TemperatureByAgeController extends GetxController {
  static const int toolId =
      ToolIds.temperatureByAge; // Temperature by Age tool ID = 7

  RxInt selectedAge = 1.obs;
  RxInt temperature = 0.obs;

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }

  void calculateTemperature() {
    if (selectedAge.value > 0 && selectedAge.value <= temperatureList.length) {
      temperature.value = temperatureList[selectedAge.value - 1];
    } else {
      temperature.value = 0;
    }
  }
}
