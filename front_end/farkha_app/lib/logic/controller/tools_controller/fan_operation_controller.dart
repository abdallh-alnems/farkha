import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/id/tool_ids.dart';
import '../../../core/functions/input_validation.dart';
import '../../../core/shared/snackbar_message.dart';
import '../weather_controller.dart';
import 'tool_usage_controller.dart';

class FanOperationController extends GetxController {
  static const int toolId = ToolIds.fanOperation; // Fan Operation tool ID = 9

  // Weather controller
  WeatherController weatherController = Get.put(WeatherController());

  // Input variables
  RxInt numberOfBirds = 0.obs; // عدد الطيور
  RxDouble averageWeight = 0.0.obs; // متوسط الوزن بالكيلو
  RxDouble fanCapacityPerHour = 0.0.obs; // سعة المروحة بالمتر المكعب/ساعة
  RxDouble temperature = 0.0.obs; // درجة الحرارة

  // Calculated results
  RxDouble totalWeight = 0.0.obs; // الوزن الكلي للطيور بالكيلو
  RxDouble airFlowPerKg = 0.0.obs; // كمية الهواء المطلوبة لكل كجم
  RxDouble requiredAirFlowPerHour = 0.0.obs; // كمية الهواء المطلوبة في الساعة
  RxDouble fanCapacityPerMinute = 0.0.obs; // قدرة الشفاط في الدقيقة
  RxDouble operationDuration = 0.0.obs; // مدة التشغيل بالدقائق
  RxString operationStatus = ''.obs; // حالة التشغيل

  void calculateFanOperation(BuildContext context) {
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

    // التحقق من صحة متوسط الوزن
    final weightValidation = InputValidation.validateAndFormatNumber(
      averageWeight.value.toString(),
    );
    if (weightValidation != null) {
      SnackbarMessage.show(
        context,
        'متوسط الوزن: $weightValidation',
        icon: Icons.error,
      );
      return;
    }

    // التحقق من صحة سعة المروحة في الساعة
    final fanCapacityValidation = InputValidation.validateAndFormatNumber(
      fanCapacityPerHour.value.toString(),
    );
    if (fanCapacityValidation != null) {
      SnackbarMessage.show(
        context,
        'سعة المروحة في الساعة: $fanCapacityValidation',
        icon: Icons.error,
      );
      return;
    }

    // التحقق من القيم الأساسية
    if (numberOfBirds.value <= 0) {
      SnackbarMessage.show(
        context,
        'يجب إدخال عدد الطيور بشكل صحيح',
        icon: Icons.error,
      );
      return;
    }

    if (averageWeight.value <= 0) {
      SnackbarMessage.show(
        context,
        'يجب إدخال متوسط الوزن بشكل صحيح',
        icon: Icons.error,
      );
      return;
    }

    if (fanCapacityPerHour.value <= 0) {
      SnackbarMessage.show(
        context,
        'يجب إدخال سعة المروحة في الساعة بشكل صحيح',
        icon: Icons.error,
      );
      return;
    }

    // 1. حساب الوزن الكلي للطيور
    totalWeight.value = numberOfBirds.value * averageWeight.value;

    // 2. تحديد كمية الهواء المطلوبة لكل كجم حسب درجة الحرارة
    final currentTemp =
        temperature.value > 0
            ? temperature.value
            : weatherController.currentTemperature.value;
    if (currentTemp < 10) {
      airFlowPerKg.value = 0.4; // م³/ساعة لكل كجم
    } else if (currentTemp >= 10 && currentTemp <= 20) {
      airFlowPerKg.value = 1.4; // م³/ساعة لكل كجم
    } else if (currentTemp >= 25 && currentTemp <= 35) {
      airFlowPerKg.value = 4.3; // م³/ساعة لكل كجم
    } else if (currentTemp > 35) {
      airFlowPerKg.value = 7.5; // متوسط 7-8 م³/ساعة لكل كجم
    } else {
      // للحرارة بين 20-25 درجة
      airFlowPerKg.value = 2.5; // قيمة متوسطة
    }

    // 3. حساب كمية الهواء المطلوبة في الساعة
    requiredAirFlowPerHour.value = totalWeight.value * airFlowPerKg.value;

    // 4. حساب قدرة الشفاط في الدقيقة
    fanCapacityPerMinute.value = fanCapacityPerHour.value / 60;

    // 5. حساب مدة التشغيل
    if (fanCapacityPerMinute.value > 0) {
      operationDuration.value =
          requiredAirFlowPerHour.value / fanCapacityPerMinute.value;
    } else {
      operationDuration.value = 0;
    }

    // 6. تحديد حالة التشغيل
    if (operationDuration.value <= 60) {
      operationStatus.value =
          'تشغيل مستمر (${operationDuration.value.toStringAsFixed(1)} دقيقة)';
    } else if (operationDuration.value <= 120) {
      operationStatus.value =
          'تشغيل متقطع (${operationDuration.value.toStringAsFixed(1)} دقيقة)';
    } else {
      operationStatus.value =
          'تشغيل خفيف (${operationDuration.value.toStringAsFixed(1)} دقيقة)';
    }

    // تم إلغاء رسالة النجاح بناءً على طلب المستخدم
  }

  // Helper methods for updating values
  void updateNumberOfBirds(String value) {
    numberOfBirds.value = int.tryParse(value) ?? 0;
  }

  void updateAverageWeight(String value) {
    averageWeight.value = double.tryParse(value) ?? 0.0;
  }

  void updateFanCapacityPerHour(String value) {
    fanCapacityPerHour.value = double.tryParse(value) ?? 0.0;
  }

  void updateTemperature(String value) {
    temperature.value = double.tryParse(value) ?? 0.0;
  }

  Future<void> getWeatherData() async {
    await weatherController.getWeatherData();
    // تحديث قيمة درجة الحرارة في الحقل
    if (weatherController.hasWeatherData && currentTemperature > 0) {
      temperature.value = currentTemperature;
      update(); // تحديث الواجهة
    }
  }

  // Getter for current temperature from weather controller
  double get currentTemperature => weatherController.currentTemperature.value;

  // Getter for weather loading status
  bool get isWeatherLoading => weatherController.isLoading;

  // Getter for weather error status
  bool get hasWeatherError => weatherController.hasError;

  // Getter for location message
  String get locationMessage => weatherController.locationMessage;

  // Getter for weather data status
  bool get hasWeatherData => weatherController.hasWeatherData;

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }
}
