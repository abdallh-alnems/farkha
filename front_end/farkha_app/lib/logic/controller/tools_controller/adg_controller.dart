import 'package:get/get.dart';

import '../../../core/constant/id/tool_ids.dart';
import 'tool_usage_controller.dart';

class AdgController extends GetxController {
  static const double initialWeight = 45; // جرام
  static const int toolId = ToolIds.adg; // ADG tool ID = 2

  RxInt days = 0.obs;
  RxDouble currentWeight = 0.0.obs;
  RxDouble adg = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }

  void calculateADG() {
    if (days.value > 0 && currentWeight.value > initialWeight) {
      adg.value = (currentWeight.value - initialWeight) / days.value;
    } else {
      adg.value = 0.0;
    }
  }

  void reset() {
    days.value = 0;
    currentWeight.value = 0.0;
    adg.value = 0.0;
  }
}
