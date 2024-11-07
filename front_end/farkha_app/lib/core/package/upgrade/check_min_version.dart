import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MinVersionController extends GetxController {
  var minAppVersion = ''.obs;
  var showUpgradeMessage = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMinAppVersion();
  }

  Future<void> fetchMinAppVersion() async {
    
      final snapshot = await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('min_version')
          .get();
      if (snapshot.exists) {
        minAppVersion.value = snapshot.get('version_info');
        showUpgradeMessage.value = true; 
      }
    }
  }

