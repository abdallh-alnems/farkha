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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
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
          child: SizedBox(
            height: 52.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 36.w),
                    child: Text(
                      question.name,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: controller.previousStep,
                      child: Transform.scale(
                        scaleX: -1,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 22.sp,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Obx(
          () => Container(
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
