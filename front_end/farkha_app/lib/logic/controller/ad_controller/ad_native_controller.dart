import 'dart:developer';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/constant/id/ad_id.dart';

class AdNativeController extends GetxController {
  NativeAd? nativeAdHome;
  NativeAd? nativeAdAll;

  RxBool isAdHomeLoadedNative = false.obs;
  RxBool isAdAllLoadedNative = false.obs;

  final String adHomeIdNative = AdManager.nativeHome;
  final String adAllIdNative = AdManager.nativeAll;

  @override
  void onInit() {
    super.onInit();
    nativeHomeAd();
    nativeAllAd();
  }

  nativeHomeAd() {
    nativeAdHome = NativeAd(
        adUnitId: adHomeIdNative,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            isAdHomeLoadedNative.value = true;
            log("Ad Loaded");
          },
          onAdFailedToLoad: (ad, error) {
            isAdHomeLoadedNative.value = false;
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle:
            NativeTemplateStyle(templateType: TemplateType.small));
    nativeAdHome!.load();
  }

  nativeAllAd() {
    nativeAdAll = NativeAd(
        adUnitId: adAllIdNative,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            isAdAllLoadedNative.value = true;
            log("Ad Loaded");
          },
          onAdFailedToLoad: (ad, error) {
            isAdAllLoadedNative.value = false;
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle:
            NativeTemplateStyle(templateType: TemplateType.small));
    nativeAdAll!.load();
  }
}
