import 'package:get/get.dart';

import '../../../../core/class/status_request.dart';
import '../../../../data/data_source/remote/prices_data/price_history_data.dart';

class PriceHistoryController extends GetxController {
  PriceHistoryController({
    required int typeId,
    required String typeName,
  })  : _typeId = typeId,
        _typeName = typeName;

  final int _typeId;
  final String _typeName;

  int get typeId => _typeId;
  String get typeName => _typeName;

  final PriceHistoryData _priceHistoryData = PriceHistoryData(Get.find());

  StatusRequest statusRequest = StatusRequest.loading;
  List<Map<String, dynamic>> historyList = [];

  static const int _pageLimit = 30;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  Future<void> fetchHistory({String? beforeDate}) async {
    if (beforeDate == null) {
      statusRequest = StatusRequest.loading;
      update();
    } else {
      _isLoadingMore = true;
      update();
    }

    final response = await _priceHistoryData.getPriceHistory(
      typeId: _typeId,
      beforeDate: beforeDate,
    );

    if (response is StatusRequest) {
      statusRequest = response;
      _isLoadingMore = false;
      _hasMore = false;
      update();
      return;
    }

    final mapResponse = response as Map<String, dynamic>;
    if (mapResponse['status'] != 'success') {
      statusRequest = StatusRequest.failure;
      _isLoadingMore = false;
      _hasMore = false;
      update();
      return;
    }

    final data = mapResponse['data'] as List<dynamic>? ?? [];
    final newItems = data
        .map((e) => e as Map<String, dynamic>)
        .map((m) => {
              'date': m['date']?.toString() ?? '',
              'higher': m['higher']?.toString() ?? '',
              'lower': m['lower']?.toString() ?? '',
            })
        .toList();

    if (beforeDate == null) {
      historyList = newItems;
      statusRequest = StatusRequest.success;
    } else {
      historyList.addAll(newItems);
    }

    _hasMore = newItems.length >= _pageLimit;
    _isLoadingMore = false;
    update();
  }

  void loadMore() {
    if (_isLoadingMore || !_hasMore || historyList.isEmpty) return;
    final lastDate = historyList.last['date'] as String?;
    if (lastDate == null || lastDate.isEmpty) return;
    fetchHistory(beforeDate: lastDate);
  }

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  @override
  void onReady() {
    fetchHistory();
    super.onReady();
  }
}
