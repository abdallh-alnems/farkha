import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/class/status_request.dart';
import '../../core/functions/handing_data_controller.dart';
import '../../core/services/permission.dart';
import '../../core/services/weather.dart';

/// عنصر توقعات يوم واحد
class ForecastDay {
  ForecastDay({
    required this.date,
    required this.maxtempC,
    required this.mintempC,
    required this.conditionText,
  });

  final String date;
  final double maxtempC;
  final double mintempC;
  final String conditionText;
}

class WeatherController extends GetxController {
  final WeatherService weatherService = WeatherService();
  final Rx<StatusRequest> statusRequest = StatusRequest.none.obs;
  final PermissionController permission = Get.find<PermissionController>();

  final RxString currentRegion = ''.obs;
  final RxString currentCenter = ''.obs;

  final RxDouble currentTemperature = 0.0.obs;
  final RxInt currentHumidity = 0.obs;
  final RxDouble currentWindSpeed = 0.0.obs;
  final RxInt currentWindDegree = 0.obs;
  final RxString currentWindDir = ''.obs;
  final RxDouble currentPrecipitation = 0.0.obs;
  final RxString currentConditionText = ''.obs;
  final RxDouble feelsLikeC = 0.0.obs;

  /// حقول إضافية من الـ API (قد لا ترجع في كل الخطط)
  final RxDouble pressureMb = 0.0.obs;
  final RxDouble visKm = 0.0.obs;
  final RxDouble uv = 0.0.obs;
  final RxInt cloud = 0.obs;
  final RxDouble gustKph = 0.0.obs;

  /// توقعات درجة الحرارة للأيام القادمة
  final RxList<ForecastDay> forecastDays = <ForecastDay>[].obs;

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
      statusRequest.value = StatusRequest.failure;
      update();
      return;
    }

    final hasPermission = await permission.checkAndRequestLocationPermission();

    if (hasPermission) {
      await _fetchWeatherData();
    } else {
      // تحديث الحالة عند عدم وجود صلاحية
      statusRequest.value = StatusRequest.failure;
      update();
    }
  }

  Future<void> _fetchWeatherData() async {
    try {
      statusRequest.value = StatusRequest.loading;
      update(); // تحديث الواجهة لإظهار حالة التحميل

      final LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );

        final List<Placemark> placemarks = await placemarkFromCoordinates(
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
          // طباعة استجابة الـ API الخام
          debugPrint('═══════════════ استجابة API الطقس (خام) ═══════════════');
          debugPrint(data.toString());
          debugPrint('══════════════════════════════════════════════════════════');
          statusRequest.value = handlingData(data);
          if (statusRequest.value == StatusRequest.success) {
            final current = data['current'] as Map<String, dynamic>?;
            currentTemperature.value =
                (current?['temp_c'] as num?)?.toDouble() ?? 0.0;
            currentHumidity.value = (current?['humidity'] as num?)?.toInt() ?? 0;
            currentWindSpeed.value =
                (current?['wind_kph'] as num?)?.toDouble() ?? 0.0;
            currentWindDegree.value =
                (current?['wind_degree'] as num?)?.toInt() ?? 0;
            currentWindDir.value =
                (current?['wind_dir'] as String?) ?? '';
            currentPrecipitation.value =
                (current?['precip_mm'] as num?)?.toDouble() ?? 0.0;
            feelsLikeC.value =
                (current?['feelslike_c'] as num?)?.toDouble() ?? 0.0;
            final condition = current?['condition'] as Map<String, dynamic>?;
            currentConditionText.value =
                (condition?['text'] as String?) ?? '';
            pressureMb.value =
                (current?['pressure_mb'] as num?)?.toDouble() ?? 0.0;
            visKm.value =
                (current?['vis_km'] as num?)?.toDouble() ?? 0.0;
            uv.value = (current?['uv'] as num?)?.toDouble() ?? 0.0;
            cloud.value = (current?['cloud'] as num?)?.toInt() ?? 0;
            gustKph.value =
                (current?['gust_kph'] as num?)?.toDouble() ?? 0.0;

            // جلب توقعات الأيام القادمة
            await _fetchForecast(position.latitude, position.longitude);
          } else {
            statusRequest.value = StatusRequest.failure;
          }
        } else {
          statusRequest.value = StatusRequest.failure;
        }
      } else {
        statusRequest.value = StatusRequest.failure;
      }
    } catch (e) {
      statusRequest.value = StatusRequest.failure;
    }
    update(); // تحديث الواجهة لإظهار النتيجة النهائية
  }

  Future<void> _fetchForecast(double lat, double lon) async {
    try {
      final data = await weatherService.getForecastData(lat, lon);
      final forecast = data['forecast'] as Map<String, dynamic>?;
      final forecastdayList = forecast?['forecastday'] as List<dynamic>?;
      if (forecastdayList == null || forecastdayList.isEmpty) {
        forecastDays.clear();
        return;
      }
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final List<ForecastDay> list = [];
      for (final day in forecastdayList) {
        final dayMap = day as Map<String, dynamic>;
        final dateStr = (dayMap['date'] as String?) ?? '';
        if (dateStr == todayStr) continue;
        final dayData = dayMap['day'] as Map<String, dynamic>?;
        final condition = dayData?['condition'] as Map<String, dynamic>?;
        list.add(ForecastDay(
          date: dateStr,
          maxtempC: (dayData?['maxtemp_c'] as num?)?.toDouble() ?? 0.0,
          mintempC: (dayData?['mintemp_c'] as num?)?.toDouble() ?? 0.0,
          conditionText: (condition?['text'] as String?) ?? '',
        ));
      }
      forecastDays.value = list;
    } catch (_) {
      forecastDays.clear();
    }
  }

  void refreshWeather() {
    getWeatherData();
  }

  void reset() {
    statusRequest.value = StatusRequest.none;
    currentRegion.value = '';
    currentCenter.value = '';
    currentTemperature.value = 0.0;
    currentHumidity.value = 0;
    currentWindSpeed.value = 0.0;
    currentWindDegree.value = 0;
    currentWindDir.value = '';
    currentPrecipitation.value = 0.0;
    currentConditionText.value = '';
    feelsLikeC.value = 0.0;
    pressureMb.value = 0.0;
    visKm.value = 0.0;
    uv.value = 0.0;
    cloud.value = 0;
    gustKph.value = 0.0;
    forecastDays.clear();
    update();
  }

  /// ترجمة حالة الطقس للتوقعات (نفس خريطة الحالة الحالية)
  String conditionToArabic(String text) {
    if (text.isEmpty) return '—';
    final key = text.trim().toLowerCase();
    return _conditionToArabic[key] ?? text;
  }

  // دوال مساعدة للحصول على البيانات
  bool get hasWeatherData => statusRequest.value == StatusRequest.success;
  bool get isLoading => statusRequest.value == StatusRequest.loading;
  bool get hasError => statusRequest.value == StatusRequest.failure;

  // رسالة الموقع الموحدة
  String get locationMessage {
    if (hasWeatherData) {
      final String region =
          currentRegion.value.isEmpty ? 'غير محدد' : currentRegion.value;
      final String center =
          currentCenter.value.isEmpty ? 'غير محدد' : currentCenter.value;
      return '$region - $center';
    }
    return 'فعّل صلاحية الموقع';
  }

  // قيمة درجة الحرارة أو رسالة الخطأ
  String get temperatureText {
    if (hasWeatherData) {
      return '°${currentTemperature.value.toStringAsFixed(0)}';
    }
    return 'فعّل صلاحية الموقع';
  }

  // قيمة الرطوبة أو رسالة الخطأ
  String get humidityText {
    if (hasWeatherData) {
      return '${currentHumidity.value}%';
    }
    return 'فعّل صلاحية الموقع';
  }

  /// ترجمة حالة الطقس من الإنجليزية إلى العربية
  static const Map<String, String> _conditionToArabic = {
    'clear': 'صافي',
    'sunny': 'مشمس',
    'partly cloudy': 'غائم جزئياً',
    'cloudy': 'غائم',
    'overcast': 'غائم جداً',
    'mist': 'ضباب خفيف',
    'fog': 'ضباب',
    'patchy rain possible': 'أمطار متفرقة محتملة',
    'patchy light rain': 'أمطار خفيفة متفرقة',
    'light rain': 'أمطار خفيفة',
    'moderate rain': 'أمطار متوسطة',
    'heavy rain': 'أمطار غزيرة',
    'light snow': 'ثلج خفيف',
    'moderate snow': 'ثلج متوسط',
    'heavy snow': 'ثلج غزير',
    'patchy snow possible': 'ثلج متفرق محتمل',
    'thundery outbreaks possible': 'عواصف رعدية محتملة',
    'blowing snow': 'ثلج متطاير',
    'blizzard': 'عاصفة ثلجية',
    'freezing fog': 'ضباب متجمد',
    'patchy light drizzle': 'رذاذ خفيف متفرق',
    'light drizzle': 'رذاذ خفيف',
    'freezing drizzle': 'رذاذ متجمد',
    'heavy freezing drizzle': 'رذاذ متجمد غزير',
    'patchy freezing drizzle possible': 'رذاذ متجمد متفرق محتمل',
  };

  String get conditionTextArabic {
    if (!hasWeatherData || currentConditionText.value.isEmpty) return '—';
    final key = currentConditionText.value.trim().toLowerCase();
    return _conditionToArabic[key] ?? currentConditionText.value;
  }

  /// ترجمة اتجاه الرياح إلى العربية
  static const Map<String, String> _windDirToArabic = {
    'N': 'شمال',
    'NNE': 'شمال شمال شرق',
    'NE': 'شمال شرق',
    'ENE': 'شرق شمال شرق',
    'E': 'شرق',
    'ESE': 'شرق جنوب شرق',
    'SE': 'جنوب شرق',
    'SSE': 'جنوب جنوب شرق',
    'S': 'جنوب',
    'SSW': 'جنوب جنوب غرب',
    'SW': 'جنوب غرب',
    'WSW': 'غرب جنوب غرب',
    'W': 'غرب',
    'WNW': 'غرب شمال غرب',
    'NW': 'شمال غرب',
    'NNW': 'شمال شمال غرب',
  };

  String get windDirectionArabic {
    if (!hasWeatherData) return '—';
    final dir = currentWindDir.value.trim().toUpperCase();
    if (dir.isEmpty) return '—';
    return _windDirToArabic[dir] ?? dir;
  }

  /// وصف هطول الأمطار (نسبة/مستوى) بالعربية
  String get precipitationDescription {
    if (!hasWeatherData) return '—';
    final precip = currentPrecipitation.value;
    if (precip == 0) return 'لا أمطار';
    if (precip >= 0.1 && precip <= 2.5) return 'خفيفة';
    if (precip >= 2.6 && precip <= 7.5) return 'متوسطة';
    if (precip >= 7.6) return 'غزيرة';
    return 'لا أمطار';
  }
}
