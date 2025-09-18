import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/functions/input_validation.dart';
import '../../../core/package/snackbar_message.dart';

class TotalFeedConsumptionController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final RxString result = ''.obs;

  void calculateTotalFeedConsumption(BuildContext context) {
    // التحقق من صحة الرقم
    final numberValidation = InputValidation.validateAndFormatNumber(
      textController.text,
    );
    if (numberValidation != null) {
      SnackbarMessage.show(context, numberValidation, icon: Icons.error);
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
        'الاستهلاك الكلي للعلف طوال الدورة : ${total.toStringAsFixed(0)} كيلو';
  }

  void resetInputs() {
    textController.clear();
    result.value = '';
    FocusScope.of(Get.context!).unfocus();
  }
}
