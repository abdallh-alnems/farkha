import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdgController extends GetxController {
  static const double initialWeight = 45; // جرام

  final TextEditingController daysController = TextEditingController();
  final TextEditingController currentWeightKgController =
      TextEditingController();

  RxDouble adg = 0.0.obs;

  void calculateADG() {
    final days = double.tryParse(daysController.text) ?? 0;
    final kg = double.tryParse(currentWeightKgController.text) ?? 0;
    final currentWeightG = kg * 1000;

    if (days > 0 && currentWeightG > initialWeight) {
      adg.value = (currentWeightG - initialWeight) / days;
    } else {
      adg.value = 0.0;
    }
  }

  /// Returns ADG quality: 0=excellent, 1=good, 2=fair, 3=needs improvement
  int getAdgQuality() {
    final value = adg.value;
    if (value >= 55) return 0;
    if (value >= 45) return 1;
    if (value >= 35) return 2;
    return 3;
  }

  void reset() {
    daysController.clear();
    currentWeightKgController.clear();
    adg.value = 0.0;
  }

  @override
  void onClose() {
    daysController.dispose();
    currentWeightKgController.dispose();
    super.onClose();
  }
}
