import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/constant/id/ad_id.dart';

class AdBannerController extends GetxController {
  // ================================ banner ad ================================

  late BannerAd bannerAdFirst;
  late BannerAd bannerAdSecond;
  late BannerAd bannerAdThird;

  // ================================= loading =================================

  RxBool isAdFirstLoaded = false.obs;
  RxBool isAdSecondLoaded = false.obs;
  RxBool isAdThirdLoaded = false.obs;

  // ================================== ad id ==================================

  String adFirstId = AdManager.bannerFirst;
  String adSecondId = AdManager.bannerSecond;
  String adThirdId = AdManager.bannerThird;

  @override
  void onInit() {
    super.onInit();
    bannerFirstAd();
    bannerSecondAd();
    bannerThirdAd();
  }

  // ============================== banner first Ad ============================

  bannerFirstAd() {
    bannerAdFirst = BannerAd(
      size: AdSize.banner,
      adUnitId: adFirstId,
      listener: BannerAdListener(onAdLoaded: (ad) {
        isAdFirstLoaded.value = true;
        update();
      }, onAdFailedToLoad: ((ad, error) {
        ad.dispose();
      })),
      request: const AdRequest(),
    );
    bannerAdFirst.load();
  }

  // ============================== banner second Ad ===========================

  bannerSecondAd() {
    bannerAdSecond = BannerAd(
      size: AdSize.banner,
      adUnitId: adSecondId,
      listener: BannerAdListener(onAdLoaded: (ad) {
        isAdSecondLoaded.value = true;
        update();
      }, onAdFailedToLoad: ((ad, error) {
        ad.dispose();
      })),
      request: const AdRequest(),
    );
    bannerAdSecond.load();
  }

  // ============================== banner third Ad ============================

  bannerThirdAd() {
    bannerAdThird = BannerAd(
      size: AdSize.banner,
      adUnitId: adThirdId,
      listener: BannerAdListener(onAdLoaded: (ad) {
        isAdThirdLoaded.value = true;
        update();
      }, onAdFailedToLoad: ((ad, error) {
        ad.dispose();
      })),
      request: const AdRequest(),
    );
    bannerAdThird.load();
  }
}
