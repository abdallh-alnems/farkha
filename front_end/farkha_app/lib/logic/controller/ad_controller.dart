import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/constant/ad_id.dart';

class AdController extends GetxController {
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  String adUnit = AdManager.bannerHome;

  @override
  void onInit() {
    super.onInit();
    initBannerAd();
  }

  @override
  void onClose() {
    super.onClose();
    bannerAd.dispose();
  }

  initBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnit,
      listener: BannerAdListener(onAdLoaded: (ad) {
        isAdLoaded = true;
        update();
      }, onAdFailedToLoad: ((ad, error) {
        ad.dispose();
      })),
      request: const AdRequest(),
    );
    bannerAd.load();
  }
}