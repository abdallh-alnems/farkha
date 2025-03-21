import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/constant/id/ad_id.dart';

class AdBannerController extends GetxController {
  final List<BannerAd?> bannerAds = [null, null, null];
  final List<RxBool> isAdLoadedList = [false.obs, false.obs, false.obs];

  final List<String> adIds = [
    AdManager.bannerFirst,
    AdManager.bannerSecond,
    AdManager.bannerThird,
  ];

  @override
  void onClose() {
    for (var ad in bannerAds) {
      ad?.dispose();
    }
    super.onClose();
  }

  void loadAd(int index) {
    if (bannerAds[index] == null) {
      _loadBannerAd(index);
    }
  }

  void disposeAd(int index) {
    if (bannerAds[index] != null) {
      bannerAds[index]?.dispose();
      bannerAds[index] = null;
      isAdLoadedList[index].value = false;
    }
  }

  void _loadBannerAd(int index) {
    bannerAds[index] = BannerAd(
      size: AdSize.banner,
      adUnitId: adIds[index],
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isAdLoadedList[index].value = true;
          update();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          Future.delayed(const Duration(seconds: 30), () {
            _loadBannerAd(index);
          });
        },
      ),
      request: const AdRequest(),
    )..load();
  }
}
