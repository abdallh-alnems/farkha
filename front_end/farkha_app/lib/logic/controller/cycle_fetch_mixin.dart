import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/storage_keys.dart';
import '../../core/services/notification_service.dart';
import 'cycle_controller_base.dart';
import 'cycle_custom_data_controller.dart';
import 'cycle_expenses_controller.dart';

mixin CycleFetchMixin on CycleControllerBase {
  @override
  Future<void> fetchCyclesFromServer({bool force = false}) async {
    if (isCycleOpen && !force) {
      return;
    }

    try {
      final user = auth.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) return;

      final response = cycleData.getCycles(token: token);

      (await response).fold(
        (failure) {
          // fetch failed silently
        },
        (result) {
          final data = result['data'];
          if (data != null && data['cycles'] != null) {
            final apiCycles = data['cycles'] as List;

            final convertedCycles =
                apiCycles.map<Map<String, dynamic>>((cycle) {
                  final cycleId = cycle['id'];
                  final name = cycle['name'] ?? '';
                  final chickCount = cycle['chick_count']?.toString() ?? '0';
                  final startDateRaw = cycle['start_date_raw'] ?? '';
                  final mortality = cycle['mortality']?.toString() ?? '0';
                  final totalExpenses =
                      (cycle['total_expenses'] ?? 0).toString();
                  final totalSales = (cycle['total_sales'] ?? 0).toString();

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

                  final role = cycle['role']?.toString() ?? 'owner';
                  return {
                    'cycle_id': cycleId,
                    'name': name,
                    'chickCount': chickCount,
                    'startDate': startDate,
                    'startDateRaw': startDateRaw,
                    'mortality': mortality,
                    'total_expenses': totalExpenses,
                    'total_sales': totalSales,
                    'role': role,
                    'is_owner': role == 'owner',
                    'mortalityEntries': <Map<String, dynamic>>[],
                    'averageWeightEntries': <Map<String, dynamic>>[],
                    'medicationEntries': <Map<String, dynamic>>[],
                    'feedConsumptionEntries': <Map<String, dynamic>>[],
                  };
                }).toList();

            for (var convertedCycle in convertedCycles) {
              final cycleId = convertedCycle['cycle_id'];
              final existingIdx = cycles.indexWhere(
                (c) => c['cycle_id'] == cycleId,
              );

              if (existingIdx != -1) {
                final existingCycle = cycles[existingIdx];
                final cycleIdInt = cycleId is int
                    ? cycleId
                    : int.tryParse(cycleId.toString());

                if (cycleIdInt != null &&
                    loadingCycleDetails.contains(cycleIdInt)) {
                  continue;
                }

                final hasName = existingCycle['name'] != null &&
                    existingCycle['name'].toString().isNotEmpty;
                final hasCycleId = existingCycle['cycle_id'] != null;

                if (hasName && hasCycleId) {
                  final nameChanged =
                      existingCycle['name'] != convertedCycle['name'];
                  final chickCountChanged =
                      existingCycle['chickCount'] !=
                      convertedCycle['chickCount'];
                  final startDateRawChanged =
                      existingCycle['startDateRaw'] !=
                      convertedCycle['startDateRaw'];
                  final mortalityChanged =
                      existingCycle['mortality'] != convertedCycle['mortality'];
                  final totalExpensesChanged =
                      existingCycle['total_expenses'] !=
                      convertedCycle['total_expenses'];
                  final roleChanged =
                      existingCycle['role'] != convertedCycle['role'];

                  if (nameChanged ||
                      chickCountChanged ||
                      startDateRawChanged ||
                      mortalityChanged ||
                      totalExpensesChanged ||
                      roleChanged) {
                    cycles[existingIdx] = {
                      ...existingCycle,
                      'name': convertedCycle['name'],
                      'chickCount': convertedCycle['chickCount'],
                      'startDate': convertedCycle['startDate'],
                      'startDateRaw': convertedCycle['startDateRaw'],
                      'mortality': convertedCycle['mortality'],
                      'total_expenses': convertedCycle['total_expenses'],
                      'total_sales': convertedCycle['total_sales'],
                      'role': convertedCycle['role'],
                      'is_owner': convertedCycle['is_owner'],
                    };

                    if (roleChanged) {
                      final currentCycleId = currentCycle['cycle_id'];
                      if (currentCycleId == cycleId) {
                        currentCycle['role'] = convertedCycle['role'];
                        currentCycle['is_owner'] = convertedCycle['is_owner'];
                        currentCycle.refresh();
                      }
                    }
                  }
                } else {
                  cycles[existingIdx] = convertedCycle;
                }
              } else {
                cycles.add(convertedCycle);
              }
            }

            final convertedCycleIds =
                convertedCycles.map((c) => c['cycle_id']).toSet();
            cycles.removeWhere((cycle) {
              final cycleId = cycle['cycle_id'];
              return cycleId != null && !convertedCycleIds.contains(cycleId);
            });

            cycles.refresh();

            final deletedCycles =
                myServices.getStorage.read<List<dynamic>>(
                  StorageKeys.deletedCycles,
                ) ??
                <dynamic>[];
            if (deletedCycles.isNotEmpty) {
              cycles.removeWhere((cycle) {
                final cycleName = cycle['name']?.toString();
                return cycleName != null && deletedCycles.contains(cycleName);
              });
            }

            if (cycles.isNotEmpty) {
              final currentCycleId = currentCycle['cycle_id'];
              final currentCycleName = currentCycle['name']?.toString();
              final hasCurrentCycleData =
                  currentCycleName != null &&
                  currentCycleName.isNotEmpty &&
                  currentCycle.isNotEmpty &&
                  currentCycleId != null;

              if (hasCurrentCycleData) {
                final currentIdx = cycles.indexWhere(
                  (c) => c['cycle_id'] == currentCycleId,
                );
                if (currentIdx == -1) {
                  cycles.add(Map<String, dynamic>.from(currentCycle));
                } else {
                  final cycleInList = cycles[currentIdx];
                  final hasFullDataInList =
                      (cycleInList['mortalityEntries'] as List?)?.isNotEmpty ==
                          true ||
                      (cycleInList['averageWeightEntries'] as List?)
                              ?.isNotEmpty ==
                          true ||
                      (cycleInList['medicationEntries'] as List?)
                              ?.isNotEmpty ==
                          true ||
                      (cycleInList['feedConsumptionEntries'] as List?)
                              ?.isNotEmpty ==
                          true;

                  final hasFullDataInCurrent =
                      (currentCycle['mortalityEntries'] as List?)?.isNotEmpty ==
                          true ||
                      (currentCycle['averageWeightEntries'] as List?)
                              ?.isNotEmpty ==
                          true ||
                      (currentCycle['medicationEntries'] as List?)
                              ?.isNotEmpty ==
                          true ||
                      (currentCycle['feedConsumptionEntries'] as List?)
                              ?.isNotEmpty ==
                          true;

                  if (hasFullDataInCurrent && !hasFullDataInList) {
                    cycles[currentIdx] = Map<String, dynamic>.from(
                      currentCycle,
                    );
                  }
                }
              } else {
                if (currentCycleId != null) {
                  final currentIdx = cycles.indexWhere(
                    (c) => c['cycle_id'] == currentCycleId,
                  );
                  if (currentIdx != -1) {
                    currentCycle.assignAll(cycles[currentIdx]);
                  } else if (cycles.isNotEmpty) {
                    currentCycle.assignAll(cycles.first);
                  }
                } else if (cycles.isNotEmpty) {
                  currentCycle.assignAll(cycles.first);
                }
              }
            }

            myServices.getStorage.write(StorageKeys.cycles, cycles.toList());

            cycles.refresh();
          }
        },
      );
    } catch (e) {
      // fetch exception silently ignored
    } finally {
      checkAndAutoEndCycles();
    }
  }

  @override
  void checkAndAutoEndCycles();

  @override
  Future<void> fetchCycleDetails(int cycleId, {bool silent = false}) async {
    if (loadingCycleDetails.contains(cycleId)) {
      return;
    }

    try {
      isCycleOpen = true;
      loadingCycleDetails.add(cycleId);

      if (!silent) cycleDetailsStatus.value = StatusRequest.loading;

      final isLoggedIn =
          myServices.getStorage.read<bool>(StorageKeys.isLoggedIn) ?? false;
      if (!isLoggedIn) {
        loadingCycleDetails.remove(cycleId);
        if (!silent) cycleDetailsStatus.value = StatusRequest.none;
        return;
      }

      final user = auth.currentUser;
      if (user == null) {
        loadingCycleDetails.remove(cycleId);
        if (!silent) cycleDetailsStatus.value = StatusRequest.none;
        return;
      }

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        loadingCycleDetails.remove(cycleId);
        if (!silent) cycleDetailsStatus.value = StatusRequest.none;
        return;
      }

      final response = await cycleData.getCycleDetails(
        token: token,
        cycleId: cycleId,
      );

      response.fold(
        (failure) {
          loadingCycleDetails.remove(cycleId);

          if (!silent) {
            if (failure == StatusRequest.offlineFailure) {
              cycleDetailsStatus.value = StatusRequest.offlineFailure;
            } else if (failure == StatusRequest.serverFailure) {
              cycleDetailsStatus.value = StatusRequest.serverFailure;
            } else {
              cycleDetailsStatus.value = StatusRequest.failure;
            }
          }
        },
        (result) {
          final responseData = result['data'] as Map<String, dynamic>?;
          if (responseData != null) {
            final cycleApiData =
                responseData['cycle'] as Map<String, dynamic>?;
            final cycleDataList =
                (responseData['data'] as List<dynamic>?) ?? <dynamic>[];
            final expensesList =
                (responseData['expenses'] as List<dynamic>?) ?? <dynamic>[];

            final membersList =
                (responseData['members'] as List<dynamic>?) ?? <dynamic>[];
            final salesList =
                (responseData['sales'] as List<dynamic>?) ?? <dynamic>[];

            if (cycleApiData != null) {
              final cycleDetails = convertCycleDetailsFromApi(
                cycleApiData,
                cycleDataList: cycleDataList,
                expensesList: expensesList,
                membersList: membersList,
                salesList: salesList,
              );

              final idx = cycles.indexWhere((c) => c['cycle_id'] == cycleId);
              if (idx != -1) {
                final existing = cycles[idx];
                final merged = Map<String, dynamic>.from(cycleDetails);
                final fromApi =
                    (merged['chickCount']?.toString().trim() ??
                        merged['chick_count']?.toString().trim()) ??
                    '';
                if (fromApi.isEmpty || fromApi == '0') {
                  final existingCount =
                      existing['chickCount']?.toString().trim() ??
                      existing['chick_count']?.toString().trim();
                  if (existingCount != null &&
                      existingCount.isNotEmpty &&
                      existingCount != '0') {
                    merged['chickCount'] = existingCount;
                  }
                }
                cycles[idx] = merged;
              } else {
                cycles.add(Map<String, dynamic>.from(cycleDetails));
              }

              final currentCycleId = currentCycle['cycle_id'];
              if (currentCycleId != null) {
                final currentCycleIdInt = currentCycleId is int
                    ? currentCycleId
                    : int.tryParse(currentCycleId.toString());
                if (currentCycleIdInt == cycleId) {
                  currentCycle.assignAll(cycleDetails);
                  currentCycle.assignAll(cycleDetails);
                  cycleDataVersion.value++;

                  _scheduleNotificationsForCycle(cycleDetails);
                  _reloadExpensesController(cycleDetails);
                  _reloadCustomDataController(cycleDetails);
                }
              } else if (currentCycle['name'] == cycleDetails['name']) {
                currentCycle.assignAll(cycleDetails);
                cycleDataVersion.value++;

                _reloadExpensesController(cycleDetails);
                _reloadCustomDataController(cycleDetails);
              }
            }
          }

          loadingCycleDetails.remove(cycleId);
          if (!silent) {
            cycleDetailsStatus.value = StatusRequest.success;
            Future.delayed(const Duration(milliseconds: 500), () {
              if (cycleDetailsStatus.value == StatusRequest.success) {
                cycleDetailsStatus.value = StatusRequest.none;
              }
            });
          }
        },
      );
    } catch (e) {
      loadingCycleDetails.remove(cycleId);
      if (!silent) cycleDetailsStatus.value = StatusRequest.serverFailure;
      isCycleOpen = false;
    }
  }

  void _scheduleNotificationsForCycle(Map<String, dynamic> cycleDetails) {
    final startDateRaw = cycleDetails['startDateRaw']?.toString() ?? '';
    if (startDateRaw.isEmpty) return;
    final date = DateTime.tryParse(startDateRaw);
    if (date == null) return;
    final rawCycleId = cycleDetails['cycle_id'];
    final cycleIdInt = rawCycleId is int
        ? rawCycleId
        : int.tryParse(rawCycleId?.toString() ?? '');
    NotificationService.instance.scheduleCycleNotifications(
      date,
      cycleDetails['name']?.toString() ?? '',
      cycleIdInt,
    );
  }

  void _reloadExpensesController(Map<String, dynamic> cycleDetails) {
    final expenses = cycleDetails['expenses'] as List<dynamic>?;
    if (expenses == null || expenses.isEmpty) return;
    if (!Get.isRegistered<CycleExpensesController>()) return;
    try {
      final expensesCtrl = Get.find<CycleExpensesController>();
      expensesCtrl.reloadExpensesFromCycle();
    } catch (e) {
      // ignore
    }
  }

  void _reloadCustomDataController(Map<String, dynamic> cycleDetails) {
    final customDataEntries =
        cycleDetails['customDataEntries'] as List<dynamic>?;
    if (customDataEntries == null || customDataEntries.isEmpty) return;
    if (!Get.isRegistered<CycleCustomDataController>()) return;
    try {
      final customDataCtrl = Get.find<CycleCustomDataController>();
      customDataCtrl.loadCustomDataFromApi(customDataEntries);
    } catch (e) {
      // ignore
    }
  }

  void closeCycle() {
    isCycleOpen = false;
  }

  Future<void> forceRefreshCurrentCycle() async {
    final cycleId = currentCycle['cycle_id'];
    if (cycleId == null) return;
    final cycleIdInt =
        cycleId is int ? cycleId : int.tryParse(cycleId.toString());
    if (cycleIdInt == null || cycleIdInt <= 0) return;
    loadingCycleDetails.remove(cycleIdInt);
    await fetchCycleDetails(cycleIdInt);
  }
}
