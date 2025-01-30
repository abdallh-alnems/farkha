import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../../logic/controller/ad_controller/native_controller.dart';

class AdFirstNative extends StatelessWidget {
  const AdFirstNative({super.key});

  @override
  Widget build(BuildContext context) {
    final adController = Get.find<AdNativeController>();

    return Obx(() => Container(
          child: adController.isAdFirstLoadedNative.value
              ? ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 100,
                    minHeight: 100,
                  ),
                  child: AdWidget(ad: adController.nativeAdFirst!))
              : const SizedBox(),
        ));
  }
}
