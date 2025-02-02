import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../logic/controller/ad_controller/banner_controller.dart';

class AdBannerWidget extends StatefulWidget {
  final int adIndex;

  const AdBannerWidget({super.key, required this.adIndex});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  late final AdBannerController adController;

  @override
  void initState() {
    super.initState();
    adController = Get.find<AdBannerController>();
    _loadAdIfNeeded();
  }

  @override
  void dispose() {
    _disposeAdIfNeeded();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isAdLoaded = adController.isAdLoadedList[widget.adIndex].value;
      final bannerAd = adController.bannerAds[widget.adIndex];

      return isAdLoaded && bannerAd != null
          ? SizedBox(
              height: bannerAd.size.height.toDouble(),
              width: double.infinity,
              child: AdWidget(ad: bannerAd),
            )
          : const SizedBox();
    });
  }

  void _loadAdIfNeeded() {
    if (widget.adIndex >= 0 && widget.adIndex < adController.adIds.length) {
      adController.loadAd(widget.adIndex);
    }
  }

  void _disposeAdIfNeeded() {
    if (widget.adIndex >= 0 && widget.adIndex < adController.adIds.length) {
      adController.disposeAd(widget.adIndex);
    }
  }
}
