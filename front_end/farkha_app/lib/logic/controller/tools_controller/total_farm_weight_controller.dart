import 'package:get/get.dart';

import '../../../core/constant/id/tool_ids.dart';
import 'tool_usage_controller.dart';

class TotalFarmWeightController extends GetxController {
  static const int toolId =
      ToolIds.totalFarmWeight; // Total Farm Weight tool ID = 21

  final RxString birdsCount = ''.obs;
  final RxString birdWeight = ''.obs;
  final RxDouble totalWeight = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }

  void calculate() {
    final int? birds = int.tryParse(birdsCount.value);
    final double? weight = double.tryParse(birdWeight.value);
    if (birds != null && weight != null) {
      totalWeight.value = birds * weight;
    } else {
      totalWeight.value = 0.0;
    }
  }
}
