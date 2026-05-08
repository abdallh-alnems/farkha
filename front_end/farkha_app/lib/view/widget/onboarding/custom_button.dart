import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/constant/theme/theme.dart' show AppElevation;
import '../../../data/data_source/static/onboarding_static.dart';
import '../../../logic/controller/onboarding_controller.dart';

class CustomButtonOnBoarding extends GetView<OnBoardingControllerImp> {
  const CustomButtonOnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Obx(() {
      final isLast =
          controller.currentPage.value == onBoardingList.length - 1;

      return Padding(
        padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 28.h),
        child: SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              elevation: AppElevation.sm,
              shadowColor: buttonColor.withValues(alpha: 0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.r),
              ),
            ),
            onPressed: controller.next,
            child: Text(
              isLast ? 'بدء' : 'متابعة',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    });
  }
}
