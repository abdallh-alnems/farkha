import 'package:farkha_app/data/model/note_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoteModel', () {
    test('toJson/fromJson round-trip يحافظ على الحقول', () {
      final now = DateTime(2026, 6, 20, 14, 30);
      final note = NoteModel(
        id: '1',
        title: 'تذكير علف',
        content: 'طلب علف يوم الخميس',
        createdAt: now,
        updatedAt: now,
      );

      final restored = NoteModel.fromJson(note.toJson());

      expect(restored.id, '1');
      expect(restored.title, 'تذكير علف');
      expect(restored.content, 'طلب علف يوم الخميس');
      expect(restored.createdAt, now);
      expect(restored.updatedAt, now);
      expect(restored.edited, isFalse);
    });

    test('fromJson يتحمّل القيم المفقودة للعنوان/النص/العلم', () {
      final restored = NoteModel.fromJson({
        'id': '2',
        'createdAt': '2026-06-20T14:30:00.000',
        'updatedAt': '2026-06-20T14:30:00.000',
      });

      expect(restored.title, '');
      expect(restored.content, '');
      expect(restored.edited, isFalse);
    });

    test('fromJson يقرأ علم edited القادم من التخزين', () {
      final restored = NoteModel.fromJson({
        'id': '3',
        'title': 't',
        'content': 'c',
        'createdAt': '2026-06-01T00:00:00.000',
        'updatedAt': '2026-06-20T00:00:00.000',
        'edited': true,
      });

      expect(restored.edited, isTrue);
      expect(restored.isEdited, isTrue);
    });

    test('copyWith يُغيّر الحقول المحددة فقط', () {
      final created = DateTime(2026, 6, 15);
      final note = NoteModel(
        id: '3',
        title: 'قديم',
        content: 'نص قديم',
        createdAt: created,
        updatedAt: created,
      );
      final updated = DateTime(2026, 6, 20);
      final edited = note.copyWith(title: 'جديد', updatedAt: updated);

      expect(edited.id, '3');
      expect(edited.title, 'جديد');
      expect(edited.content, 'نص قديم');
      expect(edited.createdAt, created);
      expect(edited.updatedAt, updated);
    });

    test('isEdited يبدأ false ويصبح true بعد التعديل', () {
      final ts = DateTime(2026, 6, 20, 10);
      final fresh = NoteModel(
        id: '4',
        title: 'a',
        content: 'b',
        createdAt: ts,
        updatedAt: ts,
      );
      expect(fresh.isEdited, isFalse);

      final edited = fresh.copyWith(updatedAt: ts.add(const Duration(seconds: 1)));
      expect(edited.isEdited, isTrue);
    });

    test('copyWith بـ markEdited: false يحافظ على حالة العلم', () {
      final ts = DateTime(2026, 6, 20, 10);
      final note = NoteModel(
        id: '5',
        title: 'a',
        content: 'b',
        createdAt: ts,
        updatedAt: ts,
      );
      final copy = note.copyWith(updatedAt: ts.add(const Duration(minutes: 1)), markEdited: false);
      expect(copy.isEdited, isFalse);
    });
  });
}
