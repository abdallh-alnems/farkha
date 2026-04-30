import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/strings/app_strings.dart';
import '../../core/constant/routes/route.dart';
import '../../core/constant/storage_keys.dart';
import '../../core/services/initialization.dart';
import '../../core/services/notification_service.dart';
import '../../data/data_source/remote/cycle_data/cycle_data.dart';
import '../../view/widget/cycle/darkness_settings_sheet.dart';
import 'cycle_controller_base.dart';
import 'cycle_custom_data_controller.dart';
import 'cycle_data_entry_mixin.dart';
import 'cycle_expenses_controller.dart';
import 'cycle_history_mixin.dart';
import 'cycle_member_mixin.dart';
import 'tools_controller/darkness_schedule_controller.dart';

class CycleController extends CycleControllerBase
    with CycleHistoryMixin, CycleDataEntryMixin, CycleMemberMixin {
  CycleController({
    CycleData? cycleData,
    FirebaseAuth? auth,
    MyServices? myServices,
  })  : _cycleDataOverride = cycleData,
        _authOverride = auth,
        _myServicesOverride = myServices;

  final CycleData? _cycleDataOverride;
  final FirebaseAuth? _authOverride;
  final MyServices? _myServicesOverride;

  late final CycleData _cycleDataInternal;
  late final FirebaseAuth _authInternal;
  late final MyServices myServices;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController countController = TextEditingController();
  final TextEditingController spaceController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController dateRawController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Data
  final RxList<Map<String, dynamic>> cycles = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> historyCycles =
      <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> currentCycle = <String, dynamic>{}.obs;

  // Edit state
  final RxBool isEdit = false.obs;
  final RxInt editIndex = (-1).obs;
  final RxBool isCreatingCycle = false.obs;

  final Set<int> _loadingCycleDetails = <int>{};

  final Rx<StatusRequest> cycleDetailsStatus = StatusRequest.none.obs;

  final Rx<StatusRequest> cycleSaveStatus = StatusRequest.none.obs;

  final Rx<StatusRequest> cycleDeleteStatus = StatusRequest.none.obs;

  final Rx<StatusRequest> cycleEndStatus = StatusRequest.none.obs;

  /// Incremented when cycle data changes (edit save or fetch); Cycle screen listens to refresh darkness/broiler.
  final RxInt cycleDataVersion = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _cycleDataInternal = _cycleDataOverride ?? CycleData();
    cycleData = _cycleDataInternal;
    _authInternal = _authOverride ?? FirebaseAuth.instance;
    auth = _authInternal;
    myServices = _myServicesOverride ?? Get.find<MyServices>();
    _loadCycles();
    fetchCyclesFromServer();
    fetchInvitations();

    historyScrollController.addListener(() {
      if (historyScrollController.position.pixels ==
          historyScrollController.position.maxScrollExtent) {
        fetchNextHistoryPage();
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    _checkArguments();
  }

  void _checkArguments() {
    final args = Get.arguments;
    if (args != null && args is Map) {
      if (args['action'] == 'open_darkness_settings') {
        unawaited(
          Get.bottomSheet(
            DarknessSettingsSheet(
              controller: Get.find<DarknessScheduleController>(),
            ),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          ),
        );
      }
    }
  }

  void _loadCycles() {
    final saved = myServices.getStorage.read<List<dynamic>>(StorageKeys.cycles);
    if (saved != null && saved.isNotEmpty) {
      final loadedCycles =
          saved.map((item) {
            final cycle = Map<String, dynamic>.from(
              item as Map<dynamic, dynamic>,
            );
            cycle.remove('mortalityEntries');
            cycle.remove('averageWeightEntries');
            cycle.remove('medicationEntries');
            cycle.remove('feedConsumptionEntries');
            cycle.remove('expenses');
            cycle.remove('sales');
            cycle.remove('customDataEntries');
            cycle.remove('members');
            cycle.remove('notes');
            cycle['role'] ??= 'owner';
            return cycle;
          }).toList();
      cycles.value =
          loadedCycles.where((cycle) {
            final status = cycle['status']?.toString();
            return status != 'finished';
          }).toList();

      historyCycles.value =
          loadedCycles.where((cycle) {
            final status = cycle['status']?.toString();
            return status == 'finished';
          }).toList();
      if (cycles.isNotEmpty) {
        currentCycle.assignAll(cycles.first);
      }
    }
  }

  // ======================== جلب الدورات النشطة ========================

  Future<void> fetchCyclesFromServer() async {
    if (isCycleOpen) {
      return;
    }

    try {
      final user = auth.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) return;

      final response = await cycleData.getCycles(token: token);

      response.fold(
        (failure) {
          // ignore
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
                final cycleIdInt =
                    cycleId is int ? cycleId : int.tryParse(cycleId.toString());

                if (cycleIdInt != null &&
                    _loadingCycleDetails.contains(cycleIdInt)) {
                  continue;
                }

                final hasName =
                    existingCycle['name'] != null &&
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

                  if (nameChanged ||
                      chickCountChanged ||
                      startDateRawChanged ||
                      mortalityChanged ||
                      totalExpensesChanged) {
                    cycles[existingIdx] = {
                      ...existingCycle,
                      'name': convertedCycle['name'],
                      'chickCount': convertedCycle['chickCount'],
                      'startDate': convertedCycle['startDate'],
                      'startDateRaw': convertedCycle['startDateRaw'],
                      'mortality': convertedCycle['mortality'],
                      'total_expenses': convertedCycle['total_expenses'],
                      'total_sales': convertedCycle['total_sales'],
                    };
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
                myServices.getStorage.read<List<dynamic>>(StorageKeys.deletedCycles) ??
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
      // ignore
    } finally {
      _checkAndAutoEndCycles();
    }
  }

  void _checkAndAutoEndCycles() {
    if (cycles.isEmpty) return;

    final List<Map<String, dynamic>> activeCycles =
        List<Map<String, dynamic>>.from(cycles);
    final List<({Map<String, dynamic> cycle, String autoEndDate})> cyclesToEnd =
        [];

    for (final cycle in activeCycles) {
      final startDateRaw = cycle['startDateRaw']?.toString() ?? '';
      if (startDateRaw.isEmpty) continue;

      try {
        final startD = DateTime.parse(startDateRaw);
        final now = DateTime.now();
        final age = now.difference(startD).inDays + 1;

        if (age >= 40) {
          final day40 = startD.add(const Duration(days: 39));
          final autoEndDate = DateFormat('yyyy-MM-dd').format(day40);
          cyclesToEnd.add((cycle: cycle, autoEndDate: autoEndDate));
        }
      } catch (e) {
        // ignore
      }
    }

    if (cyclesToEnd.isNotEmpty) {
      _showSalesBeforeCloseDialog(cyclesToEnd, 0);
    }
  }

  void _showSalesBeforeCloseDialog(
    List<({Map<String, dynamic> cycle, String autoEndDate})> pendingCycles,
    int index,
  ) {
    if (index >= pendingCycles.length) return;

    final entry = pendingCycles[index];
    final cycle = entry.cycle;
    final autoEndDate = entry.autoEndDate;
    final cycleName = cycle['name']?.toString() ?? 'الدورة';

    void proceedToNext() {
      _showSalesBeforeCloseDialog(pendingCycles, index + 1);
    }

    Future<void> closeCycleAndProceed() async {
      await endCurrentCycle(endDate: autoEndDate, cycleOverride: cycle);
      proceedToNext();
    }

    Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'تنبيه – إغلاق دورة "$cycleName"',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          ],
        ),
        content: const Text(
          'وصلت الدورة إلى عمر 40 يوماً وستُغلق تلقائياً.\n\nيُنصح بإدخال بيانات المبيعات أولاً لضمان دقة التقارير المالية.',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back<void>();
              unawaited(closeCycleAndProceed());
            },
            child: const Text(
              'إغلاق بدون مبيعات',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
            label: const Text(
              'إدخال المبيعات',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onPressed: () async {
              Get.back<void>();
              currentCycle.assignAll(cycle);
              if (!Get.isRegistered<CycleExpensesController>()) {
                Get.put(CycleExpensesController());
              }
              await Get.toNamed<void>(AppRoute.cycleSales);
              unawaited(closeCycleAndProceed());
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> fetchCycleDetails(int cycleId, {bool silent = false}) async {
    if (_loadingCycleDetails.contains(cycleId)) {
      return;
    }

    try {
      isCycleOpen = true;
      _loadingCycleDetails.add(cycleId);

      if (!silent) cycleDetailsStatus.value = StatusRequest.loading;

      final isLoggedIn =
          myServices.getStorage.read<bool>(StorageKeys.isLoggedIn) ?? false;
      if (!isLoggedIn) {
        _loadingCycleDetails.remove(cycleId);
        if (!silent) cycleDetailsStatus.value = StatusRequest.none;
        return;
      }

      final user = auth.currentUser;
      if (user == null) {
        _loadingCycleDetails.remove(cycleId);
        if (!silent) cycleDetailsStatus.value = StatusRequest.none;
        return;
      }

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        _loadingCycleDetails.remove(cycleId);
        if (!silent) cycleDetailsStatus.value = StatusRequest.none;
        return;
      }

      final response = await cycleData.getCycleDetails(
        token: token,
        cycleId: cycleId,
      );

      response.fold(
        (failure) {
          _loadingCycleDetails.remove(cycleId);

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
            final cycleData = responseData['cycle'] as Map<String, dynamic>?;
            final cycleDataList =
                (responseData['data'] as List<dynamic>?) ?? <dynamic>[];
            final expensesList =
                (responseData['expenses'] as List<dynamic>?) ?? <dynamic>[];

            final membersList =
                (responseData['members'] as List<dynamic>?) ?? <dynamic>[];
            final salesList =
                (responseData['sales'] as List<dynamic>?) ?? <dynamic>[];

            if (cycleData != null) {
              final cycleDetails = _convertCycleDetailsFromApi(
                cycleData,
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
                final currentCycleIdInt =
                    currentCycleId is int
                        ? currentCycleId
                        : int.tryParse(currentCycleId.toString());
                if (currentCycleIdInt == cycleId) {
                  currentCycle.assignAll(cycleDetails);
                  currentCycle.assignAll(cycleDetails);
                  cycleDataVersion.value++;

                  final startDateRaw =
                      cycleDetails['startDateRaw']?.toString() ?? '';
                  if (startDateRaw.isNotEmpty) {
                    final date = DateTime.tryParse(startDateRaw);
                    if (date != null) {
                      NotificationService.instance.scheduleCycleNotifications(
                        date,
                        cycleDetails['name']?.toString() ?? '',
                      );
                    }
                  }

                  final expenses = cycleDetails['expenses'] as List<dynamic>?;
                  if (expenses != null &&
                      expenses.isNotEmpty &&
                      Get.isRegistered<CycleExpensesController>()) {
                    try {
                      final expensesCtrl = Get.find<CycleExpensesController>();
                      expensesCtrl.reloadExpensesFromCycle();
                    } catch (e) {
                      // ignore
                    }
                  }

                  final customDataEntries =
                      cycleDetails['customDataEntries'] as List<dynamic>?;
                  if (customDataEntries != null &&
                      customDataEntries.isNotEmpty &&
                      Get.isRegistered<CycleCustomDataController>()) {
                    try {
                      final customDataCtrl =
                          Get.find<CycleCustomDataController>();
                      customDataCtrl.loadCustomDataFromApi(customDataEntries);
                    } catch (e) {
                      // ignore
                    }
                  }
                }
              } else if (currentCycle['name'] == cycleDetails['name']) {
                currentCycle.assignAll(cycleDetails);
                cycleDataVersion.value++;

                final expenses = cycleDetails['expenses'] as List<dynamic>?;
                if (expenses != null &&
                    expenses.isNotEmpty &&
                    Get.isRegistered<CycleExpensesController>()) {
                  try {
                    final expensesCtrl = Get.find<CycleExpensesController>();
                    expensesCtrl.reloadExpensesFromCycle();
                  } catch (e) {
                    // ignore
                  }
                }

                final customDataEntries =
                    cycleDetails['customDataEntries'] as List<dynamic>?;
                if (customDataEntries != null &&
                    customDataEntries.isNotEmpty &&
                    Get.isRegistered<CycleCustomDataController>()) {
                  try {
                    final customDataCtrl =
                        Get.find<CycleCustomDataController>();
                    customDataCtrl.loadCustomDataFromApi(customDataEntries);
                  } catch (e) {
                    // ignore
                  }
                }
              }
            }
          }

          _loadingCycleDetails.remove(cycleId);
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
      _loadingCycleDetails.remove(cycleId);
      if (!silent) cycleDetailsStatus.value = StatusRequest.serverFailure;
      isCycleOpen = false;
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
    _loadingCycleDetails.remove(cycleIdInt);
    await fetchCycleDetails(cycleIdInt);
  }

  Map<String, dynamic> _convertCycleDetailsFromApi(
    Map<String, dynamic> cycleData, {
    List<dynamic>? cycleDataList,
    List<dynamic>? expensesList,
    List<dynamic>? notesList,
    List<dynamic>? membersList,
    List<dynamic>? salesList,
  }) {
    final cycleId = cycleData['id'] ?? cycleData['cycle_id'];
    final name = cycleData['name'] ?? '';
    final chickCount =
        cycleData['chick_count']?.toString() ??
        cycleData['chickCount']?.toString() ??
        '0';
    final space = cycleData['space']?.toString() ?? '0';
    final breed = cycleData['breed'] ?? 'تسمين';
    final systemType = cycleData['system_type'] ?? 'أرضي';
    final startDateRaw = cycleData['start_date_raw'] ?? '';
    final totalSales = (cycleData['total_sales'] ?? 0).toString();

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

    final mortalityEntries = <Map<String, dynamic>>[];
    final averageWeightEntries = <Map<String, dynamic>>[];
    final medicationEntries = <Map<String, dynamic>>[];
    final feedConsumptionEntries = <Map<String, dynamic>>[];
    final customDataEntries = <Map<String, dynamic>>[];

    if (cycleDataList != null && cycleDataList.isNotEmpty) {
      for (var item in cycleDataList) {
        final label = item['label']?.toString() ?? '';
        final value = item['value']?.toString() ?? '';
        final entryDateStr = item['entry_date']?.toString() ?? '';

        final labelLower = label.toLowerCase().trim();
        final labelOriginal = label.trim();

        final isMortality =
            labelLower == 'mortality' ||
            labelLower == 'نافق' ||
            labelLower == 'عدد النافق' ||
            labelOriginal == 'عدد النافق' ||
            (label.contains('نافق') && !label.contains('غير'));

        final isAverageWeight =
            labelLower == 'average_weight' ||
            labelLower == 'averageweight' ||
            labelOriginal == 'الوزن المتوسط' ||
            labelOriginal == 'متوسط وزن القطيع' ||
            labelLower == 'متوسط وزن القطيع' ||
            labelLower == 'الوزن المتوسط' ||
            labelLower == 'متوسط الوزن' ||
            (label.contains('وزن') && label.contains('متوسط'));

        final isMedication =
            labelLower == 'medication' ||
            labelOriginal == 'التحصينات' ||
            labelLower == 'التحصينات' ||
            labelLower == 'تحصين' ||
            (label.contains('تحصين') && !label.contains('غير')) ||
            label.contains('دواء');

        final isFeedConsumption =
            labelLower == 'feed_consumption' ||
            labelLower == 'feedconsumption' ||
            labelOriginal == 'الاستهلاك اليومي' ||
            labelOriginal == 'استهلاك العلف' ||
            labelLower == 'الاستهلاك اليومي' ||
            labelLower == 'استهلاك العلف' ||
            (label.contains('استهلاك') && !label.contains('غير')) ||
            (label.contains('علف') && label.contains('استهلاك'));

        final dateFormatted = _parseDateToString(entryDateStr);

        if (isMortality) {
          final count = int.tryParse(value) ?? 0;
          if (count > 0) {
            mortalityEntries.add({
              'id': item['id']?.toString() ?? '',
              'count': count,
              'date': dateFormatted,
            });
          }
        } else if (isAverageWeight) {
          final weight = double.tryParse(value) ?? 0.0;
          if (weight > 0) {
            averageWeightEntries.add({
              'id': item['id']?.toString() ?? '',
              'weight': weight,
              'date': dateFormatted,
            });
          }
        } else if (isMedication) {
          if (value.isNotEmpty) {
            medicationEntries.add({
              'id': item['id']?.toString() ?? '',
              'text': value,
              'date': dateFormatted,
            });
          }
        } else if (isFeedConsumption) {
          final amount = double.tryParse(value) ?? 0.0;
          if (amount > 0) {
            feedConsumptionEntries.add({
              'id': item['id']?.toString() ?? '',
              'amount': amount,
              'date': dateFormatted,
            });
          }
        } else {
          if (value.isNotEmpty) {
            customDataEntries.add({
              'id': item['id']?.toString() ?? '',
              'element_type': 'note',
              'label': label,
              'value': value,
              'date': dateFormatted,
            });
          }
        }
      }
    }

    final calculatedMortality = mortalityEntries.fold<int>(
      0,
      (sum, entry) =>
          sum + (int.tryParse(entry['count']?.toString() ?? '0') ?? 0),
    );

    double totalExpenses = 0.0;
    if (cycleData['total_expenses'] != null) {
      totalExpenses =
          (cycleData['total_expenses'] is num)
              ? (cycleData['total_expenses'] as num).toDouble()
              : (double.tryParse(cycleData['total_expenses'].toString()) ??
                  0.0);
    }

    final processedExpenses = <Map<String, dynamic>>[];
    if (expensesList != null && expensesList.isNotEmpty) {
      for (var expense in expensesList) {
        final label = expense['label']?.toString() ?? '';
        final rawValue = expense['value'];
        final entryDateStr = expense['entry_date']?.toString() ?? '';
        final dateFormatted = _parseDateToString(entryDateStr);
        final amount =
            (rawValue is num)
                ? rawValue.toDouble()
                : (double.tryParse(rawValue?.toString() ?? '0') ?? 0.0);

        if (label.isNotEmpty) {
          processedExpenses.add({
            'id': expense['id']?.toString() ?? '',
            'type': label,
            'amount': amount,
            'created_at': dateFormatted,
            'notes': '',
          });
          totalExpenses += amount;
        }
      }
    }

    final processedNotes = <Map<String, dynamic>>[];
    if (notesList != null && notesList.isNotEmpty) {
      for (var note in notesList) {
        final content = note['content']?.toString() ?? '';
        final noteDateStr = note['entry_date']?.toString() ?? '';
        final dateFormatted = _parseDateToString(noteDateStr);
        if (content.isNotEmpty) {
          processedNotes.add({
            'id': note['id']?.toString() ?? '',
            'content': content,
            'date': dateFormatted,
          });
          customDataEntries.add({
            'id': note['id']?.toString() ?? '',
            'element_type': 'note',
            'label': 'ملاحظة',
            'value': content,
            'date': dateFormatted,
          });
        }
      }
    }

    if (totalExpenses == 0.0 && processedExpenses.isNotEmpty) {
      totalExpenses = processedExpenses.fold<double>(
        0.0,
        (sum, expense) => sum + ((expense['value'] as num?)?.toDouble() ?? 0.0),
      );
    }

    double calculatedTotalSales = (double.tryParse(totalSales) ?? 0.0);
    if (calculatedTotalSales == 0.0 &&
        salesList != null &&
        salesList.isNotEmpty) {
      calculatedTotalSales = salesList.fold<double>(
        0.0,
        (sum, sale) =>
            sum +
            (double.tryParse(sale['total_price']?.toString() ?? '0.0') ?? 0.0),
      );
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
      'mortality': calculatedMortality.toString(),
      'total_expenses': totalExpenses.toString(),
      'total_sales': calculatedTotalSales.toString(),
      'feedEntries': feedConsumptionEntries,
      'mortalityEntries': mortalityEntries,
      'weightEntries': averageWeightEntries,
      'customDataEntries': customDataEntries,
      'expenses': processedExpenses,
      'notes': processedNotes,
      'mortalityEntriesLegacy': mortalityEntries,
      'averageWeightEntries': averageWeightEntries,
      'medicationEntries': medicationEntries,
      'feedConsumptionEntries': feedConsumptionEntries,
      'members': membersList ?? [],
      'sales': salesList ?? [],
      'role': cycleData['role'] ?? 'owner',
      'is_owner': (cycleData['role'] ?? 'owner') == 'owner',
    };
  }

  String _parseDateToString(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      DateTime? parsed = DateTime.tryParse(dateStr);

      if (parsed == null && dateStr.contains(' ')) {
        final parts = dateStr.split(' ');
        if (parts.length == 2) {
          parsed = DateTime.tryParse('${parts[0]}T${parts[1]}');
        }
      }

      if (parsed != null) {
        final y = parsed.year.toString().padLeft(4, '0');
        final m = parsed.month.toString().padLeft(2, '0');
        final d = parsed.day.toString().padLeft(2, '0');
        return '$y/$m/$d';
      }
    } catch (_) {}
    return dateStr.length >= 10
        ? dateStr.substring(0, 10).replaceAll('-', '/')
        : dateStr;
  }

  void prepareForEdit(Map<String, dynamic> data, int index) {
    isEdit.value = true;
    editIndex.value = index;
    nameController.text = (data['name'] ?? '').toString();
    countController.text =
        (data['chickCount'] ?? data['chick_count'] ?? '').toString();
    spaceController.text = (data['space'] ?? '').toString();
    dateController.text = (data['startDate'] ?? '').toString();
    dateRawController.text = (data['startDateRaw'] ?? '').toString();
  }

  String ageOf(String isoDate) {
    if (isoDate.isEmpty) return '';
    final start = DateTime.tryParse(isoDate);
    if (start == null) return '';
    final now = DateTime.now();
    if (now.isBefore(start)) return 'لم تبدأ';
    final days = now.difference(start).inDays + 1;
    return '$days';
  }

  Future<void> onNext() async {
    if (cycleSaveStatus.value == StatusRequest.loading) return;
    if (!formKey.currentState!.validate()) return;

    final name = nameController.text.trim();
    final chickCount = int.tryParse(countController.text.trim()) ?? 0;
    final space = double.tryParse(spaceController.text.trim()) ?? 0.0;
    const breed = 'تسمين';
    const systemType = 'أرضي';
    final startDateRaw = dateRawController.text.trim();
    final startDate = dateController.text.trim();

    final entry = {
      'name': name,
      'chickCount': countController.text.trim(),
      'space': spaceController.text.trim(),
      'breed': breed,
      'systemType': systemType,
      'startDate': startDate,
      'startDateRaw': startDateRaw,
      'mortalityEntries': <Map<String, dynamic>>[],
      'mortality': '0',
      'role': 'owner',
    };

    if (isEdit.value &&
        editIndex.value >= 0 &&
        editIndex.value < cycles.length) {
      cycles[editIndex.value] = entry;
      currentCycle.assignAll(entry);
      cycleDataVersion.value++;
      isEdit.value = false;
      editIndex.value = -1;

      if (entry['startDateRaw'] != null) {
        final date = DateTime.tryParse(entry['startDateRaw'].toString());
        if (date != null) {
          NotificationService.instance.scheduleCycleNotifications(
            date,
            entry['name']?.toString() ?? '',
          );
        }
      }

      if (entry['cycle_id'] == null) {
        await myServices.getStorage.write(StorageKeys.cycles, cycles.toList());
      }
      clearFields();

      Get.back<void>();
      return;
    }

    if (isEdit.value) {
      isEdit.value = false;
      editIndex.value = -1;
    }

    final existingCycle = cycles.indexWhere((c) => c['name'] == name);
    if (existingCycle == -1) {
      _deleteCycleRelatedData(name);
    }

    isCreatingCycle.value = true;
    cycleSaveStatus.value = StatusRequest.loading;

    try {
      final isLoggedIn =
          myServices.getStorage.read<bool>(StorageKeys.isLoggedIn) ?? false;
      if (!isLoggedIn) {
        cycles.add(entry);
        await myServices.getStorage.write(StorageKeys.cycles, cycles.toList());
        clearFields();
        cycleSaveStatus.value = StatusRequest.none;
        isCreatingCycle.value = false;

        final newIndex = cycles.length - 1;
        final shouldShowTutorial = cycles.length == 2;

        unawaited(
          Get.offNamedUntil(
            AppRoute.cycle,
            ModalRoute.withName('/'),
            arguments: {'index': newIndex, 'showTutorial': shouldShowTutorial},
          ),
        );
        return;
      }

      final user = auth.currentUser;
      if (user == null) {
        isCreatingCycle.value = false;
        cycleSaveStatus.value = StatusRequest.failure;
        return;
      }

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        isCreatingCycle.value = false;
        cycleSaveStatus.value = StatusRequest.failure;
        return;
      }

      final response = await cycleData.createCycle(
        token: token,
        name: name,
        chickCount: chickCount,
        space: space,
        breed: breed,
        systemType: systemType,
        startDateRaw: startDateRaw,
      );

      response.fold(
        (failure) {
          cycles.add(entry);
          myServices.getStorage.write(StorageKeys.cycles, cycles.toList());
          if (failure == StatusRequest.offlineFailure) {
            cycleSaveStatus.value = StatusRequest.offlineFailure;
          } else if (failure == StatusRequest.serverFailure) {
            cycleSaveStatus.value = StatusRequest.serverFailure;
          } else {
            cycleSaveStatus.value = StatusRequest.failure;
          }
        },
        (Map<String, dynamic> result) {
          final data = result;
          final isSuccess = data['status'] == 'success';

          if (isSuccess && data['data'] != null) {
            final cycleData = data['data'] as Map<String, dynamic>;
            final cycleId = cycleData['cycle_id'];

            if (cycleId is int) {
              entry['cycle_id'] = cycleId;
            } else if (cycleId is String) {
              final parsedId = int.tryParse(cycleId);
              if (parsedId != null) {
                entry['cycle_id'] = parsedId;
              }
            }
          }

          cycles.add(entry);
          myServices.getStorage.write(StorageKeys.cycles, cycles.toList());
          cycleSaveStatus.value = StatusRequest.success;

          if (entry['startDateRaw'] != null) {
            final date = DateTime.tryParse(entry['startDateRaw'].toString());
            if (date != null) {
              NotificationService.instance.scheduleCycleNotifications(
                date,
                entry['name']?.toString() ?? '',
              );
            }
          }
        },
      );
      clearFields();
      isCreatingCycle.value = false;

      Future.delayed(const Duration(milliseconds: 500), () {
        if (cycleSaveStatus.value == StatusRequest.success) {
          cycleSaveStatus.value = StatusRequest.none;
        }
      });

      final newIndex = cycles.length - 1;
      final shouldShowTutorial = cycles.length == 2;

      unawaited(
        Get.offNamedUntil<void>(
          AppRoute.cycle,
          ModalRoute.withName('/'),
          arguments: {'index': newIndex, 'showTutorial': shouldShowTutorial},
        ),
      );
    } catch (e) {
      cycles.add(entry);
      await myServices.getStorage.write(StorageKeys.cycles, cycles.toList());
      isCreatingCycle.value = false;
      cycleSaveStatus.value = StatusRequest.serverFailure;
      clearFields();

      final newIndex = cycles.length - 1;
      final shouldShowTutorial = cycles.length == 2;

      unawaited(
        Get.offNamedUntil<void>(
          AppRoute.cycle,
          ModalRoute.withName('/'),
          arguments: {'index': newIndex, 'showTutorial': shouldShowTutorial},
        ),
      );
    } finally {
      isCreatingCycle.value = false;
    }
  }

  void clearFields() {
    nameController.clear();
    countController.clear();
    spaceController.clear();
    dateController.clear();
    dateRawController.clear();
    formKey.currentState?.reset();
  }

  void _deleteCycleRelatedData(String cycleName) {
    try {
      final expensesKey = '${StorageKeys.expensesPrefix}$cycleName';
      if (myServices.getStorage.hasData(expensesKey)) {
        myServices.getStorage.remove(expensesKey);
      }

      final customDataKey = '${StorageKeys.customDataPrefix}$cycleName';
      if (myServices.getStorage.hasData(customDataKey)) {
        myServices.getStorage.remove(customDataKey);
      }

      final notesKey = '${StorageKeys.notesPrefix}$cycleName';
      if (myServices.getStorage.hasData(notesKey)) {
        myServices.getStorage.remove(notesKey);
      }
    } catch (e) {
      // ignore
    }
  }

  Future<bool> deleteCurrentCycle() async {
    final idx = cycles.indexWhere((c) => c['name'] == currentCycle['name']);
    if (idx == -1) return false;

    cycleDeleteStatus.value = StatusRequest.loading;

    try {
      final cycleId = currentCycle['cycle_id'];
      final cycleName = currentCycle['name']?.toString();

      final cycleIdInt =
          cycleId is int
              ? cycleId
              : (cycleId != null ? int.tryParse(cycleId.toString()) : null);
      final hasServerCycle = cycleIdInt != null && cycleIdInt > 0;

      debugPrint(
        '[deleteCycle] cycleName=$cycleName, cycleIdRaw=$cycleId, '
        'cycleIdInt=$cycleIdInt, hasServerCycle=$hasServerCycle',
      );

      if (hasServerCycle) {
        final isLoggedIn =
            myServices.getStorage.read<bool>(StorageKeys.isLoggedIn) ?? false;
        debugPrint('[deleteCycle] isLoggedIn=$isLoggedIn');
        if (!isLoggedIn) {
          debugPrint('[deleteCycle] FAIL: not logged in');
          cycleDeleteStatus.value = StatusRequest.failure;
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (cycleDeleteStatus.value == StatusRequest.failure) {
              cycleDeleteStatus.value = StatusRequest.none;
            }
          });
          return false;
        }

        final user = auth.currentUser;
        debugPrint('[deleteCycle] firebaseUser=${user?.uid}');
        if (user == null) {
          debugPrint('[deleteCycle] FAIL: no firebase user');
          cycleDeleteStatus.value = StatusRequest.failure;
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (cycleDeleteStatus.value == StatusRequest.failure) {
              cycleDeleteStatus.value = StatusRequest.none;
            }
          });
          return false;
        }

        final token = await user.getIdToken();
        debugPrint('[deleteCycle] tokenEmpty=${token == null || token.isEmpty}');
        if (token == null || token.isEmpty) {
          debugPrint('[deleteCycle] FAIL: empty token');
          cycleDeleteStatus.value = StatusRequest.failure;
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (cycleDeleteStatus.value == StatusRequest.failure) {
              cycleDeleteStatus.value = StatusRequest.none;
            }
          });
          return false;
        }

        debugPrint('[deleteCycle] calling API with cycleId=$cycleIdInt');
        final result = await cycleData.deleteCycle(
          token: token,
          cycleId: cycleIdInt,
        );

        StatusRequest? failureStatus;
        result.fold(
          (failure) {
            debugPrint('[deleteCycle] API LEFT failure=$failure');
            failureStatus = failure;
          },
          (response) {
            debugPrint('[deleteCycle] API RIGHT response=$response');
            if (response['status'] != 'success') {
              failureStatus = StatusRequest.serverFailure;
            }
          },
        );

        if (failureStatus != null) {
          debugPrint('[deleteCycle] FAIL: API failed -> $failureStatus');
          cycleDeleteStatus.value = failureStatus!;
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (cycleDeleteStatus.value == failureStatus) {
              cycleDeleteStatus.value = StatusRequest.none;
            }
          });
          return false;
        }
        debugPrint('[deleteCycle] API success, proceeding to local delete');
      }

      if (cycleName != null && cycleName.isNotEmpty) {
        _deleteCycleRelatedData(cycleName);

        final deletedCycles =
            myServices.getStorage.read<List<dynamic>>(StorageKeys.deletedCycles) ??
            <dynamic>[];
        if (!deletedCycles.contains(cycleName)) {
          deletedCycles.add(cycleName);
          unawaited(
            myServices.getStorage.write(StorageKeys.deletedCycles, deletedCycles),
          );
        }
      }

      await NotificationService.instance.cancelCycleNotifications();

      cycles.removeAt(idx);
      await myServices.getStorage.write(StorageKeys.cycles, cycles.toList());

      if (cycles.isNotEmpty) {
        currentCycle.assignAll(cycles.last);
      } else {
        currentCycle.clear();
      }

      cycleDeleteStatus.value = StatusRequest.success;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (cycleDeleteStatus.value == StatusRequest.success) {
          cycleDeleteStatus.value = StatusRequest.none;
        }
      });

      return cycles.isEmpty;
    } catch (e) {
      cycleDeleteStatus.value = StatusRequest.failure;
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (cycleDeleteStatus.value == StatusRequest.failure) {
          cycleDeleteStatus.value = StatusRequest.none;
        }
      });
      return false;
    }
  }

  Future<bool> endCurrentCycle({
    String? endDate,
    Map<String, dynamic>? cycleOverride,
  }) async {
    final cycleToEnd = cycleOverride ?? currentCycle;
    final idx = cycles.indexWhere((c) => c['name'] == cycleToEnd['name']);
    if (idx == -1) return false;

    if (cycleToEnd['endDateRaw'] != null &&
        cycleToEnd['endDateRaw'].toString().isNotEmpty) {
      return false;
    }

    final cycleId = cycleToEnd['cycle_id'];
    final cycleName = cycleToEnd['name']?.toString();

    cycles.removeAt(idx);

    if (currentCycle['name'] == cycleName) {
      currentCycle.clear();
      if (cycles.isNotEmpty) {
        currentCycle.assignAll(cycles.first);
      }
    }

    cycles.refresh();

    unawaited(
      Future.microtask(() {
        cycles.refresh();
      }),
    );

    unawaited(NotificationService.instance.cancelCycleNotifications());

    if (cycleName != null && cycleName.isNotEmpty) {
      _deleteCycleRelatedData(cycleName);

      final deletedCycles =
          myServices.getStorage.read<List<dynamic>>(StorageKeys.deletedCycles) ??
          <dynamic>[];
      if (!deletedCycles.contains(cycleName)) {
        deletedCycles.add(cycleName);
        unawaited(
          myServices.getStorage.write(StorageKeys.deletedCycles, deletedCycles),
        );
      }
    }

    await myServices.getStorage.write(StorageKeys.cycles, cycles.toList());

    cycleEndStatus.value = StatusRequest.loading;

    if (cycleId != null) {
      unawaited(_endCycleFromServerInBackground(cycleId, endDate: endDate));
    } else {
      cycleEndStatus.value = StatusRequest.success;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (cycleEndStatus.value == StatusRequest.success) {
          cycleEndStatus.value = StatusRequest.none;
        }
      });
    }

    return true;
  }

  Future<void> _endCycleFromServerInBackground(
    dynamic cycleId, {
    String? endDate,
  }) async {
    try {
      final isLoggedIn =
          myServices.getStorage.read<bool>(StorageKeys.isLoggedIn) ?? false;
      if (!isLoggedIn) {
        cycleEndStatus.value = StatusRequest.success;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (cycleEndStatus.value == StatusRequest.success) {
            cycleEndStatus.value = StatusRequest.none;
          }
        });
        return;
      }

      final user = auth.currentUser;
      if (user == null) {
        cycleEndStatus.value = StatusRequest.success;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (cycleEndStatus.value == StatusRequest.success) {
            cycleEndStatus.value = StatusRequest.none;
          }
        });
        return;
      }

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        cycleEndStatus.value = StatusRequest.success;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (cycleEndStatus.value == StatusRequest.success) {
            cycleEndStatus.value = StatusRequest.none;
          }
        });
        return;
      }

      final cycleIdInt =
          cycleId is int ? cycleId : int.tryParse(cycleId.toString()) ?? 0;
      if (cycleIdInt <= 0) {
        cycleEndStatus.value = StatusRequest.success;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (cycleEndStatus.value == StatusRequest.success) {
            cycleEndStatus.value = StatusRequest.none;
          }
        });
        return;
      }

      final result = await cycleData.endCycle(
        token: token,
        cycleId: cycleIdInt,
        endDate: endDate,
      );

      result.fold(
        (failure) {
          cycleEndStatus.value = StatusRequest.success;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (cycleEndStatus.value == StatusRequest.success) {
              cycleEndStatus.value = StatusRequest.none;
            }
          });
        },
        (response) {
          if (response['status'] == 'success') {
            cycleEndStatus.value = StatusRequest.success;
            Future.delayed(const Duration(milliseconds: 500), () {
              if (cycleEndStatus.value == StatusRequest.success) {
                cycleEndStatus.value = StatusRequest.none;
              }
            });
          } else {
            cycleEndStatus.value = StatusRequest.success;
            Future.delayed(const Duration(milliseconds: 500), () {
              if (cycleEndStatus.value == StatusRequest.success) {
                cycleEndStatus.value = StatusRequest.none;
              }
            });
          }
        },
      );
    } catch (e) {
      cycleEndStatus.value = StatusRequest.success;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (cycleEndStatus.value == StatusRequest.success) {
          cycleEndStatus.value = StatusRequest.none;
        }
      });
    }
  }

  bool isCycleEnded(Map<String, dynamic> cycle) {
    return cycle['endDateRaw'] != null &&
        cycle['endDateRaw'].toString().isNotEmpty;
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final firstAllowedDate = now.subtract(const Duration(days: 39));
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstAllowedDate,
      lastDate: DateTime(now.year + 1),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      dateRawController.text = DateFormat('yyyy-MM-dd').format(picked);
      final formatted = DateFormat('MM-dd', 'en').format(picked);
      final dayName = DateFormat('EEEE', 'ar').format(picked);
      dateController.text = '$formatted ($dayName)';
    }
  }
}
