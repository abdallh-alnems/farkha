import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/strings/app_strings.dart';
import '../../../data/data_source/static/onboarding_static.dart';
import '../../../logic/controller/onboarding_controller.dart';

class SkipButton extends GetView<OnBoardingControllerImp> {
  const SkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.h,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: 24.w, end: 24.w),
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Obx(() {
            if (controller.currentPage.value ==
                onBoardingList.length - 1) {
              return const SizedBox.shrink();
            }
            return GestureDetector(
              onTap: controller.skip,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Text(
                  AppStrings.skip,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.45),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
