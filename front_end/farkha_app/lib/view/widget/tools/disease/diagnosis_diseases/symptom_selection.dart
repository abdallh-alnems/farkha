import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/constant/theme/colors.dart';
import '../../../../../data/data_source/static/disease/symptoms_data.dart';
import '../../../../../logic/controller/tools_controller/disease_controller.dart';

class SymptomSelection extends StatelessWidget {
  const SymptomSelection({super.key, required this.controller});

  final DiagnosisDiseasesController controller;

  static const _symptomIcons = <String, IconData>{
    'اعاقة حركية': Icons.accessibility_new_outlined,
    'نقص نمو': Icons.trending_down_outlined,
    'اعراض معوية': Icons.sick_outlined,
    'اعراض عصبية': Icons.psychology_outlined,
    'اعراض تنفسية': Icons.air_outlined,
    'نفوق': Icons.warning_amber_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(bottom: 8.h),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.list_alt_outlined,
                  size: 20.sp,
                  color: primaryColor,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'اختر الأعراض التي تلاحظها',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'تحديد أكثر من عرض يُحسّن دقة التشخيص',
          style: TextStyle(
            fontSize: 13.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.55),
            height: 1.3,
          ),
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: Obx(() {
            return ListView(
              children: symptoms.map((symptom) {
                final isSelected =
                    controller.selectedSymptoms.contains(symptom);
                final icon = _symptomIcons[symptom] ?? Icons.healing_outlined;

                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (isSelected) {
                          controller.selectedSymptoms.remove(symptom);
                        } else {
                          controller.selectedSymptoms.add(symptom);
                        }
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor.withValues(
                                  alpha: isDark ? 0.2 : 0.08,
                                )
                              : (isDark
                                  ? AppColors.darkSurfaceElevatedColor
                                  : AppColors.lightSurfaceColor),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor.withValues(alpha: 0.5)
                                : (isDark
                                    ? AppColors.darkOutlineColor
                                        .withValues(alpha: 0.5)
                                    : AppColors.lightOutlineColor
                                        .withValues(alpha: 0.3)),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              size: 22.sp,
                              color: isSelected
                                  ? primaryColor
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                symptom,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? primaryColor
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ),
                            AnimatedScale(
                              scale: isSelected ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 150),
                              child: Icon(
                                Icons.check_circle,
                                size: 22.sp,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          child: Obx(() {
            final enabled = controller.canContinue;
            return FilledButton(
              onPressed: enabled ? controller.nextStep : null,
              style: FilledButton.styleFrom(
                backgroundColor: enabled
                    ? primaryColor
                    : (isDark
                        ? Colors.grey.withValues(alpha: 0.35)
                        : Colors.grey.shade300),
                foregroundColor: enabled
                    ? (isDark ? AppColors.darkBackGroundColor : Colors.white)
                    : (isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'التالي',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_back_ios_new, size: 14.sp),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
