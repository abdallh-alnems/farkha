import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../logic/controller/ad_controller/ad_banner_controller.dart';
import '../../../../logic/controller/ad_controller/ad_native_controller.dart';

class AdFirstBanner extends StatelessWidget {
  const AdFirstBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final adController = Get.find<AdBannerController>();

    return Obx(() => adController.isAdFirstLoaded.value
        ? SizedBox(
            height: adController.bannerAdFirst.size.height.toDouble(),
            width: adController.bannerAdFirst.size.width.toDouble(),
            child: AdWidget(ad: adController.bannerAdFirst),
          )
        : const SizedBox());
  }
}
