import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/constant/routes/route.dart';
import '../../../../../core/constant/theme/colors.dart';
import '../../../../../data/model/disease_model/disease_model.dart';

Widget buildDiseaseAnswer(
  DiseaseModel disease,
  Map<String, String> answers,
) {
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final colorScheme = Theme.of(context).colorScheme;
      final primaryColor =
          isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
      final accentColor =
          isDark ? AppColors.accentLight : AppColors.accentColor;

      final surfaceColor = isDark
          ? AppColors.darkSurfaceElevatedColor
          : AppColors.lightSurfaceColor;
      final borderColor = isDark
          ? AppColors.darkOutlineColor.withValues(alpha: 0.5)
          : AppColors.lightOutlineColor.withValues(alpha: 0.3);

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'نتيجة التشخيص',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  InkWell(
                    onTap: () {
                      Get.offNamed<void>(
                        AppRoute.diseaseDetails,
                        arguments: disease,
                      );
                    },
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              disease.name,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: accentColor,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14.sp,
                            color: accentColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'اضغط على اسم المرض لعرض التفاصيل',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: borderColor),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  tilePadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  childrenPadding: EdgeInsetsDirectional.only(
                    bottom: 8.h,
                    start: 16.w,
                    end: 16.w,
                  ),
                  shape: const RoundedRectangleBorder(),
                  title: Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 20.sp,
                        color: primaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'تفاصيل الإجابات',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  children: answers.entries.map((entry) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
