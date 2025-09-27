import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/color.dart';
import '../../../data/data_source/static/onboarding_static.dart';
import '../../../logic/controller/onboarding_controller.dart';

class SkipButton extends GetView<OnBoardingControllerImp> {
  const SkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child:
            controller.currentPage != onBoardingList.length - 1
                ? GestureDetector(
                  onTap: () {
                    controller.skip();
                  },
                  child: const Text(
                    'تخطي',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                : const SizedBox.shrink(),
      ),
    );
  }
}
