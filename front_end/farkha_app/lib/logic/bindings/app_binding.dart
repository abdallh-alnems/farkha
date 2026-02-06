import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/class/crud.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // ================================ curd ===================================
    Get.put(Crud());

    // ================================ ads ====================================
    // ملاحظة: gma_mediation_meta يعمل تلقائياً من خلال dependency
    // لا حاجة لتهيئة إضافية - فقط تأكد من إضافة Facebook App ID في AndroidManifest.xml
    MobileAds.instance.initialize();
  }
}
