import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/constant/id/ad_id.dart';

class AdBannerController extends GetxController {
  late BannerAd bannerAdHome;
  late BannerAd bannerAdAll;

  RxBool isAdHomeLoaded = false.obs;
  RxBool isAdAllLoaded = false.obs;

  String adHomeId = AdManager.bannerHome;
  String adAllId = AdManager.bannerAll;

  @override
  void onInit() {
    super.onInit();
    bannerHomeAd();
    bannerAllAd();
  }

  // ============================== banner Home Ad =============================
  bannerHomeAd() {
    bannerAdHome = BannerAd(
      size: AdSize.banner,
      adUnitId: adHomeId,
      listener: BannerAdListener(onAdLoaded: (ad) {
        isAdHomeLoaded.value = true;
        update();
      }, onAdFailedToLoad: ((ad, error) {
        ad.dispose();
      })),
      request: const AdRequest(),
    );
    bannerAdHome.load();
  }

  // =============================== banner All Ad =============================
  bannerAllAd() {
    bannerAdAll = BannerAd(
      size: AdSize.banner,
      adUnitId: adAllId,
      listener: BannerAdListener(onAdLoaded: (ad) {
        isAdAllLoaded.value = true;
        update();
      }, onAdFailedToLoad: ((ad, error) {
        ad.dispose();
      })),
      request: const AdRequest(),
    );
    bannerAdAll.load();
  }
}
