import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../../../logic/controller/ad_controller/ad_native_controller.dart';

class AdThirdNative extends StatelessWidget {
  const AdThirdNative({super.key});

  @override
  Widget build(BuildContext context) {
    final adController = Get.find<AdNativeController>();

    return Obx(() => Padding(
          padding: const EdgeInsets.only(bottom: 11).r,
          child: Container(
            child: adController.isAdThirdLoadedNative.value
                ? ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 100,
                      minHeight: 100,
                    ),
                    child: AdWidget(ad: adController.nativeAdThird!))
                : const SizedBox(),
          ),
        ));
  }
}
