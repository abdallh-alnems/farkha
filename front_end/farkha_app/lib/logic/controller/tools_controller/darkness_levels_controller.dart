import 'package:get/get.dart';

import '../../../data/data_source/static/growth_parameters.dart';

class DarknessLevelsController extends GetxController {
  final RxInt selectedDay = 1.obs;
  final RxString result = ''.obs;

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
