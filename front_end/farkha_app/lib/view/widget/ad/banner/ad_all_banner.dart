import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../logic/controller/ad_controller/ad_banner_controller.dart';

class AdAllBanner extends StatelessWidget {
  const AdAllBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final adController = Get.find<AdBannerController>();

    return Obx(() => adController.isAdAllLoaded.value
        ? SizedBox(
            height: adController.bannerAdAll.size.height.toDouble(),
            width: adController.bannerAdAll.size.width.toDouble(),
            child: AdWidget(ad: adController.bannerAdAll),
          )
        : const SizedBox());
  }
}
