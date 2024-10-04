import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../logic/controller/ad_controller/ad_banner_controller.dart';
import '../../../../logic/controller/ad_controller/ad_native_controller.dart';

class AdHomeBanner extends StatelessWidget {
  const AdHomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final adController = Get.find<AdBannerController>();

    return Obx(() => adController.isAdHomeLoaded.value
        ? SizedBox(
            height: adController.bannerAdHome.size.height.toDouble(),
            width: adController.bannerAdHome.size.width.toDouble(),
            child: AdWidget(ad: adController.bannerAdHome),
          )
        : const SizedBox());
  }
}
