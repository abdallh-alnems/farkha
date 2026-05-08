import 'package:farkha_app/data/model/cycle/mortality_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MortalityEntry', () {
    test('fromJson يُنشئ كائن صحيح', () {
      final json = {
        'id': 'm1',
        'count': 5,
        'date': '2026-01-15T10:00:00Z',
      };

      final entry = MortalityEntry.fromJson(json);

      expect(entry.id, 'm1');
      expect(entry.count, 5);
      expect(entry.date, DateTime.parse('2026-01-15T10:00:00Z'));
    });

    test('fromJson يتعامل مع القيم المفقودة', () {
      final entry = MortalityEntry.fromJson({});

      expect(entry.id, '');
      expect(entry.count, 0);
    });

    test('toJson يُرجع خريطة صحيحة', () {
      final entry = MortalityEntry(
        id: 'm1',
        count: 3,
        date: DateTime.parse('2026-01-15T10:00:00Z'),
      );

      final json = entry.toJson();

      expect(json['id'], 'm1');
      expect(json['count'], 3);
      expect(json['date'], '2026-01-15T10:00:00.000Z');
    });

    test('fromJson ← toJson round-trip', () {
      final original = {
        'id': 'm2',
        'count': 10,
        'date': '2026-02-20T08:30:00Z',
      };

      final entry = MortalityEntry.fromJson(original);
      final json = entry.toJson();

      expect(json['id'], original['id']);
      expect(json['count'], original['count']);
    });
  });
}
