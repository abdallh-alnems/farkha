import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/class/crud.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/id/tool_ids.dart';
import '../../../core/functions/handing_data_controller.dart';
import '../../../data/data_source/remote/prices_data/broiler_price_data.dart';
import '../../../data/data_source/static/chicken_data.dart';
import '../weather_controller.dart';
import 'tool_usage_controller.dart';

class BroilerController extends GetxController {
  static const int toolId =
      ToolIds
          .broilerChickenRequirements; // Broiler Chicken Requirements tool ID = 13

  final TextEditingController chickensCountController = TextEditingController();
  final Rxn selectedChickenAge = Rxn();

  late final WeatherController weatherController;

  final RxInt ageTemperature = 0.obs;
  int ageDarkness = 0;
  int ageWeight = 0;

  int dailyFeedConsumption = 0;
  double totalFeedConsumption = 0.0;
  String ageHumidityRange = "";
  int chickensPerSquareMeter = 0;
  final RxDouble requiredArea = 0.0.obs;
  double collegeArea = 0.0;

  RxBool showData = false.obs;
  final RxDouble broilerPrice = 35.0.obs; // قيمة افتراضية
  late final BroilerPriceData broilerPriceData;

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
    dailyFeedConsumption = 0;
    totalFeedConsumption = 0.0;
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

  bool get hasWeatherTemperature => weatherController.hasWeatherData;

  String get weatherTemperatureText {
    final String tempText = weatherController.temperatureText;
    if (tempText == "فعّل صلاحية الموقع") {
      return tempText;
    }
    return "الخارج : $tempText";
  }

  String get weatherHumidityText {
    final String humidityText = weatherController.humidityText;
    if (humidityText == "فعّل صلاحية الموقع") {
      return humidityText;
    }
    return "الخارج : $humidityText";
  }

  String get weatherLocationShort => weatherController.locationMessage;

  void refreshWeatherTemperature() {
    weatherController.refreshWeather();
  }

  Future<void> fetchBroilerPrice() async {
    try {
      var response = await broilerPriceData.getBroilerPrice();
      final status = handlingData(response);

      if (StatusRequest.success == status) {
        final mapResponse = response as Map<String, dynamic>;
        if (mapResponse['status'] == "success") {
          final data = mapResponse['data'] as Map<String, dynamic>?;
          if (data != null && data['price'] != null) {
            final price = double.tryParse(data['price'].toString());
            if (price != null && price > 0) {
              broilerPrice.value = price;
            }
          }
        }
      }
    } catch (e) {
      // في حالة الخطأ، نستخدم القيمة الافتراضية
      broilerPrice.value = 35.0;
    }
  }

  @override
  void onInit() {
    super.onInit();
    weatherController =
        Get.isRegistered<WeatherController>()
            ? Get.find<WeatherController>()
            : Get.put(WeatherController());
    broilerPriceData = BroilerPriceData(Get.find<Crud>());
    ToolUsageController.recordToolUsageFromController(toolId);
    // جلب السعر عند تهيئة الـ controller
    fetchBroilerPrice();
  }
}
