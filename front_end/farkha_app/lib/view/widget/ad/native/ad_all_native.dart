import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../logic/controller/ad_controller/ad_native_controller.dart';

class AdAllNative extends StatelessWidget {
  const AdAllNative({super.key});

  @override
  Widget build(BuildContext context) {
    final adController = Get.find<AdNativeController>();

    return Obx(() => Container(
          child: adController.isAdAllLoadedNative.value
              ? ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 100,
                    minHeight: 100,
                  ),
                  child: AdWidget(ad: adController.nativeAdAll!))
              : const SizedBox(),
        ));
  }
}
