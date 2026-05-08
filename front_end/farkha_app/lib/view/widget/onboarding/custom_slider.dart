import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../data/data_source/static/onboarding_static.dart';
import '../../../logic/controller/onboarding_controller.dart';

const _pageAccents = [
  AppColors.accentColor,
  AppColors.secondaryColor,
  AppColors.primaryColor,
];

class CustomSliderOnBoarding extends GetView<OnBoardingControllerImp> {
  const CustomSliderOnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PageView.builder(
      controller: controller.pageController,
      onPageChanged: controller.onPageChanged,
      itemCount: onBoardingList.length,
      itemBuilder: (context, i) {
        final accent = _pageAccents[i];

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            children: [
              SizedBox(height: 16.h),
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 280.w,
                        height: 280.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: isDark ? 0.04 : 0.05),
                        ),
                      ),
                      Container(
                        width: 210.w,
                        height: 210.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: isDark ? 0.06 : 0.08),
                        ),
                      ),
                      Hero(
                        tag: 'onboarding_$i',
                        child: SvgPicture.asset(
                          onBoardingList[i].image!,
                          width: 220.w,
                          height: 220.w,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 36.h),
              Text(
                onBoardingList[i].title!,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkPrimaryColor
                      : AppColors.primaryColor,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 14.h),
              Text(
                onBoardingList[i].body!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? const Color(0xFFA09888)
                      : const Color(0xFF5A564C),
                  height: 1.7,
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }
}
