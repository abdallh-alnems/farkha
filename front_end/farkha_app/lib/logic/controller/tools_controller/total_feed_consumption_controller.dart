import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/id/tool_ids.dart';
import 'tool_usage_controller.dart';

class TotalFeedConsumptionController extends GetxController {
  static const int toolId =
      ToolIds.totalFeedConsumption; // Total Feed Consumption tool ID = 5

  final TextEditingController textController = TextEditingController();
  final RxString result = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }

  void calculateTotalFeedConsumption() {
    if (textController.text.isEmpty) {
      return;
    }

    final int count = int.parse(textController.text);

    double badi = count * 0.5;
    double nami = count * 1.2;
    double nahi = count * 1.8;
    double total = count * 3.5;

    result.value =
        'استهلاك ${textController.text} فرخ للعلف طوال الدورة :\n \n'
        'استهلاك العلف البادي : ${badi.toStringAsFixed(0)} كيلو\n \n'
        'استهلاك العلف النامي : ${nami.toStringAsFixed(0)} كيلو\n \n'
        'استهلاك العلف الناهي : ${nahi.toStringAsFixed(0)} كيلو\n \n'
        'الاستهلاك الكلي للعلف : ${total.toStringAsFixed(0)} كيلو';
  }

  void resetInputs() {
    textController.clear();
    result.value = '';
    FocusScope.of(Get.context!).unfocus();
  }
}
