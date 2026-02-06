import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class RemoteConfigController extends GetxController {
  String minAppVersion = '';
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  bool get hasError => errorMessage.value.isNotEmpty;
  bool get isLoaded => minAppVersion.isNotEmpty && !isLoading.value;

  Future<void> fetchMinAppVersion() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final remoteConfig = FirebaseRemoteConfig.instance;

      // ضبط إعدادات Remote Config
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 17),
          // تم ضبطها بـ 0 لضمان جلب البيانات بشكل فوري دائماً دون استخدام الكاش
          minimumFetchInterval: Duration.zero,
        ),
      );

      // تعيين القيم الافتراضية
      await remoteConfig.setDefaults(const {'min_version': '1.0.0'});

      // جلب البيانات وتفعيلها
      await remoteConfig.fetchAndActivate();

      // الحصول على قيمة min_version
      minAppVersion = remoteConfig.getString('min_version');

      if (minAppVersion.isEmpty) {
        minAppVersion = '1.0.0';
      }

      debugPrint('Min app version fetched from Remote Config: $minAppVersion');
    } catch (e) {
      errorMessage.value = 'فشل في جلب إصدار التطبيق: $e';
      minAppVersion = '1.0.0'; // إصدار افتراضي في حالة الخطأ
      debugPrint('Error fetching min version: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// إعادة محاولة جلب الإصدار
  Future<void> retryFetchVersion() async {
    await fetchMinAppVersion();
  }
}
