import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../logic/controller/ad_controller/ad_banner_controller.dart';

class AdThirdBanner extends StatelessWidget {
  const AdThirdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final adController = Get.find<AdBannerController>();

    return Obx(() => adController.isAdThirdLoaded.value
        ? SizedBox(
            height: adController.bannerAdThird.size.height.toDouble(),
            width: adController.bannerAdThird.size.width.toDouble(),
            child: AdWidget(ad: adController.bannerAdThird),
          )
        : const SizedBox());
  }
}
