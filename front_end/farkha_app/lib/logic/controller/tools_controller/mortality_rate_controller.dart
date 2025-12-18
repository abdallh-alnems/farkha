import 'package:get/get.dart';

import '../../../core/constant/id/tool_ids.dart';
import 'tool_usage_controller.dart';

class MortalityRateController extends GetxController {
  static const int toolId =
      ToolIds.mortalityRate; // Mortality Rate tool ID = 20

  final RxInt initialCount = 0.obs;
  final RxInt deaths = 0.obs;
  final RxDouble mortalityRate = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }

  void calculateMortalityRate() {
    if (initialCount.value > 0) {
      mortalityRate.value = (deaths.value / initialCount.value) * 100;
    } else {
      mortalityRate.value = 0.0;
    }
  }

  void reset() {
    initialCount.value = 0;
    deaths.value = 0;
    mortalityRate.value = 0.0;
  }
}
