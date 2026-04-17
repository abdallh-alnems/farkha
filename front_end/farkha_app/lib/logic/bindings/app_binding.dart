import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/class/crud.dart';
import '../../view/widget/ad/interstitial.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // ================================ curd ===================================
    Get.put(Crud());

    // ================================ ads ====================================
    MobileAds.instance.initialize().then((_) {
      // تحميل الإعلان البيني بعد تهيئة AdMob مباشرة
      InterstitialAdService.instance.load();
    });
  }
}
