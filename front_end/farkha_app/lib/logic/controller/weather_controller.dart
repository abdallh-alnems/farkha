import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/functions/handing_data_controller.dart';
import '../../core/services/permission.dart';
import '../../core/services/weather.dart';

class WeatherController extends GetxController {
  final WeatherService weatherService = WeatherService();
  late StatusRequest statusRequest = StatusRequest.none;
  final PermissionController permission = Get.find<PermissionController>();

  final RxString currentRegion = ''.obs;
  final RxString currentCenter = ''.obs;

  final RxDouble currentTemperature = 0.0.obs;
  final RxInt currentHumidity = 0.obs;
  final RxDouble currentWindSpeed = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // تحميل بيانات الطقس تلقائياً عند بدء التشغيل
    getWeatherData();
  }

  Future<void> getWeatherData() async {
    final hasPermission = await permission.checkAndRequestLocationPermission();

    if (hasPermission) {
      await _fetchWeatherData();
    }
  }

  Future<void> _fetchWeatherData() async {
    try {
      statusRequest = StatusRequest.loading;
      update(); // تحديث الواجهة لإظهار حالة التحميل

      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );

        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          currentRegion.value = placemarks[0].locality ?? 'غير محدد';
          currentCenter.value =
              placemarks[0].subAdministrativeArea ?? 'غير محدد';

          final data = await weatherService.getWeatherData(
            position.latitude,
            position.longitude,
          );
          statusRequest = handlingData(data);
          if (statusRequest == StatusRequest.success) {
            currentTemperature.value =
                data['current']['temp_c']?.toDouble() ?? 0.0;
            currentHumidity.value = data['current']['humidity']?.toInt() ?? 0;
            currentWindSpeed.value =
                data['current']['wind_kph']?.toDouble() ?? 0.0;
          } else {
            statusRequest = StatusRequest.failure;
          }
        } else {
          statusRequest = StatusRequest.failure;
        }
      } else {
        statusRequest = StatusRequest.failure;
      }
    } catch (e) {
      statusRequest = StatusRequest.failure;
    }
    update(); // تحديث الواجهة لإظهار النتيجة النهائية
  }

  void refreshWeather() {
    getWeatherData();
  }

  void reset() {
    statusRequest = StatusRequest.none;
    currentRegion.value = '';
    currentCenter.value = '';
    currentTemperature.value = 0.0;
    currentHumidity.value = 0;
    currentWindSpeed.value = 0.0;
    update();
  }

  // دوال مساعدة للحصول على البيانات
  bool get hasWeatherData => statusRequest == StatusRequest.success;
  bool get isLoading => statusRequest == StatusRequest.loading;
  bool get hasError => statusRequest == StatusRequest.failure;
}
