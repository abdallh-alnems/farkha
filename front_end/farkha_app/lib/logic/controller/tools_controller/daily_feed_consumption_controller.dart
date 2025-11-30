import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/id/tool_ids.dart';
import '../../../core/functions/input_validation.dart';
import '../../../core/shared/snackbar_message.dart';
import '../../../data/data_source/static/chicken_data.dart';
import 'tool_usage_controller.dart';

class DailyFeedConsumptionController extends GetxController {
  static const int toolId =
      ToolIds.dailyFeedConsumption; // Daily Feed Consumption tool ID = 4

  final TextEditingController textController = TextEditingController();
  final Rxn selectedAge = Rxn<int>();
  final RxString result = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }

  void calculateDailyFeedConsumption(BuildContext context) {
    // التحقق من صحة الرقم
    final numberValidation = InputValidation.validateAndFormatNumber(
      textController.text,
    );
    if (numberValidation != null) {
      SnackbarMessage.show(context, numberValidation, icon: Icons.error);
      return;
    }

    // التحقق من تحديد العمر
    if (selectedAge.value == null) {
      SnackbarMessage.show(context, 'الرجاء تحديد العمر', icon: Icons.error);
      return;
    }

    final int count = int.parse(textController.text);

    double totalFeed =
        feedConsumptions[selectedAge.value! - 1] * count.toDouble();

    if (totalFeed < 1000) {
      result.value = '${totalFeed.toStringAsFixed(0)} جرام';
    } else {
      double totalFeedInKilo = totalFeed / 1000;
      result.value = '${totalFeedInKilo.toStringAsFixed(1)} كيلو';
    }
  }

  void resetInputs() {
    textController.clear();
    selectedAge.value = null;
    result.value = '';
    FocusScope.of(Get.context!).unfocus();
  }
}
