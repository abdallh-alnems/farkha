import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/functions/input_validation.dart';
import '../../../core/package/snackbar_message.dart';

class MortalityRateController extends GetxController {
  final RxInt initialCount = 0.obs;
  final RxInt deaths = 0.obs;
  final RxDouble mortalityRate = 0.0.obs;

  void calculateMortalityRate(BuildContext context) {
    // التحقق من صحة العدد الأولي
    final initialValidation = InputValidation.validateAndFormatNumber(
      initialCount.value.toString(),
    );
    if (initialValidation != null) {
      SnackbarMessage.show(
        context,
        'العدد الأولي: $initialValidation',
        icon: Icons.error,
      );
      return;
    }

    // التحقق من صحة عدد النفوق
    final deathsValidation = InputValidation.validateAndFormatNumber(
      deaths.value.toString(),
    );
    if (deathsValidation != null) {
      SnackbarMessage.show(
        context,
        'عدد النفوق: $deathsValidation',
        icon: Icons.error,
      );
      return;
    }

    if (initialCount.value > 0) {
      mortalityRate.value = (deaths.value / initialCount.value) * 100;
    } else {
      mortalityRate.value = 0.0;
    }
  }

  void reset() {
    initialCount.value = 0;
    deaths.value = 0;
    mortalityRate.value = 0.0;
  }
}
