import 'package:farkha_app/data/data_source/static/vaccination_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VaccinationData', () {
    test('جدول التطعيمات يحتوي على 5 تطعيمات', () {
      expect(VaccinationData.vaccinationSchedule.length, 5);
    });

    test('getNextVaccinations يُرجع التطعيمات القادمة بعد العمر', () {
      final next = VaccinationData.getNextVaccinations(10);

      expect(next.isNotEmpty, isTrue);
      expect(next.every((v) => v.age > 10), isTrue);
    });

    test('getNextVaccinations يُرجع حتى 5 تطعيمات', () {
      final next = VaccinationData.getNextVaccinations(0);

      expect(next.length, lessThanOrEqualTo(5));
    });

    test('getNextVaccinations يُرجع قائمة فارغة بعد كل التطعيمات', () {
      final next = VaccinationData.getNextVaccinations(100);

      expect(next, isEmpty);
    });

    test('getTodayVaccination يُرجع التطعيم عند تطابق العمر', () {
      final today = VaccinationData.getTodayVaccination(7);

      expect(today, isNotNull);
      expect(today!.age, 7);
      expect(today.vaccineName, 'لقاح B1');
    });

    test('getTodayVaccination يُرجع null عند عدم تطابق', () {
      final today = VaccinationData.getTodayVaccination(99);

      expect(today, isNull);
    });

    test('getNextVaccination يُرجع أول تطعيم بعد العمر', () {
      final next = VaccinationData.getNextVaccination(7);

      expect(next, isNotNull);
      expect(next!.age, greaterThan(7));
    });

    test('getNextVaccination يُرجع null بعد كل التطعيمات', () {
      final next = VaccinationData.getNextVaccination(100);

      expect(next, isNull);
    });

    test('أعمار التطعيمات مرتبة تصاعدياً', () {
      final ages =
          VaccinationData.vaccinationSchedule.map((v) => v.age).toList();

      for (int i = 1; i < ages.length; i++) {
        expect(ages[i], greaterThan(ages[i - 1]));
      }
    });
  });
}
