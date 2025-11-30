import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GetMinVersionController extends GetxController {
  String minAppVersion = '';
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  bool get hasError => errorMessage.value.isNotEmpty;
  bool get isLoaded => minAppVersion.isNotEmpty && !isLoading.value;

  Future<void> fetchMinAppVersion() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot =
          await FirebaseFirestore.instance
              .collection('app_settings')
              .doc('min_version')
              .get();

      if (snapshot.exists && snapshot.data() != null) {
        minAppVersion = snapshot.get('version_info') ?? '';
        debugPrint('Min app version fetched: $minAppVersion');
      } else {
        minAppVersion = '1.0.0'; // إصدار افتراضي
        debugPrint('No version found, using default: $minAppVersion');
      }
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
