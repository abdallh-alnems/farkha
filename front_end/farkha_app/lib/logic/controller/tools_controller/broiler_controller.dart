import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/tool_ids.dart';
import '../../../data/data_source/static/growth_parameters.dart';
import '../tool_usage_controller.dart';

class BroilerController extends GetxController {
  static const int toolId =
      ToolIds
          .broilerChickenRequirements; // Broiler Chicken Requirements tool ID = 13

  final TextEditingController chickensCountController = TextEditingController();
  final Rxn selectedChickenAge = Rxn();

  final RxInt ageTemperature = 0.obs;
  late int ageDarkness;
  late int ageWeight;

  late int dailyFeedConsumption;
  late double totalFeedConsumption;
  String ageHumidityRange = "";
  late int chickensPerSquareMeter;
  final RxDouble requiredArea = 0.0.obs;
  late double collegeArea;

  RxBool showData = false.obs;

  void validateInputs() {
    final chickensText = chickensCountController.text;
    final isValidChickens =
        chickensText.isNotEmpty && int.tryParse(chickensText) != null;
    if (isValidChickens && selectedChickenAge.value != null) {
      ageOfChickens();
      getTemperature();
      calculateArea();
      getLighting();
      getWeight();
      calculateFeedConsumption();
      showData.value = true;
    }
  }

  void onPressed() {
    validateInputs();
  }

  void reset() {
    chickensCountController.clear();
    selectedChickenAge.value = null;
    ageTemperature.value = 0;
    // الحقول اللاحقة مجرد متغيرات عادية:
    ageHumidityRange = '';
    chickensPerSquareMeter = 0;
    showData.value = false;
    requiredArea.value = 0.0;
    collegeArea = 0.0;
  }

  void ageOfChickens() {
    if (selectedChickenAge.value != null) {
      if (selectedChickenAge.value! <= 7) {
        ageHumidityRange = '60-70%';
        chickensPerSquareMeter = 30;
      } else if (selectedChickenAge.value! <= 14) {
        ageHumidityRange = '60-70%';
        chickensPerSquareMeter = 25;
      } else if (selectedChickenAge.value! <= 21) {
        ageHumidityRange = '50-60%';
        chickensPerSquareMeter = 20;
      } else if (selectedChickenAge.value! <= 28) {
        ageHumidityRange = '50-60%';
        chickensPerSquareMeter = 15;
      } else {
        ageHumidityRange = '50-55%';
        chickensPerSquareMeter = 10;
      }
    }
  }

  void getTemperature() {
    ageTemperature.value = temperatureList[selectedChickenAge.value! - 1];
  }

  void getLighting() {
    ageDarkness = darknessLevels[selectedChickenAge.value! - 1];
  }

  void getWeight() {
    ageWeight = weightsList[selectedChickenAge.value! - 1];
  }

  void calculateFeedConsumption() {
    final int? chickens = int.tryParse(chickensCountController.text);

    dailyFeedConsumption =
        feedConsumptions[selectedChickenAge.value! - 1] * chickens!;
    totalFeedConsumption = chickens * 3.5;
  }

  void calculateArea() {
    final int? chickens = int.tryParse(chickensCountController.text);

    requiredArea.value = (chickens! / chickensPerSquareMeter).clamp(
      1,
      double.infinity,
    );

    collegeArea = (chickens / 10).clamp(1, double.infinity);
  }

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }
}
