import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../data/data_source/static/onboarding_static.dart';
import '../../../logic/controller/onboarding_controller.dart';

class CustomDotControllerOnBoarding extends GetView<OnBoardingControllerImp> {
  const CustomDotControllerOnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Obx(() {
      final current = controller.currentPage.value;
      return Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            onBoardingList.length,
            (index) => AnimatedContainer(
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              width: current == index ? 32.w : 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: current == index
                    ? activeColor
                    : activeColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
      );
    });
  }
}
