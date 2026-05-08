import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constant/theme/colors.dart';
import '../../../../logic/controller/tools_controller/disease_controller.dart';
import '../../../widget/appbar/custom_appbar.dart';
import '../../../widget/tools/disease/diagnosis_diseases/disease_answer.dart';
import '../../../widget/tools/disease/diagnosis_diseases/questions.dart';
import '../../../widget/tools/disease/diagnosis_diseases/symptom_selection.dart';

class DiagnosisDiseases extends StatelessWidget {
  DiagnosisDiseases({super.key});

  final DiagnosisDiseasesController controller = Get.put(
    DiagnosisDiseasesController(),
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: 'تشخيص المرض'),
          Obx(() {
            final totalSteps = controller.filteredQuestions.length + 2;
            return _StepIndicator(
              currentStep: controller.currentStep.value,
              totalSteps: totalSteps,
              color: primaryColor,
            );
          }),
          Expanded(
            child: SafeArea(
              child: Obx(() {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 20.w,
                  ),
                  child: PageView(
                    controller: controller.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      SymptomSelection(controller: controller),
                      ...controller.filteredQuestions.map(
                        (question) => QuestionStep(
                          question: question,
                          controller: controller,
                        ),
                      ),
                      buildDiseaseAnswer(
                        controller.computeDisease(),
                        controller.answers,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.color,
  });

  final int currentStep;
  final int totalSteps;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? AppColors.darkOutlineColor.withValues(alpha: 0.5)
        : AppColors.lightOutlineColor.withValues(alpha: 0.4);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index <= currentStep;
          final isCurrent = index == currentStep;
          return Expanded(
            child: Container(
              height: isCurrent ? 4.h : 3.h,
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: isActive ? color : trackColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }),
      ),
    );
  }
}
