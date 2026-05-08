import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/constant/theme/colors.dart';
import '../../../../../data/model/disease_model/question_disease_model.dart';
import '../../../../../logic/controller/tools_controller/disease_controller.dart';

class QuestionStep extends StatelessWidget {
  const QuestionStep({
    super.key,
    required this.question,
    required this.controller,
  });

  final QuestionDiseaseModel question;
  final DiagnosisDiseasesController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
    final options = controller.updatedOptions(question.options);

    final surfaceColor = isDark
        ? AppColors.darkSurfaceElevatedColor
        : AppColors.lightSurfaceColor;
    final borderColor = isDark
        ? AppColors.darkOutlineColor.withValues(alpha: 0.5)
        : AppColors.lightOutlineColor.withValues(alpha: 0.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsetsDirectional.fromSTEB(14.w, 14.h, 14.w, 14.h),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: borderColor),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: controller.previousStep,
                child: Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 16.sp,
                    color: primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  question.name,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(width: 38.w),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: borderColor),
            ),
            child: RadioGroup<String>(
              groupValue: controller.answers[question.name] ?? '',
              onChanged: (value) {
                if (value != null) {
                  controller.setAnswer(question.name, value);
                  Future.delayed(const Duration(milliseconds: 500), () {
                    controller.nextStep();
                  });
                }
              },
              child: Column(
                children: options
                    .map(
                      (option) => RadioListTile<String>(
                        title: Text(
                          option,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        value: option,
                        activeColor: primaryColor,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
