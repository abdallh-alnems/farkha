import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BroilerChickenRequirementsController extends GetxController {
  final TextEditingController chickensController = TextEditingController();
  final Rxn<int> selectedAge = Rxn<int>();

  // List of temperatures based on age
  final List<int> temperatureList = [
    34, 34, 33, 33, 33, 32, 32, 31, 31, 30, 30, 30, 29, 29, 28, 28, 28, 27, 27, 26, 26, 26, 25, 25, 24, 24, 24, 23, 23, 23,
    22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22
  ];

  // Method to get the temperature based on selected age
  int getTemperature() {
    if (selectedAge.value != null && selectedAge.value! > 0 && selectedAge.value! <= temperatureList.length) {
      return temperatureList[selectedAge.value! - 1]; // Adjust index for 1-based age
    }
    return 0; // Default temperature if not selected or invalid age
  }
}
