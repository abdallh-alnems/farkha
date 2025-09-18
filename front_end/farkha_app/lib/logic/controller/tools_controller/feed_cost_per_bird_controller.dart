import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/functions/input_validation.dart';
import '../../../core/package/snackbar_message.dart';

class FeedCostPerBirdController extends GetxController {
  RxDouble totalFeedQuantity = 0.0.obs; // إجمالي كمية العلف بالطن
  RxDouble feedPricePerTon = 0.0.obs; // سعر الطن الواحد من العلف
  RxInt numberOfBirds = 0.obs; // عدد الطيور
  RxDouble feedCostPerBird = 0.0.obs; // تكلفة العلف لكل طائر
  RxBool hasCalculated = false.obs; // لتتبع ما إذا تم الحساب أم لا

  void calculateFeedCostPerBird(BuildContext context) {
    // التحقق من صحة كمية العلف
    final feedValidation = InputValidation.validateAndFormatNumber(
      totalFeedQuantity.value.toString(),
    );
    if (feedValidation != null) {
      SnackbarMessage.show(
        context,
        'كمية العلف: $feedValidation',
        icon: Icons.error,
      );
      return;
    }

    // التحقق من صحة سعر العلف
    final priceValidation = InputValidation.validateAndFormatNumber(
      feedPricePerTon.value.toString(),
    );
    if (priceValidation != null) {
      SnackbarMessage.show(
        context,
        'سعر العلف: $priceValidation',
        icon: Icons.error,
      );
      return;
    }

    // التحقق من صحة عدد الطيور
    final birdsValidation = InputValidation.validateAndFormatNumber(
      numberOfBirds.value.toString(),
    );
    if (birdsValidation != null) {
      SnackbarMessage.show(
        context,
        'عدد الطيور: $birdsValidation',
        icon: Icons.error,
      );
      return;
    }

    // حساب إجمالي تكلفة العلف
    double totalFeedCost = totalFeedQuantity.value * feedPricePerTon.value;

    // حساب تكلفة العلف لكل طائر
    feedCostPerBird.value = totalFeedCost / numberOfBirds.value;
    hasCalculated.value = true;
  }

  void resetCalculation() {
    hasCalculated.value = false;
  }

  String getFormattedResult() {
    if (!hasCalculated.value) return '';

    return feedCostPerBird.value.toStringAsFixed(1);
  }

  String getTotalFeedCostFormatted() {
    if (!hasCalculated.value) return '';

    double totalFeedCost = totalFeedQuantity.value * feedPricePerTon.value;
    return totalFeedCost.toStringAsFixed(1);
  }
}
