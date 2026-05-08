import 'package:farkha_app/data/model/cycle/medication_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MedicationEntry', () {
    test('fromJson يُنشئ كائن صحيح', () {
      final json = {
        'id': 'med1',
        'text': 'مضاد حيوي',
        'date': '2026-01-15T10:00:00Z',
      };

      final entry = MedicationEntry.fromJson(json);

      expect(entry.id, 'med1');
      expect(entry.text, 'مضاد حيوي');
      expect(entry.date, DateTime.parse('2026-01-15T10:00:00Z'));
    });

    test('fromJson يتعامل مع القيم المفقودة', () {
      final entry = MedicationEntry.fromJson({});

      expect(entry.id, '');
      expect(entry.text, '');
    });

    test('toJson يُرجع خريطة صحيحة', () {
      final entry = MedicationEntry(
        id: 'med1',
        text: 'لقاح',
        date: DateTime.parse('2026-01-15T10:00:00Z'),
      );

      final json = entry.toJson();

      expect(json['id'], 'med1');
      expect(json['text'], 'لقاح');
      expect(json['date'], '2026-01-15T10:00:00.000Z');
    });
  });
}
