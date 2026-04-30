import 'package:dartz/dartz.dart';
import 'package:farkha_app/core/class/status_request.dart';
import 'package:farkha_app/data/data_source/remote/cycle_data/cycle_data.dart';

class FakeCycleData implements CycleData {
  final Map<String, Either<StatusRequest, Map<String, dynamic>>> _responses = {};

  void when(String method, Either<StatusRequest, Map<String, dynamic>> response) {
    _responses[method] = response;
  }

  Either<StatusRequest, Map<String, dynamic>> _get(String method) {
    return _responses[method] ?? const Left(StatusRequest.serverFailure);
  }

  @override
  Future<Either<StatusRequest, Map<String, dynamic>>> createCycle({
    required String token,
    required String name,
    required int chickCount,
    required double space,
    String? breed,
    String? systemType,
    required String startDateRaw,
  }) async => _get('createCycle');

  @override
  Future<Either<StatusRequest, Map<String, dynamic>>> addCycleData({
    required String token,
    required int cycleId,
    required String label,
    required String value,
  }) async => _get('addCycleData');

  @override
  Future<Either<StatusRequest, Map<String, dynamic>>> addCycleExpense({
    required String token,
    required int cycleId,
    required String label,
    required double value,
  }) async => _get('addCycleExpense');

  @override
  Future<Either<StatusRequest, Map<String, dynamic>>> addCycleSale({
    required String token,
    required int cycleId,
    required int quantity,
    required double totalWeight,
    required double pricePerKg,
    required double totalPrice,
    String? saleDate,
  }) async => _get('addCycleSale');

  @override
  Future<Either<StatusRequest, Map<String, dynamic>>> deleteCycle({
    required String token,
    required int cycleId,
  }) async => _get('deleteCycle');

  @override
  Future<Either<StatusRequest, Map<String, dynamic>>> getCycles({
    required String token,
  }) async => _get('getCycles');

  @override
  Future<Either<StatusRequest, Map<String, dynamic>>> getHistory({
    required String token,
    int page = 1,
    int limit = 5,
    String search = '',
    String dateFrom = '',
    String dateTo = '',
  }) async => _get('getHistory');

  @override
  Future<Either<StatusRequest, Map<String, dynamic>>> getCycleDetails({
    required String token,
    required int cycleId,
  }) async => _get('getCycleDetails');

  @override
  Future<Either<StatusRequest, Map<String, dynamic>>> deleteCycleItem({
    required String token,
    required int cycleId,
    required String type,
    required String deleteType,
    int? itemId,
    String? label,
  }) async => _get('deleteCycleItem');

  @override
  Future<Either<StatusRequest, Map<String, dynamic>>> endCycle({
    required String token,
    required int cycleId,
    String? endDate,
  }) async => _get('endCycle');
}
