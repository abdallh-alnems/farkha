import 'dart:developer';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/constant/id/ad_id.dart';

class AdNativeController extends GetxController {
  // ================================ banner ad ================================

  NativeAd? nativeAdFirst;
  NativeAd? nativeAdSecond;
  NativeAd? nativeAdThird;

  // ================================= loading =================================

  RxBool isAdFirstLoadedNative = false.obs;
  RxBool isAdSecondLoadedNative = false.obs;
  RxBool isAdThirdLoadedNative = false.obs;

  // ================================== ad id ==================================

  final String adFirstIdNative = AdManager.nativeFirst;
  final String adSecondIdNative = AdManager.nativeSecond;
  final String adThirdIdNative = AdManager.nativeThird;

  @override
  void onInit() {
    super.onInit();
    nativeFirstAd();
    nativeSecondAd();
    nativeThirdAd();
  }

  // ============================== native first Ad ============================

  nativeFirstAd() {
    nativeAdFirst = NativeAd(
        adUnitId: adFirstIdNative,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            isAdFirstLoadedNative.value = true;
            log("Ad Loaded");
          },
          onAdFailedToLoad: (ad, error) {
            isAdFirstLoadedNative.value = false;
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle:
            NativeTemplateStyle(templateType: TemplateType.small));
    nativeAdFirst!.load();
  }

  // ============================== native second Ad ============================

  nativeSecondAd() {
    nativeAdSecond = NativeAd(
        adUnitId: adSecondIdNative,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            isAdSecondLoadedNative.value = true;
            log("Ad Loaded");
          },
          onAdFailedToLoad: (ad, error) {
            isAdSecondLoadedNative.value = false;
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle:
            NativeTemplateStyle(templateType: TemplateType.small));
    nativeAdSecond!.load();
  }

  // ============================== native third Ad ============================

  nativeThirdAd() {
    nativeAdThird = NativeAd(
        adUnitId: adThirdIdNative,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            isAdThirdLoadedNative.value = true;
            log("Ad Loaded");
          },
          onAdFailedToLoad: (ad, error) {
            isAdThirdLoadedNative.value = false;
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle:
            NativeTemplateStyle(templateType: TemplateType.small));
    nativeAdThird!.load();
  }
}
