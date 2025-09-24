import 'package:get/get.dart';

import '../../../core/constant/tool_ids.dart';
import '../../../data/data_source/static/growth_parameters.dart';
import '../tool_usage_controller.dart';

class DarknessLevelsController extends GetxController {
  static const int toolId =
      ToolIds.darknessLevels; // Darkness Levels tool ID = 8

  final RxInt selectedDay = 1.obs;
  final RxString result = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }

  int get maxDay => darknessLevels.length;
  int get darkness => darknessLevels[selectedDay.value - 1];

  void setDay(int day) => selectedDay.value = day;

  void calculateDarknessLevels() {
    final int darknessHours = darkness;

    if (darknessHours == 0) {
      result.value = 'لا يوجد إظلام في اليوم ${selectedDay.value}';
    } else {
      result.value =
          'ساعات الإظلام في اليوم ${selectedDay.value}: $darknessHours ساعة';
    }
  }
}
