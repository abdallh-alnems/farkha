import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../logic/controller/onboarding_controller.dart';
import '../widget/onboarding/custom_button.dart';
import '../widget/onboarding/custom_slider.dart';
import '../widget/onboarding/dot_controller.dart';
import '../widget/onboarding/skip_button.dart';

class OnBoarding extends StatelessWidget {
  const OnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OnBoardingControllerImp());
    return GetBuilder<OnBoardingControllerImp>(
      builder: (_) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const SafeArea(
              child: Column(
                children: [
                  SkipButton(),
                  Expanded(child: CustomSliderOnBoarding()),
                  CustomDotControllerOnBoarding(),
                  CustomButtonOnBoarding(),
                ],
              ),
            ),
          ),
    );
  }
}
