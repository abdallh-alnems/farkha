import 'package:get/get.dart';

import '../../../core/constant/id/tool_ids.dart';
import '../../../data/data_source/static/chicken_data.dart';
import 'tool_usage_controller.dart';

class TemperatureByAgeController extends GetxController {
  static const int toolId =
      ToolIds.temperatureByAge; // Temperature by Age tool ID = 7

  Rx<int?> selectedAge = Rx<int?>(null);
  RxInt temperature = 0.obs;

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }

  void calculateTemperature() {
    if (selectedAge.value != null &&
        selectedAge.value! > 0 &&
        selectedAge.value! <= temperatureList.length) {
      temperature.value = temperatureList[selectedAge.value! - 1];
    } else {
      temperature.value = 0;
    }
  }
}
