import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/functions/number_format.dart';
import '../../../data/data_source/static/chicken_data.dart';

class DailyFeedConsumptionController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final Rxn<int> selectedAge = Rxn<int>();
  final RxString result = ''.obs;

  void calculateDailyFeedConsumption() {
    if (textController.text.isEmpty || selectedAge.value == null) {
      return;
    }

    final int count = int.parse(textController.text);

    final age = selectedAge.value!;
    final double totalFeed = feedConsumptions[age - 1] * count.toDouble();

    if (totalFeed < 1000) {
      result.value = '${formatDecimal(totalFeed, decimals: 0)} جرام';
    } else {
      final double totalFeedInKilo = totalFeed / 1000;
      result.value = '${formatDecimal(totalFeedInKilo)} كيلو';
    }
  }

  void resetInputs() {
    textController.clear();
    selectedAge.value = null;
    result.value = '';
    FocusScope.of(Get.context!).unfocus();
  }
}
