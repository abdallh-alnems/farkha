// import 'dart:developer';

// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'core/constant/id/ad_id.dart';

// class AdddController extends GetxController {
//   NativeAd? nativeAd;
//   bool isAdLoadedNative = false;
//   final String adUnitIdNative = "ca-app-pub-3940256099942544/2247696110";

//   late BannerAd bannerAd;
//   bool isAdLoaded = false;
//   String adUnitId = AdManager.bannerHome;

//   @override
//   void onInit() {
//     super.onInit();
//     initBannerAd();
//     loadAd();
//   }


//   loadAd() {
//     nativeAd = NativeAd(
//         adUnitId: adUnitIdNative,
//         listener: NativeAdListener(
//           onAdLoaded: (ad) {
//             isAdLoadedNative = true;
//             log("Ad Loaded");
//           },
//           onAdFailedToLoad: (ad, error) {
//             isAdLoadedNative = false;
//           },
//         ),
//         request: const AdRequest(),
//         nativeTemplateStyle:
//             NativeTemplateStyle(templateType: TemplateType.small));
//     nativeAd!.load();
//   }

//   initBannerAd() {
//     bannerAd = BannerAd(
//       size: AdSize.banner,
//       adUnitId: adUnitId,
//       listener: BannerAdListener(onAdLoaded: (ad) {
//         isAdLoaded = true;
//         update();
//       }, onAdFailedToLoad: ((ad, error) {
//         ad.dispose();
//       })),
//       request: const AdRequest(),
//     );
//     bannerAd.load();
//   }
// }
