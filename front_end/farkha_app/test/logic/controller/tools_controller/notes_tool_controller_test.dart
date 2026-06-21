import 'package:farkha_app/core/constant/storage_keys.dart';
import 'package:farkha_app/data/model/note_model.dart';
import 'package:farkha_app/logic/controller/tools_controller/notes_tool_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_harness.dart';

class FailingGetStorage extends Mock implements GetStorage {}

void main() {
  late GetStorage storage;
  late NotesToolController controller;

  setUpAll(() async {
    TestHarness.setUpGetx();
    await TestHarness.ensureGetStorage();
  });

  setUp(() async {
    storage = await TestHarness.getStorage();
    await storage.remove(StorageKeys.notesTool);
    Get.reset();
    controller = Get.put(NotesToolController(storage: storage));
  });

  tearDown(() {
    Get.reset();
  });

  group('NotesToolController — الإضافة والعرض', () {
    test('addNote يضيف الملاحظة في رأس القائمة ويبقى محفوظاً', () async {
      await controller.addNote(title: 'أول', content: 'نص 1');
      await controller.addNote(title: 'ثاني', content: 'نص 2');

      expect(controller.notes.length, 2);
      expect(controller.notes.first.title, 'ثاني');
    });

    test('القائمة تبدأ فارغة', () {
      expect(controller.notes, isEmpty);
    });

    test('filteredNotes تعيد الكل عند عدم وجود بحث', () async {
      await controller.addNote(title: 't', content: 'c');
      expect(controller.filteredNotes.length, 1);
    });
  });

  group('NotesToolController — التحقق من الفراغ', () {
    test('addNote يقبل عنواناً فقط دون نص', () async {
      await controller.addNote(title: 'عنوان', content: '');
      expect(controller.notes.single.title, 'عنوان');
      expect(controller.notes.single.content, '');
    });

    test('addNote يقبل نصاً فقط دون عنوان', () async {
      await controller.addNote(title: '', content: 'محتوى');
      expect(controller.notes.single.title, '');
      expect(controller.notes.single.content, 'محتوى');
    });
  });

  group('NotesToolController — التعديل', () {
    test('updateNote يحدّث المحتوى ويعيد الترتيب للأحدث', () async {
      await controller.addNote(title: 'A', content: 'a');
      final aId = controller.notes.first.id;
      await controller.addNote(title: 'B', content: 'b');
      final bId = controller.notes.first.id;
      // القائمة: [B, A]
      expect(controller.notes.first.id, bId);

      await controller.updateNote(id: aId, title: 'A2', content: 'a2');
      // بعد التعديل يجب أن يصبح A في الرأس (آخر تعديل)
      expect(controller.notes.first.id, aId);
      expect(controller.notes.first.title, 'A2');
    });

    test('updateNote يعيد false لمعرّف غير موجود', () async {
      expect(
        await controller.updateNote(id: 'ghost', title: 'x', content: 'y'),
        isFalse,
      );
    });
  });

  group('NotesToolController — الحذف', () {
    test('deleteNote يحذف الملاحظة ويعيد true', () async {
      await controller.addNote(title: 't', content: 'c');
      final id = controller.notes.first.id;
      expect(await controller.deleteNote(id), isTrue);
      expect(controller.notes, isEmpty);
    });

    test('deleteNote يعيد false لمعرّف غير موجود', () async {
      expect(await controller.deleteNote('ghost'), isFalse);
    });
  });

  group('NotesToolController — البحث', () {
    test('filteredNotes يطابق العنوان أو النص', () async {
      await controller.addNote(title: 'تذكير علف', content: 'abc');
      await controller.addNote(title: ' XYZ ', content: 'مهم');
      await controller.addNote(title: 'شيء', content: 'كلمة علف هنا');

      controller.updateSearch('علف');
      expect(controller.filteredNotes.length, 2);
    });

    test('clearSearch تعيد عرض كل الملاحظات', () async {
      await controller.addNote(title: 't', content: 'c');
      controller.updateSearch('لا_مطابقة');
      expect(controller.filteredNotes, isEmpty);

      controller.clearSearch();
      expect(controller.filteredNotes.length, 1);
    });
  });

  group('NotesToolController — الثبات (persistence)', () {
    test('الملاحظات تُحمَّل من التخزين عند إنشاء متحكم جديد', () async {
      await controller.addNote(title: 'ثابت', content: 'يبقى بعد إعادة الفتح');

      // محاكاة إعادة فتح التطبيق: متحكم جديد يقرأ من نفس التخزين عبر onInit
      await Get.delete<NotesToolController>();
      final reloaded = Get.put(NotesToolController(storage: storage));

      expect(reloaded.notes.length, 1);
      expect(reloaded.notes.first.title, 'ثابت');
      expect(reloaded.notes.first.content, 'يبقى بعد إعادة الفتح');
    });

    test('الحذف يُكتب على التخزين ولا يعود بعد إعادة التحميل', () async {
      await controller.addNote(title: 'للحذف', content: 'c');
      final id = controller.notes.first.id;
      await controller.deleteNote(id);

      await Get.delete<NotesToolController>();
      final reloaded = Get.put(NotesToolController(storage: storage));
      expect(reloaded.notes, isEmpty);
    });
  });

  group('NotesToolController — فشل التخزين (التراجع)', () {
    test('addNote يتراجع عن الإضافة عند فشل الكتابة على القرص', () async {
      final failing = FailingGetStorage();
      when(() => failing.write(any<String>(), any<dynamic>()))
          .thenThrow(Exception('disk full'));

      final c = NotesToolController(storage: failing);
      final ok = await c.addNote(title: 'x', content: 'y');

      expect(ok, isFalse);
      expect(c.notes, isEmpty); // تراجع كامل
    });

    test('deleteNote يستعيد الملاحظة عند فشل الكتابة', () async {
      final failing = FailingGetStorage();
      when(() => failing.write(any<String>(), any<dynamic>()))
          .thenThrow(Exception('disk full'));

      final c = NotesToolController(storage: failing);
      final note = NoteModel(
        id: '1',
        title: 't',
        content: 'c',
        createdAt: DateTime(2026, 6, 15),
        updatedAt: DateTime(2026, 6, 15),
      );
      c.notes.add(note);

      final ok = await c.deleteNote('1');

      expect(ok, isFalse);
      expect(c.notes.length, 1); // استعادة
      expect(c.notes.single.id, '1');
    });

    test('updateNote يستعيد النسخة السابقة عند فشل الكتابة', () async {
      final failing = FailingGetStorage();
      when(() => failing.write(any<String>(), any<dynamic>()))
          .thenThrow(Exception('disk full'));

      final c = NotesToolController(storage: failing);
      final original = NoteModel(
        id: '1',
        title: 'أصلي',
        content: 'c',
        createdAt: DateTime(2026, 6, 15),
        updatedAt: DateTime(2026, 6, 15),
      );
      c.notes.add(original);

      final ok = await c.updateNote(id: '1', title: 'معدّل', content: 'c2');

      expect(ok, isFalse);
      expect(c.notes.single.title, 'أصلي'); // استعادة
    });
  });
}
