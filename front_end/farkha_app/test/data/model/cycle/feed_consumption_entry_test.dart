import 'package:farkha_app/data/model/cycle/feed_consumption_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeedConsumptionEntry', () {
    test('fromJson يُنشئ كائن صحيح', () {
      final json = {
        'id': 'f1',
        'amount': 150.5,
        'date': '2026-01-15T10:00:00Z',
      };

      final entry = FeedConsumptionEntry.fromJson(json);

      expect(entry.id, 'f1');
      expect(entry.amount, 150.5);
      expect(entry.date, DateTime.parse('2026-01-15T10:00:00Z'));
    });

    test('fromJson يتعامل مع القيم المفقودة', () {
      final entry = FeedConsumptionEntry.fromJson({});

      expect(entry.id, '');
      expect(entry.amount, 0.0);
    });

    test('toJson يُرجع خريطة صحيحة', () {
      final entry = FeedConsumptionEntry(
        id: 'f1',
        amount: 200.0,
        date: DateTime.parse('2026-01-15T10:00:00Z'),
      );

      final json = entry.toJson();

      expect(json['id'], 'f1');
      expect(json['amount'], 200.0);
      expect(json['date'], '2026-01-15T10:00:00.000Z');
    });

    test('fromJson يحوّل int إلى double', () {
      final entry = FeedConsumptionEntry.fromJson({'id': 'f1', 'amount': 100});

      expect(entry.amount, 100.0);
    });
  });
}
