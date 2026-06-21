import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/constant/storage_keys.dart';
import '../../../data/model/note_model.dart';

/// متحكم أداة الملاحظات العامة — تخزين محلي فقط على الجهاز.
///
/// مستقل تماماً عن [CycleNotesController] (ملاحظات الدورة على السيرفر).
/// لا يعتمد على اتصال بالإنترنت ولا على وجود دورة نشطة.
class NotesToolController extends GetxController {
  NotesToolController({GetStorage? storage})
      : _storage = storage ?? Get.find<GetStorage>();

  final GetStorage _storage;
  final Random _random = Random();

  final RxList<NoteModel> notes = <NoteModel>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotes();
  }

  void _loadNotes() {
    final raw = _storage.read<List<dynamic>>(StorageKeys.notesTool);
    if (raw == null) return;
    notes.value = raw
        .map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// يكتب الملاحظات على القرص. يعيد false عند فشل الكتابة (مثل امتلاء التخزين).
  Future<bool> _persist() async {
    try {
      await _storage.write(
        StorageKeys.notesTool,
        notes.map((n) => n.toJson()).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// الملاحظات مرتبة من الأحدث للأقدم حسب آخر تعديل.
  void _sort() {
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// معرّف فريد آمن ضد التصادم حتى مع الإنشاء المتزامن.
  String _newId() {
    return '${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';
  }

  /// قائمة مفلترة حسب نص البحث (في العنوان أو المحتوى).
  List<NoteModel> get filteredNotes {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return notes.toList();
    return notes.where((n) {
      return n.title.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q);
    }).toList();
  }

  /// إضافة ملاحظة جديدة. يعيد true عند نجاح الحفظ على القرص.
  /// عند الفشل يتراجع عن الإضافة المحلية كي لا تضيع البيانات صامتةً.
  Future<bool> addNote({
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();
    final note = NoteModel(
      id: _newId(),
      title: title.trim(),
      content: content.trim(),
      createdAt: now,
      updatedAt: now,
    );
    notes.insert(0, note);
    if (await _persist()) return true;
    notes.removeWhere((n) => n.id == note.id);
    return false;
  }

  /// تعديل ملاحظة موجودة. يعيد true عند النجاح، ويعيد false عند عدم العثور
  /// على الملاحظة أو فشل الحفظ (مع استعادة النسخة السابقة).
  Future<bool> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    final index = notes.indexWhere((n) => n.id == id);
    if (index == -1) return false;
    final previous = notes[index];
    notes[index] = previous.copyWith(
      title: title.trim(),
      content: content.trim(),
      updatedAt: DateTime.now(),
    );
    _sort();
    if (await _persist()) return true;
    // استعادة النسخة السابقة عند الفشل
    notes.removeWhere((n) => n.id == id);
    final insertAt = notes.indexWhere((n) =>
        n.updatedAt.isBefore(previous.updatedAt));
    notes.insert(insertAt == -1 ? notes.length : insertAt, previous);
    return false;
  }

  /// حذف ملاحظة. يعيد true عند الحذف الفعلي ونقله للقرص.
  Future<bool> deleteNote(String id) async {
    final index = notes.indexWhere((n) => n.id == id);
    if (index == -1) return false;
    final removed = notes.removeAt(index);
    if (await _persist()) return true;
    // استعادة الملاحظة عند فشل الكتابة
    notes.insert(index.clamp(0, notes.length), removed);
    return false;
  }

  NoteModel? getNote(String id) {
    final index = notes.indexWhere((n) => n.id == id);
    return index == -1 ? null : notes[index];
  }

  void updateSearch(String value) => searchQuery.value = value;

  void clearSearch() => searchQuery.value = '';

  /// تنبيه عائم موحّد (يستخدم ScaffoldMessenger لتفادي مشاكل Overlay).
  void showSnack({
    required String message,
    required IconData icon,
    required Color color,
  }) {
    final context = Get.context;
    if (context == null || !context.mounted) return;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          duration: const Duration(milliseconds: 1800),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(12),
        ),
      );
    } catch (_) {
      // تجاهل صامت لأخطاء العرض
    }
  }
}
