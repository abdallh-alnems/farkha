import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/functions/input_validation.dart';
import '../../../core/package/snackbar_message.dart';

class FeedCostPerKiloController extends GetxController {
  RxDouble totalFeedConsumed = 0.0.obs; // كمية العلف الكلية المستهلكة (طن)
  RxDouble totalWeightSold = 0.0.obs; // الوزن الكلي المباع (طن)
  RxDouble feedPricePerTon = 0.0.obs; // سعر الطن علف (جنيه)
  RxDouble feedCostPerTon = 0.0.obs; // تكلفة العلف لكل طن وزن
  RxBool hasCalculated = false.obs; // لتتبع ما إذا تم الحساب أم لا

  void calculateFeedCostPerKilo(BuildContext context) {
    // التحقق من صحة كمية العلف المستهلكة
    final feedValidation = InputValidation.validateAndFormatNumber(
      totalFeedConsumed.value.toString(),
    );
    if (feedValidation != null) {
      SnackbarMessage.show(
        context,
        'كمية العلف المستهلكة: $feedValidation',
        icon: Icons.error,
      );
      return;
    }

    // التحقق من صحة الوزن المباع
    final weightValidation = InputValidation.validateAndFormatNumber(
      totalWeightSold.value.toString(),
    );
    if (weightValidation != null) {
      SnackbarMessage.show(
        context,
        'الوزن المباع: $weightValidation',
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

    // حساب تكلفة العلف لكل طن وزن
    // المعادلة: (كمية العلف الكلية المستهلكة / الوزن الكلي المباع) × سعر الطن علف
    feedCostPerTon.value =
        (totalFeedConsumed.value / totalWeightSold.value) *
        feedPricePerTon.value;
    hasCalculated.value = true;
  }

  void resetCalculation() {
    hasCalculated.value = false;
  }

  String getFormattedResult() {
    if (!hasCalculated.value) return '';

    return feedCostPerTon.value.toStringAsFixed(1);
  }

  String getTotalFeedCostFormatted() {
    if (!hasCalculated.value) return '';

    double totalFeedCost = totalFeedConsumed.value * feedPricePerTon.value;
    return totalFeedCost.toStringAsFixed(1);
  }
}
