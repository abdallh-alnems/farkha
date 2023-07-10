import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdController extends GetxController {
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  String adUnit = 'ca-app-pub-8595701567488603/1584158060';

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
        // ignore: avoid_print
        print(error);
      })),
      request: const AdRequest(),
    );
    bannerAd.load();
  }
}