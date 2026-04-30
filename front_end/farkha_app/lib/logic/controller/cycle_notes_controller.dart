import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/storage_keys.dart';
import '../../core/services/initialization.dart';
import '../../data/data_source/remote/cycle_data/cycle_data.dart';
import 'cycle_controller.dart';

class NoteItem {
  final String id;
  final String content;
  final DateTime date;

  NoteItem({required this.id, required this.content, required this.date});

  Map<String, dynamic> toJson() {
    return {'id': id, 'content': content, 'date': date.toIso8601String()};
  }

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      id: (json['id'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      date:
          DateTime.tryParse(
            (json['date'] ?? json['entry_date'] ?? '').toString(),
          ) ??
          DateTime.now(),
    );
  }
}

class CycleNotesController extends GetxController {
  CycleNotesController({
    CycleData? cycleData,
    FirebaseAuth? auth,
    MyServices? myServices,
  })  : _cycleDataOverride = cycleData,
        _authOverride = auth,
        _myServicesOverride = myServices;

  final CycleData? _cycleDataOverride;
  final FirebaseAuth? _authOverride;
  final MyServices? _myServicesOverride;

  final RxList<NoteItem> notes = <NoteItem>[].obs;
  late final MyServices myServices;
  late final FirebaseAuth _auth;
  late final CycleData _cycleData;

  // حالة التحميل
  final Rx<StatusRequest> notesStatus = StatusRequest.none.obs;
  final Rx<StatusRequest> addNoteStatus = StatusRequest.none.obs;

  @override
  void onInit() {
    super.onInit();
    _cycleData = _cycleDataOverride ?? CycleData();
    _auth = _authOverride ?? FirebaseAuth.instance;
    myServices = _myServicesOverride ?? Get.find<MyServices>();
    _loadNotes();

    // Watch for cycle changes to reload notes
    final cycleCtrl = Get.find<CycleController>();
    ever(cycleCtrl.currentCycle, (_) {
      _loadNotes();
    });
  }

  int? _getCurrentCycleId() {
    final cycleCtrl = Get.find<CycleController>();
    final cycleId = cycleCtrl.currentCycle['cycle_id'];
    if (cycleId == null) return null;
    return cycleId is int ? cycleId : int.tryParse(cycleId.toString());
  }

  Future<String?> _getToken() async {
    try {
      final isLoggedIn =
          myServices.getStorage.read<bool>(StorageKeys.isLoggedIn) ?? false;
      if (!isLoggedIn) return null;

      final user = _auth.currentUser;
      if (user == null) return null;

      return await user.getIdToken();
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadNotes() async {
    final cycleId = _getCurrentCycleId();
    if (cycleId == null || cycleId <= 0) {
      notes.clear();
      return;
    }

    notesStatus.value = StatusRequest.loading;

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        notesStatus.value = StatusRequest.failure;
        return;
      }

      final result = await _cycleData.getCycleNotes(
        token: token,
        cycleId: cycleId,
      );

      result.fold(
        (failure) {
          notesStatus.value = failure;
        },
        (response) {
          final status = response['status']?.toString() ?? '';
          if (status == 'success') {
            final data = response['data'];
            if (data is Map<String, dynamic>) {
              final notesList = data['notes'] as List<dynamic>? ?? [];
              notes.clear();
              notes.addAll(
                notesList.map((e) {
                  final noteMap = e as Map<String, dynamic>;
                  return NoteItem(
                    id: (noteMap['id'] ?? '').toString(),
                    content: (noteMap['content'] ?? '').toString(),
                    date:
                        DateTime.tryParse(
                          (noteMap['entry_date'] ?? '').toString(),
                        ) ??
                        DateTime.now(),
                  );
                }).toList(),
              );
            }
            notesStatus.value = StatusRequest.success;
          } else {
            notesStatus.value = StatusRequest.serverFailure;
          }
        },
      );
    } catch (e) {
      notesStatus.value = StatusRequest.serverFailure;
    }
  }

  Future<void> addNote(String content) async {
    if (content.trim().isEmpty) return;

    final cycleId = _getCurrentCycleId();
    if (cycleId == null || cycleId <= 0) return;

    addNoteStatus.value = StatusRequest.loading;

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        addNoteStatus.value = StatusRequest.failure;
        return;
      }

      final result = await _cycleData.addCycleNote(
        token: token,
        cycleId: cycleId,
        content: content,
      );

      result.fold(
        (failure) {
          addNoteStatus.value = failure;
          Future.delayed(const Duration(milliseconds: 2000), () {
            addNoteStatus.value = StatusRequest.none;
          });
        },
        (response) {
          final status = response['status']?.toString() ?? '';
          if (status == 'success') {
            final data = response['data'];
            final noteId =
                data is Map ? (data['note_id'] ?? '').toString() : '';

            // إضافة الملاحظة محلياً
            notes.insert(
              0,
              NoteItem(id: noteId, content: content, date: DateTime.now()),
            );

            addNoteStatus.value = StatusRequest.success;
            Future.delayed(const Duration(milliseconds: 500), () {
              addNoteStatus.value = StatusRequest.none;
            });
          } else {
            addNoteStatus.value = StatusRequest.serverFailure;
            Future.delayed(const Duration(milliseconds: 2000), () {
              addNoteStatus.value = StatusRequest.none;
            });
          }
        },
      );
    } catch (e) {
      addNoteStatus.value = StatusRequest.serverFailure;
      Future.delayed(const Duration(milliseconds: 2000), () {
        addNoteStatus.value = StatusRequest.none;
      });
    }
  }

  Future<void> deleteNote(String id) async {
    final cycleId = _getCurrentCycleId();
    if (cycleId == null || cycleId <= 0) return;

    final noteId = int.tryParse(id);
    if (noteId == null) return;

    // حذف محلياً فوراً
    notes.removeWhere((note) => note.id == id);

    // حذف من السيرفر
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) return;

      await _cycleData.deleteCycleNote(
        token: token,
        cycleId: cycleId,
        noteId: noteId,
      );
    } catch (e) {
      // في حالة الفشل، إعادة تحميل من السيرفر
      _loadNotes();
    }
  }

  Future<void> updateNote(String id, String newContent) async {
    if (newContent.trim().isEmpty) return;

    final cycleId = _getCurrentCycleId();
    if (cycleId == null || cycleId <= 0) return;

    final noteId = int.tryParse(id);
    if (noteId == null) return;

    // تحديث محلياً فوراً
    final index = notes.indexWhere((note) => note.id == id);
    if (index == -1) return;

    final oldContent = notes[index].content;
    notes[index] = NoteItem(
      id: id,
      content: newContent,
      date: notes[index].date,
    );

    // تحديث في السيرفر
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) return;

      final result = await _cycleData.updateCycleNote(
        token: token,
        cycleId: cycleId,
        noteId: noteId,
        content: newContent,
      );

      result.fold(
        (failure) {
          // في حالة الفشل، إرجاع المحتوى القديم
          final idx = notes.indexWhere((note) => note.id == id);
          if (idx != -1) {
            notes[idx] = NoteItem(
              id: id,
              content: oldContent,
              date: notes[idx].date,
            );
          }
        },
        (response) {
          // نجح التحديث
        },
      );
    } catch (e) {
      // في حالة الفشل، إعادة تحميل من السيرفر
      _loadNotes();
    }
  }

  /// إعادة تحميل الملاحظات من السيرفر
  Future<void> refreshNotes() async {
    await _loadNotes();
  }
}
