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
  List<Map<String, dynamic>> filteredList = [];

  static const int _pageLimit = 30;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  DateTime? filterStartDate;
  DateTime? filterEndDate;

  DateTime? overrideDate;

  bool get isFiltering =>
      filterStartDate != null || filterEndDate != null;

  bool get isSingleDayFilter {
    if (filterStartDate == null || filterEndDate == null) return false;
    return filterStartDate!.year == filterEndDate!.year &&
        filterStartDate!.month == filterEndDate!.month &&
        filterStartDate!.day == filterEndDate!.day;
  }

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
      _applyFilter();
      return;
    }

    final mapResponse = response as Map<String, dynamic>;
    if (mapResponse['status'] != 'success') {
      statusRequest = StatusRequest.failure;
      _isLoadingMore = false;
      _hasMore = false;
      _applyFilter();
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
    _applyFilter();
  }

  void setFilter({DateTime? start, DateTime? end}) {
    filterStartDate = start;
    filterEndDate = end;
    overrideDate = null;
    _applyFilter();
    if (isSingleDayFilter && filteredList.isEmpty) {
      _expandToNearestDay();
    }
  }

  void clearFilter() {
    filterStartDate = null;
    filterEndDate = null;
    overrideDate = null;
    _applyFilter();
  }

  void _expandToNearestDay() {
    final target = DateTime(
      filterStartDate!.year,
      filterStartDate!.month,
      filterStartDate!.day,
    );

    for (int i = 0; i < historyList.length; i++) {
      final rawDate = historyList[i]['date'] as String? ?? '';
      if (rawDate.isEmpty) continue;
      final parsed = DateTime.tryParse(rawDate.split(' ').first);
      if (parsed == null) continue;
      final dateOnly = DateTime(parsed.year, parsed.month, parsed.day);

      if (dateOnly.isBefore(target) || dateOnly == target) {
        final item = Map<String, dynamic>.from(historyList[i]);
        final overrideStr =
            '${target.year}-${target.month.toString().padLeft(2, '0')}-${target.day.toString().padLeft(2, '0')}';
        item['override_date'] = overrideStr;
        filteredList = [item];
        overrideDate = target;
        update();
        return;
      }
    }
  }

  void _applyFilter() {
    if (!isFiltering) {
      filteredList = List.of(historyList);
    } else {
      filteredList = historyList.where((item) {
        final rawDate = item['date'] as String? ?? '';
        if (rawDate.isEmpty) return false;
        final datePart = rawDate.split(' ').first;
        final parsed = DateTime.tryParse(datePart);
        if (parsed == null) return false;
        final dateOnly = DateTime(parsed.year, parsed.month, parsed.day);

        if (filterStartDate != null) {
          final start = DateTime(
            filterStartDate!.year,
            filterStartDate!.month,
            filterStartDate!.day,
          );
          if (dateOnly.isBefore(start)) return false;
        }
        if (filterEndDate != null) {
          final end = DateTime(
            filterEndDate!.year,
            filterEndDate!.month,
            filterEndDate!.day,
          );
          if (dateOnly.isAfter(end)) return false;
        }
        return true;
      }).toList();
    }
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
