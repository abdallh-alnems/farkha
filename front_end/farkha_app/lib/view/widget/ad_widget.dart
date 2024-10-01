import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../logic/controller/ad_controller.dart';

class AdmobHome extends StatelessWidget {
  const AdmobHome({super.key});

  @override
  Widget build(BuildContext context) {
        final adController = Get.find<AdController>();

    return GetBuilder<AdController>(builder: (_) {
      return adController.isAdLoaded
          ? SizedBox(
              height: adController.bannerAd.size.height.toDouble(),
              width: adController.bannerAd.size.width.toDouble(),
              child: AdWidget(ad: adController.bannerAd),
            )
          : const SizedBox();
    });
  }
}
