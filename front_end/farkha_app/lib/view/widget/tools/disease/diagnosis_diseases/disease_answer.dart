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

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () {
                Get.offNamed<void>(AppRoute.diseaseDetails, arguments: disease);
              },
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.15),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'المرض : ',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      disease.name,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceElevatedColor
                    : AppColors.lightSurfaceColor,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkOutlineColor.withValues(alpha: 0.5)
                      : AppColors.lightOutlineColor.withValues(alpha: 0.3),
                ),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  childrenPadding: EdgeInsets.only(bottom: 8.h),
                  shape: const RoundedRectangleBorder(),
                  title: Text(
                    'تفاصيل الاجابات',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  children: answers.entries
                    .map(
                      (entry) => ListTile(
                        title: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
