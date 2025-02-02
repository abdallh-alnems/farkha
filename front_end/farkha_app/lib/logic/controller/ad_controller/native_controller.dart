import 'dart:developer';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/constant/id/ad_id.dart';

class AdNativeController extends GetxController {
  final List<NativeAd?> nativeAds = [null, null, null];
  final List<RxBool> isAdLoadedList = [false.obs, false.obs, false.obs];

  final List<String> adIds = [
    AdManager.nativeFirst,
    AdManager.nativeSecond,
    AdManager.nativeThird,
  ];

  @override
  void onInit() {
    super.onInit();
    _loadAllNativeAds();
  }

  @override
  void onClose() {
    for (var ad in nativeAds) {
      ad?.dispose();
    }
    super.onClose();
  }

  void _loadAllNativeAds() {
    for (int i = 0; i < adIds.length; i++) {
      _loadNativeAd(i);
    }
  }

  void loadAd(int index) {
    if (nativeAds[index] == null) {
      _loadNativeAd(index);
    }
  }

  void disposeAd(int index) {
    if (nativeAds[index] != null) {
      nativeAds[index]?.dispose();
      nativeAds[index] = null;
      isAdLoadedList[index].value = false;
    }
  }

  void _loadNativeAd(int index) {
    nativeAds[index] = NativeAd(
      adUnitId: adIds[index],
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          isAdLoadedList[index].value = true;
          log("Native Ad Loaded: $index");
          update();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isAdLoadedList[index].value = false;
          log("Native Ad Failed to Load: $index, Error: $error");
          Future.delayed(const Duration(seconds: 30), () {
            _loadNativeAd(index);
          });
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle:
          NativeTemplateStyle(templateType: TemplateType.medium),
    )..load();
  }
}
