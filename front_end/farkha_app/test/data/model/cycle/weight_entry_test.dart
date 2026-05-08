import 'package:farkha_app/data/model/cycle/weight_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeightEntry', () {
    test('fromJson يُنشئ كائن صحيح', () {
      final json = {
        'id': 'w1',
        'weight': 2.5,
        'date': '2026-01-15T10:00:00Z',
      };

      final entry = WeightEntry.fromJson(json);

      expect(entry.id, 'w1');
      expect(entry.weight, 2.5);
      expect(entry.date, DateTime.parse('2026-01-15T10:00:00Z'));
    });

    test('fromJson يتعامل مع القيم المفقودة', () {
      final entry = WeightEntry.fromJson({});

      expect(entry.id, '');
      expect(entry.weight, 0.0);
    });

    test('toJson يُرجع خريطة صحيحة', () {
      final entry = WeightEntry(
        id: 'w1',
        weight: 1.8,
        date: DateTime.parse('2026-01-15T10:00:00Z'),
      );

      final json = entry.toJson();

      expect(json['id'], 'w1');
      expect(json['weight'], 1.8);
      expect(json['date'], '2026-01-15T10:00:00.000Z');
    });

    test('fromJson يحوّل int إلى double', () {
      final entry = WeightEntry.fromJson({'id': 'w1', 'weight': 3});

      expect(entry.weight, 3.0);
    });
  });
}
