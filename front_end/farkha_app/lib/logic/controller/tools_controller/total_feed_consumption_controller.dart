import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TotalFeedConsumptionController extends GetxController {
  final TextEditingController textController = TextEditingController();

  final RxDouble badiResult = 0.0.obs;
  final RxDouble namiResult = 0.0.obs;
  final RxDouble nahiResult = 0.0.obs;
  final RxDouble totalResult = 0.0.obs;
  final RxInt chickenCount = 0.obs;

  bool calculateTotalFeedConsumption() {
    final count = int.tryParse(textController.text.trim());
    if (count == null || count <= 0) return false;

    chickenCount.value = count;
    badiResult.value = count * 0.5;
    namiResult.value = count * 1.2;
    nahiResult.value = count * 1.8;
    totalResult.value = count * 3.5;
    return true;
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
