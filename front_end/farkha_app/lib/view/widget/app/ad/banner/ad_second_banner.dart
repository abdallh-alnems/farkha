import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../../../logic/controller/ad_controller/ad_banner_controller.dart';

class AdSecondBanner extends StatelessWidget {
  const AdSecondBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final adController = Get.find<AdBannerController>();

    return Obx(() => adController.isAdSecondLoaded.value
        ? SizedBox(
            height: adController.bannerAdSecond.size.height.toDouble(),
            width: adController.bannerAdSecond.size.width.toDouble(),
            child: AdWidget(ad: adController.bannerAdSecond),
          )
        : const SizedBox());
  }
}
