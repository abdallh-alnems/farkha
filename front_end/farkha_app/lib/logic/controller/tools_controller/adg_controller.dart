import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/functions/input_validation.dart';
import '../../../core/package/snackbar_message.dart';

class AdgController extends GetxController {
  static const double initialWeight = 45; // جرام

  RxInt days = 0.obs;
  RxDouble currentWeight = 0.0.obs;
  RxDouble adg = 0.0.obs;

  void calculateADG(BuildContext context) {
    // التحقق من صحة عدد الأيام
    final daysValidation = InputValidation.validateAndFormatNumber(
      days.value.toString(),
    );
    if (daysValidation != null) {
      SnackbarMessage.show(
        context,
        'عدد الأيام: $daysValidation',
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

    if (days.value > 0 && currentWeight.value > initialWeight) {
      adg.value = (currentWeight.value - initialWeight) / days.value;
    } else {
      adg.value = 0.0;
    }
  }

  void reset() {
    days.value = 0;
    currentWeight.value = 0.0;
    adg.value = 0.0;
  }
}
