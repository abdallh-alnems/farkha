import 'package:dartz/dartz.dart';
import 'package:farkha_app/core/class/status_request.dart';
import 'package:farkha_app/data/data_source/remote/cycle_data/cycle_note_data.dart';

class FakeCycleNoteData implements CycleNoteData {
  final Map<String, Either<StatusRequest, Map<String, dynamic>>> _responses = {};

  void when(String method, Either<StatusRequest, Map<String, dynamic>> response) {
    _responses[method] = response;
  }

  Either<StatusRequest, Map<String, dynamic>> _get(String method) {
    return _responses[method] ?? const Left(StatusRequest.serverFailure);
  }

  @override
  Future<Either<StatusRequest, Map<String, dynamic>>> addCycleNote({
    required String token,
    required int cycleId,
    required String content,
  }) async => _get('addCycleNote');

  @override
  Future<Either<StatusRequest, Map<String, dynamic>>> getCycleNotes({
    required String token,
    required int cycleId,
  }) async => _get('getCycleNotes');

  @override
  Future<Either<StatusRequest, Map<String, dynamic>>> deleteCycleNote({
    required String token,
    required int cycleId,
    required int noteId,
  }) async => _get('deleteCycleNote');

  @override
  Future<Either<StatusRequest, Map<String, dynamic>>> updateCycleNote({
    required String token,
    required int cycleId,
    required int noteId,
    required String content,
  }) async => _get('updateCycleNote');
}
