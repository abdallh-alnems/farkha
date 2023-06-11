import 'package:farkha_app/logic/controller/onboarding_controller.dart';
import 'package:farkha_app/view/widget/onboarding/customSlider.dart';
import 'package:farkha_app/view/widget/onboarding/custom_button.dart';
import 'package:farkha_app/view/widget/onboarding/dot_controller.dart';
import 'package:farkha_app/view/widget/onboarding/skip_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoarding extends StatelessWidget {
  const OnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OnboardingControllerImp());
    return Scaffold(
      
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(flex: 3, child: CustomSliderOnboarding()),
            Expanded(
              flex: 1,
              child: Column(
                children: const [
                  DotController(),
                  Spacer(
                    flex: 2,
                  ),
                  CustomButton(),
                  SkipButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


