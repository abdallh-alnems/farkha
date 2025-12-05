import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/id/tool_ids.dart';
import '../../../core/functions/input_validation.dart';
import '../../../core/shared/snackbar_message.dart';
import 'tool_usage_controller.dart';

class FcrController extends GetxController {
  static const int toolId = ToolIds.fcr; // FCR tool ID = 1

  final double initialWeight =
      0.045; // الوزن الابتدائي الثابت بالكيلوغرام (45 جرام = 0.045 كجم)

  RxDouble feedConsumed = 0.0.obs; // كمية العلف المستهلك (كجم)
  RxDouble currentWeight = 0.0.obs; // الوزن الحالي للقطيع (كجم)
  RxDouble fcr = 0.0.obs; // الناتج

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }

  void calculateFCR(BuildContext context) {
    // التحقق من صحة العلف المستهلك
    final feedValidation = InputValidation.validateAndFormatNumber(
      feedConsumed.value.toString(),
    );
    if (feedValidation != null) {
      SnackbarMessage.show(
        context,
        'العلف المستهلك: $feedValidation',
        icon: Icons.error,
      );
      return;
    }

    // التحقق من صحة الوزن الحالي
    final weightValidation = InputValidation.validateAndFormatNumber(
      currentWeight.value.toString(),
    );
    if (weightValidation != null) {
      SnackbarMessage.show(
        context,
        'الوزن الحالي: $weightValidation',
        icon: Icons.error,
      );
      return;
    }

    double weightGain = currentWeight.value - initialWeight;
    if (weightGain > 0) {
      fcr.value = feedConsumed.value / weightGain;
    } else {
      fcr.value = 0.0;
    }
  }
}
