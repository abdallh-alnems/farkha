import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../logic/controller/ad_controller/native_controller.dart';

class AdNativeWidget extends StatefulWidget {
  final int adIndex;

  const AdNativeWidget({super.key, required this.adIndex});

  @override
  State<AdNativeWidget> createState() => _AdNativeWidgetState();
}

class _AdNativeWidgetState extends State<AdNativeWidget> {
  late final AdNativeController adController;

  @override
  void initState() {
    super.initState();
    adController = Get.find<AdNativeController>();
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
      final nativeAd = adController.nativeAds[widget.adIndex];

      return isAdLoaded && nativeAd != null
          ? SizedBox(
              width: double.infinity,
              height: 350,
              child: AdWidget(ad: nativeAd),
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
