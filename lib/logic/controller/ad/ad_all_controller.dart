import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdAllController extends GetxController {
  late BannerAd bannerAdAll;
  bool isAdLoaded = false;
  String adUnit = 'ca-app-pub-8595701567488603/1751748833';

  @override
  void onInit() {
    super.onInit();
    initBannerAdAll();
  }

  @override
  void onClose() {
    super.onClose();
    bannerAdAll.dispose();
  }

  initBannerAdAll() {
    bannerAdAll = BannerAd(
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
    bannerAdAll.load();
  }
}