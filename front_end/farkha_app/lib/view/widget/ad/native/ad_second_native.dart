import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../logic/controller/ad_controller/ad_native_controller.dart';

class AdSecondNative extends StatelessWidget {
  const AdSecondNative({super.key});

  @override
  Widget build(BuildContext context) {
    final adController = Get.find<AdNativeController>();

    return Obx(() => Padding(
          padding: const EdgeInsets.only(bottom: 7).r,
          child: Container(
            child: adController.isAdSecondLoadedNative.value
                ? ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 100,
                      minHeight: 100,
                    ),
                    child: AdWidget(ad: adController.nativeAdSecond!))
                : const SizedBox(),
          ),
        ));
  }
}
