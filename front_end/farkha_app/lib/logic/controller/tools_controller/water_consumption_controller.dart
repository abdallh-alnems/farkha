import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/functions/number_format.dart';
import '../../../data/data_source/static/chicken_data.dart';

class WaterConsumptionController extends GetxController {
  /// End of cycle = 35 days only
  static const int _ageEndOfCycle = 35;

  final TextEditingController textController = TextEditingController();
  final Rxn<int> selectedAge = Rxn<int>();
  final RxString resultDaily = ''.obs;
  final RxString resultWeekly = ''.obs;
  final RxString resultToEndOfCycle = ''.obs;

  String _formatWater(double ml) {
    if (ml < 1000) {
      return '${formatDecimal(ml, decimals: 0)} مل';
    }
    return '${formatDecimal(ml / 1000)} لتر';
  }

  int _sumConsumption(int startDay, int endDay) {
    final int startIndex = startDay - 1;
    final int endIndex = endDay < waterConsumptions.length
        ? endDay - 1
        : waterConsumptions.length - 1;
    int sum = 0;
    for (int i = startIndex; i <= endIndex; i++) {
      sum += waterConsumptions[i];
    }
    return sum;
  }

  void calculateWaterConsumption() {
    if (textController.text.isEmpty || selectedAge.value == null) {
      return;
    }

    final int count = int.parse(textController.text);
    final int age = selectedAge.value!;
    final double dailyWater =
        waterConsumptions[age - 1] * count.toDouble();

    // Weekly = sum of next 7 days (current day + 6 ahead)
    final int startIndex = age - 1;
    final int endIndex = startIndex + 6 < waterConsumptions.length
        ? startIndex + 6
        : waterConsumptions.length - 1;
    int sumNextSevenDays = 0;
    for (int i = startIndex; i <= endIndex; i++) {
      sumNextSevenDays += waterConsumptions[i];
    }
    resultWeekly.value = _formatWater(sumNextSevenDays * count.toDouble());

    // From entered age to end of cycle (35 days only)
    if (age <= _ageEndOfCycle) {
      final int sumToEnd = _sumConsumption(age, _ageEndOfCycle);
      resultToEndOfCycle.value = _formatWater(sumToEnd * count.toDouble());
    } else {
      resultToEndOfCycle.value = '—';
    }

    resultDaily.value = _formatWater(dailyWater);
  }

  void resetInputs() {
    textController.clear();
    selectedAge.value = null;
    resultDaily.value = '';
    resultWeekly.value = '';
    resultToEndOfCycle.value = '';
    FocusScope.of(Get.context!).unfocus();
  }
}
