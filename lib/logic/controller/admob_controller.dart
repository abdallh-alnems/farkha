// // ignore_for_file: unnecessary_overrides

// import 'package:farkha_app/service/ads_service.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// class GetBannerAd extends GetxController {
//   late BannerAd bannerAd;
//   bool isBannerAdRed = false;

//   @override
//   void onInit() {
//     super.onInit();
//     initBanner();
//   }

//   initBanner() {
//     bannerAd = BannerAd(
//       size: AdSize.banner,
//       adUnitId: AdsService.bannerAdID,
//       listener: BannerAdListener(
//         onAdLoaded: (ad) {
//           isBannerAdRed = true;
//           update();
//         },
//         onAdFailedToLoad: (ad, error) {
//           isBannerAdRed = false;
//           update();
//         },
//       ),
//       request: AdRequest(),
//     );
//     bannerAd.load();
//   }

//   Widget bannerWidget() {
//     if (isBannerAdRed) {
//       return Container(
//         width: bannerAd.size.width.toDouble(),
//         height: bannerAd.size.width.toDouble(),
//         margin: EdgeInsets.all(10),
//         child: AdWidget(
//           ad: bannerAd,
//         ),
//       );
//     } else {
//       return Container();
//     }
//   }
// }
