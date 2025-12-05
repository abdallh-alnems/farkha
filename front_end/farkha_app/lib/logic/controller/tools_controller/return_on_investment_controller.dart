import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/id/tool_ids.dart';
import '../../../core/functions/input_validation.dart';
import '../../../core/shared/snackbar_message.dart';
import 'tool_usage_controller.dart';

class ReturnOnInvestmentController extends GetxController {
  static const int toolId = ToolIds.roi; // ROI tool ID = 19

  RxDouble investmentCost = 0.0.obs;
  RxDouble totalSale = 0.0.obs;
  RxDouble netProfit = 0.0.obs;
  RxDouble roi = 0.0.obs;
  RxBool hasCalculated = false.obs;

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }

  void calculateROI(BuildContext context) {
    // التحقق من صحة تكلفة الاستثمار
    final investmentValidation = InputValidation.validateAndFormatNumber(
      investmentCost.value.toString(),
    );
    if (investmentValidation != null) {
      SnackbarMessage.show(
        context,
        'تكلفة الاستثمار: $investmentValidation',
        icon: Icons.error,
      );
      return;
    }

    // التحقق من صحة صافي الربح
    final profitValidation = InputValidation.validateAndFormatNumber(
      netProfit.value.toString(),
    );
    if (profitValidation != null) {
      SnackbarMessage.show(
        context,
        'صافي الربح: $profitValidation',
        icon: Icons.error,
      );
      return;
    }

    if (investmentCost.value > 0) {
      // حساب ROI حتى لو كان الربح سالب (خسارة)
      roi.value = (netProfit.value / investmentCost.value) * 100;
      hasCalculated.value = true;
    } else {
      roi.value = 0;
      hasCalculated.value = false;
    }
  }

  void resetCalculation() {
    hasCalculated.value = false;
  }
}
