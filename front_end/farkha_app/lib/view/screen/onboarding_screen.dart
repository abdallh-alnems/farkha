import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constant/routes/route.dart';
import '../../core/constant/storage_keys.dart';
import '../../core/constant/theme/colors.dart';
import '../../core/services/initialization.dart';
import '../../logic/controller/onboarding_controller.dart';
import '../widget/onboarding/custom_button.dart';
import '../widget/onboarding/custom_slider.dart';
import '../widget/onboarding/dot_controller.dart';
import '../widget/onboarding/skip_button.dart';

const _pageAccents = [
  AppColors.accentColor,
  AppColors.secondaryColor,
  AppColors.primaryColor,
];

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
        StorageKeys.pendingDarknessAlarm,
      );
      if (pending != null && mounted) {
        myServices.getStorage.remove(StorageKeys.pendingDarknessAlarm);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GetBuilder<OnBoardingControllerImp>(
      builder: (controller) {
        final page = controller.currentPage.value.clamp(0, _pageAccents.length - 1);
        final accent = _pageAccents[page];

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.4),
                      radius: 1.1,
                      colors: [
                        accent.withValues(alpha: isDark ? 0.06 : 0.05),
                        accent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                const Column(
                  children: [
                    SkipButton(),
                    Expanded(child: CustomSliderOnBoarding()),
                    CustomDotControllerOnBoarding(),
                    CustomButtonOnBoarding(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
