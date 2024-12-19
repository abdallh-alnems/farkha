import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/class/status_request.dart';
import '../../../core/functions/handing_data_controller.dart';
import '../../../core/services/permission.dart';
import '../../../core/services/weather.dart';
import '../../../data/data_source/static/poultry_management_data.dart';

class BroilerController extends GetxController {
  final TextEditingController chickensCountController = TextEditingController();
  final Rxn selectedChickenAge = Rxn();
  final WeatherService weatherService = WeatherService();
  late StatusRequest statusRequest = StatusRequest.none;
  final PermissionController permission = Get.find<PermissionController>();

  final RxString currentRegion = ''.obs;
  final RxString currentCenter = ''.obs;

  final RxDouble currentTemperature = 0.0.obs;
  final RxInt currentHumidity = 0.obs;
  final RxDouble currentWindSpeed = 0.0.obs;

  late int ageTemperature;
  late int ageDarkness;
  late int ageWeight;

  late int dailyFeedConsumption;
  late double totalFeedConsumption;
  late String ageHumidityRange;
  late int chickensPerSquareMeter;
  late double requiredArea;
  late double collegeArea;

  RxBool showData = false.obs;

  void validateInputs() {
    final chickensText = chickensCountController.text;
    final isValidChickens =
        chickensText.isNotEmpty && int.tryParse(chickensText) != null;
    if (isValidChickens && selectedChickenAge.value != null) {
      if (statusRequest != StatusRequest.success) {
        getData();
      }
      
      ageOfChickens();
      getTemperature();
      calculateArea();
      getLighting();
      getWeight();
      calculateFeedConsumption();
      showData.value = true;
    }
  }

  void onPressed() async {
    final hasPermission = await permission.checkAndRequestLocationPermission();

    if (hasPermission) {
      validateInputs();
    }
  }

  Future<void> getData() async {
    try {
      statusRequest = StatusRequest.loading;

      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(
            locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
        ));

        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);

        if (placemarks.isNotEmpty) {
          currentRegion.value = placemarks[0].locality!;
          currentCenter.value = placemarks[0].subAdministrativeArea!;

          final data = await weatherService.getWeatherData(
              position.latitude, position.longitude);
          statusRequest = handlingData(data);
          if (statusRequest == StatusRequest.success) {
            currentTemperature.value = data['current']['temp_c'];
            currentHumidity.value = data['current']['humidity'];
            currentWindSpeed.value = data['current']['wind_kph'];
          } else {
            statusRequest = StatusRequest.failure;
          }
        }
      }
    } catch (e) {
      statusRequest = StatusRequest.failure;
    }
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
    ageTemperature = temperatureList[selectedChickenAge.value! - 1];
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

    requiredArea =
        (chickens! / chickensPerSquareMeter).clamp(1, double.infinity);

    collegeArea = (chickens / 10).clamp(1, double.infinity);
  }
}
