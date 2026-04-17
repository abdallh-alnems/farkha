import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constant/routes/route.dart';
import '../../core/services/initialization.dart';
import '../../logic/controller/onboarding_controller.dart';
import '../widget/onboarding/custom_button.dart';
import '../widget/onboarding/custom_slider.dart';
import '../widget/onboarding/dot_controller.dart';
import '../widget/onboarding/skip_button.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final myServices = Get.find<MyServices>();
      final pending = myServices.getStorage.read<Map<dynamic, dynamic>>(
        'pending_darkness_alarm',
      );
      if (pending != null && mounted) {
        myServices.getStorage.remove('pending_darkness_alarm');
        final args = Map<String, dynamic>.from(
          pending.map((k, v) => MapEntry(k.toString(), v)),
        );
        args['fromBackground'] = true;
        Get.toNamed<void>(AppRoute.darknessAlarm, arguments: args);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Get.put(OnBoardingControllerImp());
    return GetBuilder<OnBoardingControllerImp>(
      builder:
          (_) => Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: const SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
          ),
    );
  }
}
