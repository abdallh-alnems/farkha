import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../logic/controller/tools_controller/disease_controller.dart';
import '../../../widget/appbar/custom_appbar.dart';
import '../../../widget/tools/disease/diagnosis_diseases/disease_answer.dart';
import '../../../widget/tools/disease/diagnosis_diseases/questions.dart';
import '../../../widget/tools/disease/diagnosis_diseases/symptom_selection.dart';

class DiagnosisDiseases extends StatelessWidget {
  final DiagnosisDiseasesController controller = Get.put(
    DiagnosisDiseasesController(),
  );

  DiagnosisDiseases({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: "تشخيص المرض"),
          Expanded(
            child: Obx(() {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 55,
                  horizontal: 17,
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
        ],
      ),
    );
  }
}
