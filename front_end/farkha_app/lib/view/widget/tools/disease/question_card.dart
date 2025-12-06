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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color:
            isDark
                ? AppColors.darkSurfaceElevatedColor
                : AppColors.lightSurfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isDark
                  ? AppColors.darkOutlineColor.withValues(alpha: 0.5)
                  : AppColors.lightOutlineColor.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow:
            isDark
                ? null
                : [
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
          onTap: () => Get.toNamed(AppRoute.questionDisease),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Row(
              children: [
                // Accent Line
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 14),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "تشخيص المرض",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "أجب عن الأسئلة لمعرفة المرض المحتمل",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? Colors.white60 : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
