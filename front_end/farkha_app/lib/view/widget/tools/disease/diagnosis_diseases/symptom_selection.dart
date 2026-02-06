import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/constant/theme/colors.dart';
import '../../../../../data/data_source/static/disease/symptoms_data.dart';
import '../../../../../logic/controller/tools_controller/disease_controller.dart';

class SymptomSelection extends StatelessWidget {
  const SymptomSelection({super.key, required this.controller});

  final DiagnosisDiseasesController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'اختر الأعراض',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 12.h),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: ListView(
              children: symptoms.map((symptom) {
                return Obx(() => CheckboxListTile(
                      title: Text(
                        symptom,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      value: controller.selectedSymptoms.contains(symptom),
                      onChanged: (value) {
                        if (value == true) {
                          controller.selectedSymptoms.add(symptom);
                        } else {
                          controller.selectedSymptoms.remove(symptom);
                        }
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: primaryColor,
                    ));
              }).toList(),
            ),
          ),
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
              child: Text(
                'التالي',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
