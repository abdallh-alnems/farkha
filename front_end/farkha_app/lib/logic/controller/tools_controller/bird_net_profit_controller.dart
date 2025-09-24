import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/tool_ids.dart';
import '../../../core/functions/input_validation.dart';
import '../../../core/package/snackbar_message.dart';
import '../tool_usage_controller.dart';

class BirdNetProfitController extends GetxController {
  static const int toolId =
      ToolIds.birdNetProfit; // Bird Net Profit tool ID = 18

  RxDouble totalSale = 0.0.obs;
  RxDouble totalCost = 0.0.obs;
  RxInt soldBirds = 0.obs;
  RxDouble netProfit = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }

  void calculateNetProfit(BuildContext context) {
    // التحقق من صحة إجمالي المبيعات
    final saleValidation = InputValidation.validateAndFormatNumber(
      totalSale.value.toString(),
    );
    if (saleValidation != null) {
      SnackbarMessage.show(
        context,
        'إجمالي المبيعات: $saleValidation',
        icon: Icons.error,
      );
      return;
    }

    // التحقق من صحة إجمالي التكاليف
    final costValidation = InputValidation.validateAndFormatNumber(
      totalCost.value.toString(),
    );
    if (costValidation != null) {
      SnackbarMessage.show(
        context,
        'إجمالي التكاليف: $costValidation',
        icon: Icons.error,
      );
      return;
    }

    // التحقق من صحة عدد الطيور المباعة
    final birdsValidation = InputValidation.validateAndFormatNumber(
      soldBirds.value.toString(),
    );
    if (birdsValidation != null) {
      SnackbarMessage.show(
        context,
        'عدد الطيور المباعة: $birdsValidation',
        icon: Icons.error,
      );
      return;
    }

    if (soldBirds.value > 0) {
      final totalProfit = totalSale.value - totalCost.value;
      netProfit.value = totalProfit / soldBirds.value;
    } else {
      netProfit.value = 0.0;
    }
  }

  void calculate(BuildContext context) {
    calculateNetProfit(context);
  }
}
