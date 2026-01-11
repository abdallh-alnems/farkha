import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

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
  final RxDouble currentPrecipitation = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // تحميل بيانات الطقس تلقائياً عند بدء التشغيل
    getWeatherData();
  }

  Future<void> getWeatherData() async {
    // التحقق من حالة الموقع المحلية (من GetStorage)
    final storage = GetStorage();
    final isLocationEnabledLocally =
        storage.read<bool>('location_enabled') ?? true;

    // إذا كانت الموقع معطلة محلياً، لا نستخدم الموقع
    if (!isLocationEnabledLocally) {
      statusRequest = StatusRequest.failure;
      update();
      return;
    }

    final hasPermission = await permission.checkAndRequestLocationPermission();

    if (hasPermission) {
      await _fetchWeatherData();
    } else {
      // تحديث الحالة عند عدم وجود صلاحية
      statusRequest = StatusRequest.failure;
      update();
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
            currentPrecipitation.value =
                data['current']['precip_mm']?.toDouble() ?? 0.0;
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
    currentPrecipitation.value = 0.0;
    update();
  }

  // دوال مساعدة للحصول على البيانات
  bool get hasWeatherData => statusRequest == StatusRequest.success;
  bool get isLoading => statusRequest == StatusRequest.loading;
  bool get hasError => statusRequest == StatusRequest.failure;

  // رسالة الموقع الموحدة
  String get locationMessage {
    if (hasWeatherData) {
      final String region =
          currentRegion.value.isEmpty ? "غير محدد" : currentRegion.value;
      final String center =
          currentCenter.value.isEmpty ? "غير محدد" : currentCenter.value;
      return "$region - $center";
    }
    return "فعّل صلاحية الموقع";
  }

  // قيمة درجة الحرارة أو رسالة الخطأ
  String get temperatureText {
    if (hasWeatherData) {
      return "°${currentTemperature.value.toStringAsFixed(0)}";
    }
    return "فعّل صلاحية الموقع";
  }

  // قيمة الرطوبة أو رسالة الخطأ
  String get humidityText {
    if (hasWeatherData) {
      return "${currentHumidity.value}%";
    }
    return "فعّل صلاحية الموقع";
  }
}
