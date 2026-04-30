import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/storage_keys.dart';
import 'cycle_controller_base.dart';

mixin CycleHistoryMixin on CycleControllerBase {
  int _currentHistoryPage = 1;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString filterDateFrom = ''.obs;
  final RxString filterDateTo = ''.obs;
  final ScrollController historyScrollController = ScrollController();

  final RxMap<String, dynamic> historicCycleDetails = <String, dynamic>{}.obs;
  final Rx<StatusRequest> historicCycleStatus = StatusRequest.none.obs;

  Future<void> fetchHistory({int page = 1, bool isRefresh = false}) async {
    try {
      final user = auth.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) return;

      if (isRefresh) {
        _currentHistoryPage = 1;
        page = 1;
        hasMoreData.value = true;
      }

      if (page > 1) {
        isLoadingMore.value = true;
      }

      final response = await cycleData.getHistory(
        token: token,
        page: page,
        search: searchQuery.value,
        dateFrom: filterDateFrom.value,
        dateTo: filterDateTo.value,
      );

      response.fold(
        (failure) {
          if (page > 1) isLoadingMore.value = false;
          hasMoreData.value = false;
        },
        (result) {
          if (page > 1) isLoadingMore.value = false;
          final data = result['data'];
          if (data != null && data['cycles'] != null) {
            final apiCycles = data['cycles'] as List;
            final int totalCount = (data['total_count'] ?? 0) as int;

            final convertedCycles =
                apiCycles.map<Map<String, dynamic>>((cycle) {
                  final cycleId = cycle['id'];
                  final name = cycle['name'] ?? '';
                  final chickCount = cycle['chick_count']?.toString() ?? '0';
                  final space = cycle['space']?.toString() ?? '';
                  final breed = cycle['breed']?.toString() ?? '';
                  final systemType = cycle['system_type']?.toString() ?? 'أرضي';
                  final startDateRaw = cycle['start_date_raw'] ?? '';
                  final endDateRaw = cycle['end_date_raw'];
                  final mortalityStr = cycle['mortality']?.toString() ?? '0';
                  final mortality = int.tryParse(mortalityStr) ?? 0;
                  final totalExpensesStr =
                      (cycle['total_expenses'] ?? 0).toString();
                  final totalExpenses =
                      double.tryParse(totalExpensesStr) ?? 0.0;
                  final totalSalesStr = (cycle['total_sales'] ?? 0).toString();
                  final totalSales = double.tryParse(totalSalesStr) ?? 0.0;
                  final netProfit = totalSales - totalExpenses;
                  final totalFeedStr = (cycle['total_feed'] ?? 0).toString();
                  final totalFeed = double.tryParse(totalFeedStr) ?? 0.0;
                  final averageWeightStr =
                      (cycle['average_weight'] ?? 0).toString();
                  final averageWeight =
                      double.tryParse(averageWeightStr) ?? 0.0;
                  final parsedChickCount = int.tryParse(chickCount) ?? 0;

                  double fcr = 0.0;
                  final survivingChicks = parsedChickCount - mortality;
                  if (survivingChicks > 0 &&
                      averageWeight > 0 &&
                      totalFeed > 0) {
                    final totalMeatProduced = survivingChicks * averageWeight;
                    fcr = totalFeed / totalMeatProduced;
                  }

                  double costPerBird = 0.0;
                  if (survivingChicks > 0 && totalExpenses > 0) {
                    costPerBird = totalExpenses / survivingChicks;
                  }

                  double mortalityRate = 0.0;
                  if (parsedChickCount > 0 && mortality > 0) {
                    mortalityRate = (mortality / parsedChickCount) * 100;
                  }

                  int cycleAge = 0;

                  String startDate = '';
                  final startDateRawStr = startDateRaw.toString();
                  if (startDateRawStr.isNotEmpty) {
                    try {
                      final date = DateTime.parse(startDateRawStr);
                      final formatter = DateFormat('yyyy/MM/dd', 'ar');
                      startDate = formatter.format(date);
                    } catch (e) {
                      startDate = startDateRawStr;
                    }
                  }

                  String endDate = '';
                  if (endDateRaw != null && endDateRaw.toString().isNotEmpty) {
                    try {
                      final date = DateTime.parse(endDateRaw.toString());
                      final formatter = DateFormat('yyyy/MM/dd', 'ar');
                      endDate = formatter.format(date);

                      if (startDateRawStr.isNotEmpty) {
                        final startD = DateTime.parse(startDateRawStr);
                        cycleAge = date.difference(startD).inDays + 1;
                      }
                    } catch (e) {
                      endDate = endDateRaw.toString();
                    }
                  }

                  return {
                    'cycle_id': cycleId,
                    'name': name,
                    'chickCount': chickCount,
                    'space': space,
                    'breed': breed,
                    'systemType': systemType,
                    'startDate': startDate,
                    'startDateRaw': startDateRaw,
                    'endDate': endDate,
                    'endDateRaw': endDateRaw,
                    'mortality': mortality.toString(),
                    'total_expenses': totalExpensesStr,
                    'total_sales': totalSales.toStringAsFixed(0),
                    'net_profit': netProfit.toStringAsFixed(0),
                    'total_feed': totalFeedStr,
                    'average_weight': averageWeight.toString(),
                    'fcr': fcr.toStringAsFixed(1),
                    'cost_per_bird': costPerBird.toStringAsFixed(2),
                    'cycle_age': cycleAge.toString(),
                    'mortality_rate': mortalityRate.toStringAsFixed(1),
                  };
                }).toList();

            if (apiCycles.isNotEmpty) {
              _currentHistoryPage = page;
            }

            if (page == 1) {
              historyCycles.assignAll(convertedCycles);
            } else {
              for (var cycle in convertedCycles) {
                final exists = historyCycles.any(
                  (c) => c['cycle_id'] == cycle['cycle_id'],
                );
                if (!exists) {
                  historyCycles.add(cycle);
                }
              }
            }

            hasMoreData.value = historyCycles.length < totalCount;
          } else {
            hasMoreData.value = false;
          }
        },
      );
    } catch (e) {
      if (isLoadingMore.value) isLoadingMore.value = false;
      hasMoreData.value = false;
    }
  }

  Future<void> fetchNextHistoryPage() async {
    if (!isLoadingMore.value && hasMoreData.value) {
      await fetchHistory(page: _currentHistoryPage + 1);
    }
  }

  void searchHistory(String query) {
    if (searchQuery.value != query) {
      searchQuery.value = query;
      fetchHistory(isRefresh: true);
    }
  }

  void setDateFilter(String fromDate, String toDate) {
    if (filterDateFrom.value != fromDate || filterDateTo.value != toDate) {
      filterDateFrom.value = fromDate;
      filterDateTo.value = toDate;
      fetchHistory(isRefresh: true);
    }
  }

  void clearDateFilter() {
    if (filterDateFrom.value.isNotEmpty || filterDateTo.value.isNotEmpty) {
      filterDateFrom.value = '';
      filterDateTo.value = '';
      fetchHistory(isRefresh: true);
    }
  }

  Future<void> fetchHistoricCycleDetails(int cycleId) async {
    try {
      historicCycleStatus.value = StatusRequest.loading;

      final isLoggedIn =
          myServices.getStorage.read<bool>(StorageKeys.isLoggedIn) ?? false;
      if (!isLoggedIn) {
        historicCycleStatus.value = StatusRequest.none;
        return;
      }

      final user = auth.currentUser;
      if (user == null) {
        historicCycleStatus.value = StatusRequest.none;
        return;
      }

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        historicCycleStatus.value = StatusRequest.none;
        return;
      }

      final response = await cycleData.getCycleDetails(
        token: token,
        cycleId: cycleId,
      );

      response.fold(
        (failure) {
          if (failure == StatusRequest.offlineFailure) {
            historicCycleStatus.value = StatusRequest.offlineFailure;
          } else if (failure == StatusRequest.serverFailure) {
            historicCycleStatus.value = StatusRequest.serverFailure;
          } else {
            historicCycleStatus.value = StatusRequest.failure;
          }
        },
        (result) {
          final responseData = result['data'] as Map<String, dynamic>?;
          if (responseData != null) {
            final cycleData = responseData['cycle'] as Map<String, dynamic>?;
            final cycleDataList =
                (responseData['data'] as List<dynamic>?) ?? <dynamic>[];
            final expensesList =
                (responseData['expenses'] as List<dynamic>?) ?? <dynamic>[];
            final notesList =
                (responseData['notes'] as List<dynamic>?) ?? <dynamic>[];

            final membersList =
                (responseData['members'] as List<dynamic>?) ?? <dynamic>[];
            final salesList =
                (responseData['sales'] as List<dynamic>?) ?? <dynamic>[];

            if (cycleData != null) {
              final cycleDetails = convertCycleDetailsFromApi(
                cycleData,
                cycleDataList: cycleDataList,
                expensesList: expensesList,
                notesList: notesList,
                membersList: membersList,
                salesList: salesList,
              );

              final mergedDetails = Map<String, dynamic>.from(
                historicCycleDetails,
              );
              mergedDetails['feedEntries'] = cycleDetails['feedEntries'];
              mergedDetails['mortalityEntries'] =
                  cycleDetails['mortalityEntries'];
              mergedDetails['weightEntries'] = cycleDetails['weightEntries'];
              mergedDetails['customDataEntries'] =
                  cycleDetails['customDataEntries'];
              mergedDetails['expenses'] = cycleDetails['expenses'];
              mergedDetails['notes'] = cycleDetails['notes'];

              historicCycleDetails.assignAll(mergedDetails);
              historicCycleStatus.value = StatusRequest.success;
            } else {
              historicCycleStatus.value = StatusRequest.failure;
            }
          } else {
            historicCycleStatus.value = StatusRequest.failure;
          }
        },
      );
    } catch (e) {
      historicCycleStatus.value = StatusRequest.failure;
    }
  }
}
