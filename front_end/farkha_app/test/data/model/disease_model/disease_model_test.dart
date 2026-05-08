import 'package:farkha_app/data/model/disease_model/disease_model.dart';
import 'package:farkha_app/data/model/disease_model/question_disease_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiseaseModel', () {
    test('يُنشئ كائن بالحقول المطلوبة', () {
      final disease = DiseaseModel(
        name: 'نيوكاسل',
        criteria: {
          'respiratory': ['سعال', 'عطس'],
        },
        treatment: ['عزل', 'مضاد حيوي'],
        prevention: ['تحصين', 'نظافة'],
      );

      expect(disease.name, 'نيوكاسل');
      expect(disease.criteria['respiratory'], ['سعال', 'عطس']);
      expect(disease.treatment, ['عزل', 'مضاد حيوي']);
      expect(disease.prevention, ['تحصين', 'نظافة']);
    });

    test('criteria يمكن أن يكون فارغاً', () {
      final disease = DiseaseModel(
        name: 'غير محدد',
        criteria: {},
        treatment: [],
        prevention: [],
      );

      expect(disease.criteria, isEmpty);
      expect(disease.treatment, isEmpty);
    });
  });

  group('QuestionDiseaseModel', () {
    test('يُنشئ كائن بالحقول المطلوبة', () {
      final question = QuestionDiseaseModel(
        name: 'respiratory',
        options: ['سعال', 'عطس', 'لا توجد مشاكل'],
        symptoms: ['سعال'],
      );

      expect(question.name, 'respiratory');
      expect(question.options, ['سعال', 'عطس', 'لا توجد مشاكل']);
      expect(question.symptoms, ['سعال']);
    });

    test('symptoms الافتراضي فارغ', () {
      final question = QuestionDiseaseModel(
        name: 'general',
        options: ['نعم', 'لا'],
      );

      expect(question.symptoms, isEmpty);
    });
  });
}
