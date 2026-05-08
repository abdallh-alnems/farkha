import 'package:farkha_app/data/model/disease_model/disease_model.dart';
import 'package:farkha_app/data/model/disease_model/question_disease_model.dart';
import 'package:farkha_app/logic/controller/tools_controller/disease_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../helpers/test_harness.dart';

void main() {
  setUp(TestHarness.setUpGetx);
  tearDown(TestHarness.tearDownGetx);

  group('DiagnosisDiseasesController', () {
    late DiagnosisDiseasesController controller;

    setUp(() {
      controller = DiagnosisDiseasesController();
      Get.put<DiagnosisDiseasesController>(controller);
    });

    test('الحالة الابتدائية: الخطوة 0، لا أعراض', () {
      expect(controller.currentStep.value, 0);
      expect(controller.selectedSymptoms, isEmpty);
      expect(controller.answers, isEmpty);
    });

    test('canContinue = false بدون أعراض', () {
      expect(controller.canContinue, isFalse);
    });

    test('canContinue = true مع أعراض', () {
      controller.selectedSymptoms.add('سعال');

      expect(controller.canContinue, isTrue);
    });

    test('setAnswer يضيف إجابة', () {
      controller.setAnswer('respiratory', 'سعال');

      expect(controller.answers['respiratory'], 'سعال');
    });

    test('matchingScore يحسب نقاط التطابق', () {
      final disease = DiseaseModel(
        name: 'مرض تنفسي',
        criteria: {
          'respiratory': ['سعال', 'عطس'],
          'digestive': ['إسهال'],
        },
        treatment: [],
        prevention: [],
      );

      controller.setAnswer('respiratory', 'سعال');

      final score = controller.matchingScore(disease);

      expect(score, 1);
    });

    test('matchingScore = 0 بدون إجابات', () {
      final disease = DiseaseModel(
        name: 'مرض',
        criteria: {
          'respiratory': ['سعال'],
        },
        treatment: [],
        prevention: [],
      );

      expect(controller.matchingScore(disease), 0);
    });

    test('matchingScore = 2 مع تطابق كامل', () {
      final disease = DiseaseModel(
        name: 'مرض',
        criteria: {
          'respiratory': ['سعال'],
          'digestive': ['إسهال'],
        },
        treatment: [],
        prevention: [],
      );

      controller.setAnswer('respiratory', 'سعال');
      controller.setAnswer('digestive', 'إسهال');

      expect(controller.matchingScore(disease), 2);
    });

    test('computeDisease يُرجع "يجب اختيار اعراض" مع إجابات غير محددة فقط', () {
      controller.setAnswer('q1', 'غير محدد');
      controller.setAnswer('q2', 'لا توجد مشاكل');

      final result = controller.computeDisease();

      expect(result.name, contains('اختيار اعراض'));
    });

    test('updatedOptions يضيف "لا توجد مشاكل" و "غير محدد"', () {
      final options = controller.updatedOptions(['نعم', 'لا']);

      expect(options, containsAll(['نعم', 'لا', 'لا توجد مشاكل', 'غير محدد']));
    });

    test('updatedOptions لا يضيف مكرر', () {
      final options = controller.updatedOptions(['لا توجد مشاكل', 'نعم']);

      final count =
          options.where((o) => o == 'لا توجد مشاكل').length;
      expect(count, 1);
    });
  });
}
