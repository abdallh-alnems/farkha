import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/tool_ids.dart';
import '../../../data/data_source/static/disease/disease_data.dart';
import '../../../data/data_source/static/disease/question_disease_data.dart';
import '../../../data/model/disease_model/disease_model.dart';
import '../../../data/model/disease_model/question_disease_model.dart';
import '../tool_usage_controller.dart';

class DiagnosisDiseasesController extends GetxController {
  static const int toolId = ToolIds.diseases; // Diseases tool ID = 12

  var currentStep = 0.obs;
  var selectedSymptoms = <String>[].obs;
  var answers = <String, String>{}.obs;
  PageController pageController = PageController();

  void nextStep() {
    if (currentStep.value < filteredQuestions.length + 1) {
      currentStep.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;

      int newCurrentQuestionIndex = currentStep.value - 1;

      if (newCurrentQuestionIndex < 0) {
        for (var question in filteredQuestions) {
          answers.remove(question.name);
        }
      } else {
        for (
          int i = newCurrentQuestionIndex;
          i < filteredQuestions.length;
          i++
        ) {
          answers.remove(filteredQuestions[i].name);
        }
      }

      answers.refresh();

      pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void setAnswer(String key, String value) {
    answers[key] = value;
  }

  bool get canContinue => selectedSymptoms.isNotEmpty;

  List<QuestionDiseaseModel> get filteredQuestions {
    return questionsDiseases.where((q) {
      if (q.symptoms.isEmpty) return true;
      return selectedSymptoms.any((symptom) => q.symptoms.contains(symptom));
    }).toList();
  }

  int get currentQuestionIndex => currentStep.value - 1;

  QuestionDiseaseModel get currentQuestion =>
      filteredQuestions[currentQuestionIndex];

  bool get isFinal => currentQuestionIndex == filteredQuestions.length - 1;

  List<String> updatedOptions(List<String> options) {
    List<String> updated = List<String>.from(options);
    if (!updated.contains("لا توجد مشاكل")) {
      updated.add("لا توجد مشاكل");
    }
    if (!updated.contains("غير محدد")) {
      updated.add("غير محدد");
    }
    return updated;
  }

  int matchingScore(DiseaseModel disease) {
    int score = 0;
    for (final entry in disease.criteria.entries) {
      final question = entry.key;
      final allowedAnswers = entry.value;
      if (answers.containsKey(question) &&
          allowedAnswers.contains(answers[question])) {
        score++;
      }
    }
    return score;
  }

  DiseaseModel computeDisease() {
    bool allAnswersInvalid = answers.values.every(
      (answer) => answer == "غير محدد" || answer == "لا توجد مشاكل",
    );

    if (allAnswersInvalid) {
      return DiseaseModel(
        name: "! يجب اختيار اعراض",
        criteria: {},
        treatment: [],
        prevention: [],
      );
    }

    DiseaseModel? bestMatch;
    int maxScore = -1;
    for (final disease in diseases) {
      int score = matchingScore(disease);
      if (score > maxScore) {
        maxScore = score;
        bestMatch = disease;
      }
    }

    return bestMatch ??
        DiseaseModel(
          name: "نتيجة غير محددة",
          criteria: {},
          treatment: [],
          prevention: [],
        );
  }

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }
}
