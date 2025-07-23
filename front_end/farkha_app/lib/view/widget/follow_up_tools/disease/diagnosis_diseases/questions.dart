import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constant/theme/color.dart';
import '../../../../../data/model/disease_model/question_disease_model.dart';
import '../../../../../logic/controller/follow_up_tools_controller/disease_controller.dart';

class QuestionStep extends StatelessWidget {
  final QuestionDiseaseModel question;
  final DiagnosisDiseasesController controller;

  const QuestionStep(
      {super.key, required this.question, required this.controller});

  @override
  Widget build(BuildContext context) {
    final options = controller.updatedOptions(question.options);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  question.name,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            GestureDetector(
              onTap: controller.previousStep,
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 25,
                color: AppColor.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 39),
        ...options.map(
          (option) => Obx(
            () => RadioListTile<String>(
              title: Text(
                option,
                textAlign: TextAlign.right,
              ),
              value: option,
              groupValue: controller.answers[question.name] ?? "",
              onChanged: (value) {
                if (value != null) {
                  controller.setAnswer(question.name, value);
                  Future.delayed(const Duration(milliseconds: 500), () {
                    controller.nextStep();
                  });
                }
              },
            ),
          ),
        )
      ],
    );
  }
}
