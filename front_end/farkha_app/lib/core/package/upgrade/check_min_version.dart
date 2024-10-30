import 'package:farkha_app/core/package/upgrade/messages.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:upgrader/upgrader.dart';

class MinVersionController extends GetxController {
  var minAppVersion = ''.obs;
  var showUpgradeMessage = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMinAppVersion();
  }

  Future<void> fetchMinAppVersion() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('min_version')
          .get();
      if (snapshot.exists) {
        minAppVersion.value = snapshot.get('version_info');
        showUpgradeMessage.value = true; // تحديث حالة الرسالة هنا
      }
    } catch (e) {
      print('خطأ في جلب الإصدار الأدنى: $e');
    }
  }
}
