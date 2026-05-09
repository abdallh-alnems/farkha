import 'package:farkha_app/data/model/vaccination_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VaccinationModel', () {
    test('fromJson يُنشئ كائن صحيح', () {
      final json = {
        'age': 7,
        'vaccine_name': 'لقاح B1',
        'notes': 'جرعة شرب',
        'is_completed': true,
      };

      final model = VaccinationModel.fromJson(json);

      expect(model.age, 7);
      expect(model.vaccineName, 'لقاح B1');
      expect(model.notes, 'جرعة شرب');
      expect(model.isCompleted, true);
    });

    test('fromJson الافتراضي is_completed = false', () {
      final json = {
        'age': 13,
        'vaccine_name': 'جمبورو',
        'notes': 'ماء الشرب',
      };

      final model = VaccinationModel.fromJson(json);

      expect(model.isCompleted, false);
    });

    test('toJson يُرجع خريطة صحيحة', () {
      const model = VaccinationModel(
        age: 7,
        vaccineName: 'لقاح B1',
        notes: 'جرعة شرب',
      );

      final json = model.toJson();

      expect(json['age'], 7);
      expect(json['vaccine_name'], 'لقاح B1');
      expect(json['notes'], 'جرعة شرب');
      expect(json['is_completed'], false);
    });

    test('const constructor يعمل', () {
      const model = VaccinationModel(
        age: 28,
        vaccineName: 'لاسوتا',
        notes: 'ماء الشرب',
      );

      expect(model.age, 28);
      expect(model.isCompleted, false);
    });
  });
}
