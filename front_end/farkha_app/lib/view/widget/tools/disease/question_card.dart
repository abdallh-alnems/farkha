import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constant/routes/route.dart';
import '../../../../core/constant/theme/colors.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 11.h),
      decoration: BoxDecoration(
        color:
            isDark
                ? AppColors.darkSurfaceElevatedColor
                : AppColors.lightSurfaceColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow:
            isDark
                ? null
                : [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed<void>(AppRoute.questionDisease),
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
            child: Row(
              children: [
                Container(
                  width: 5.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تشخيص المرض',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'أجب عن الأسئلة لمعرفة المرض المحتمل',
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.35,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.85)
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
