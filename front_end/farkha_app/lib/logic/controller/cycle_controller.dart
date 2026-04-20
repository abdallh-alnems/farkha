import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/routes/route.dart';
import '../../core/services/initialization.dart';
import '../../core/services/notification_service.dart';
import '../../data/data_source/remote/cycle_data/cycle_data.dart';
import '../../view/widget/cycle/darkness_settings_sheet.dart';
import 'cycle_custom_data_controller.dart';
import 'cycle_expenses_controller.dart';
import 'tools_controller/darkness_schedule_controller.dart';

class WeightEntry {
  final String id;
  final double weight;
  final DateTime date;

  WeightEntry({required this.id, required this.weight, required this.date});

  Map<String, dynamic> toJson() {
    return {'id': id, 'weight': weight, 'date': date.toIso8601String()};
  }

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: (json['id'] ?? '').toString(),
      weight: ((json['weight'] ?? 0.0) as num).toDouble(),
      date:
          DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

class MedicationEntry {
  final String id;
  final String text;
  final DateTime date;

  MedicationEntry({required this.id, required this.text, required this.date});

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'date': date.toIso8601String()};
  }

  factory MedicationEntry.fromJson(Map<String, dynamic> json) {
    return MedicationEntry(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      date:
          DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

class FeedConsumptionEntry {
  final String id;
  final double amount;
  final DateTime date;

  FeedConsumptionEntry({
    required this.id,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'amount': amount, 'date': date.toIso8601String()};
  }

  factory FeedConsumptionEntry.fromJson(Map<String, dynamic> json) {
    return FeedConsumptionEntry(
      id: (json['id'] ?? '').toString(),
      amount: ((json['amount'] ?? 0.0) as num).toDouble(),
      date:
          DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

class MortalityEntry {
  final String id;
  final int count;
  final DateTime date;

  MortalityEntry({required this.id, required this.count, required this.date});

  Map<String, dynamic> toJson() {
    return {'id': id, 'count': count, 'date': date.toIso8601String()};
  }

  factory MortalityEntry.fromJson(Map<String, dynamic> json) {
    return MortalityEntry(
      id: (json['id'] ?? '').toString(),
      count: ((json['count'] ?? 0) as num).toInt(),
      date:
          DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

class CycleController extends GetxController {
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

  late final CycleData _cycleData;
  late final FirebaseAuth _auth;
  late final MyServices myServices;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController countController = TextEditingController();
  final TextEditingController spaceController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController dateRawController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static const String _storageKey = 'cycles';
  static const String _deletedCyclesKey = 'deleted_cycles';

  // Data
  final RxList<Map<String, dynamic>> cycles = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> historyCycles =
      <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> currentCycle = <String, dynamic>{}.obs;

  // Edit state
  final RxBool isEdit = false.obs;
  final RxInt editIndex = (-1).obs;
  final RxBool isCreatingCycle = false.obs;

  // Flags لتتبع عمليات جلب البيانات
  final Set<int> _loadingCycleDetails = <int>{};
  bool _isCycleOpen = false;

  // حالة التحميل للدورة الحالية
  final Rx<StatusRequest> cycleDetailsStatus = StatusRequest.none.obs;

  // حالة التحميل لإنشاء/تعديل الدورة
  final Rx<StatusRequest> cycleSaveStatus = StatusRequest.none.obs;

  // Historic cycle deep tracking
  final RxMap<String, dynamic> historicCycleDetails = <String, dynamic>{}.obs;
  final Rx<StatusRequest> historicCycleStatus = StatusRequest.none.obs;

  // Pagination Variables (للسجل فقط)
  int _currentHistoryPage = 1;
  static const int _historyLimit = 5;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString filterDateFrom = ''.obs;
  final RxString filterDateTo = ''.obs;
  final ScrollController historyScrollController = ScrollController();

  // حالة التحميل لإضافة البيانات
  final Rx<StatusRequest> cycleDataStatus =
      StatusRequest.none.obs; // لتتبع ما إذا كانت هناك دورة مفتوحة حالياً

  // حالة التحميل لحذف الدورة
  final Rx<StatusRequest> cycleDeleteStatus = StatusRequest.none.obs;

  // حالة التحميل لمغادرة الدورة
  final Rx<StatusRequest> cycleLeaveStatus = StatusRequest.none.obs;

  // حالة التحميل لإنهاء الدورة
  final Rx<StatusRequest> cycleEndStatus = StatusRequest.none.obs;

  // حالة الدعوات
  final RxList<Map<String, dynamic>> invitations = <Map<String, dynamic>>[].obs;
  final Rx<StatusRequest> invitationsStatus = StatusRequest.none.obs;
  final Rx<StatusRequest> invitationResponseStatus = StatusRequest.none.obs;

  /// Incremented when cycle data changes (edit save or fetch); Cycle screen listens to refresh darkness/broiler.
  final RxInt cycleDataVersion = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _cycleData = _cycleDataOverride ?? CycleData();
    _auth = _authOverride ?? FirebaseAuth.instance;
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
    // قراءة الدورات من GetStorage (البيانات الأساسية فقط بدون تفاصيل)
    final saved = myServices.getStorage.read<List<dynamic>>(_storageKey);
    if (saved != null && saved.isNotEmpty) {
      final loadedCycles =
          saved.map((item) {
            final cycle = Map<String, dynamic>.from(
              item as Map<dynamic, dynamic>,
            );
            // حذف البيانات التفصيلية المحفوظة محلياً لضمان جلبها من السيرفر دائماً
            cycle.remove('mortalityEntries');
            cycle.remove('averageWeightEntries');
            cycle.remove('medicationEntries');
            cycle.remove('feedConsumptionEntries');
            cycle.remove('expenses');
            cycle.remove('sales');
            cycle.remove('customDataEntries');
            cycle.remove('members');
            cycle.remove('notes');
            // ضمان وجود role للدورات القديمة المحفوظة محلياً قبل إضافة الحقل
            cycle['role'] ??= 'owner';
            return cycle;
          }).toList();
      // فلترة الدورات لإخفاء الدورات المنتهية
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

  // ======================== جلب سجل الدورات ========================

  Future<void> fetchHistory({int page = 1, bool isRefresh = false}) async {
    try {
      final user = _auth.currentUser;
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

      final response = await _cycleData.getHistory(
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

                  // حساب معامل التحويل (FCR)
                  double fcr = 0.0;
                  final survivingChicks = parsedChickCount - mortality;
                  if (survivingChicks > 0 &&
                      averageWeight > 0 &&
                      totalFeed > 0) {
                    final totalMeatProduced = survivingChicks * averageWeight;
                    fcr = totalFeed / totalMeatProduced;
                  }

                  // حساب تكلفة الفرخ
                  double costPerBird = 0.0;
                  if (survivingChicks > 0 && totalExpenses > 0) {
                    costPerBird = totalExpenses / survivingChicks;
                  }

                  // حساب نسبة النفوق (%)
                  double mortalityRate = 0.0;
                  if (parsedChickCount > 0 && mortality > 0) {
                    mortalityRate = (mortality / parsedChickCount) * 100;
                  }

                  // حساب مدة الدورة (بالأيام)
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

            // تحديث الصفحة
            if (apiCycles.isNotEmpty) {
              _currentHistoryPage = page;
            }

            // إذا كانت الصفحة الأولى، استبدل القائمة بالكامل
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

            // تحقق من وجود المزيد بناءً على العدد الإجمالي
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

  // ======================== جلب الدورات النشطة ========================

  Future<void> fetchCyclesFromServer() async {
    // إذا كانت هناك دورة مفتوحة حالياً، لا تقم بجلب الدورات
    if (_isCycleOpen) {
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) return;

      final response = await _cycleData.getCycles(token: token);

      response.fold(
        (failure) {
          // في حالة الفشل، نستخدم البيانات المحلية
          // ignore
        },
        (result) {
          final data = result['data'];
          if (data != null && data['cycles'] != null) {
            final apiCycles = data['cycles'] as List;

            // تحويل الدورات من API إلى الصيغة المحلية
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

                  // تحويل التاريخ إلى صيغة عربية
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

            // دمج الدورات بدلاً من الاستبدال الكامل
            for (var convertedCycle in convertedCycles) {
              final cycleId = convertedCycle['cycle_id'];
              final existingIdx = cycles.indexWhere(
                (c) => c['cycle_id'] == cycleId,
              );

              if (existingIdx != -1) {
                // إذا كانت الدورة موجودة
                final existingCycle = cycles[existingIdx];
                final cycleIdInt =
                    cycleId is int ? cycleId : int.tryParse(cycleId.toString());

                // إذا كان fetchCycleDetails قيد التنفيذ لهذه الدورة، لا تستبدل
                if (cycleIdInt != null &&
                    _loadingCycleDetails.contains(cycleIdInt)) {
                  continue; // تخطي هذه الدورة
                }

                // التحقق من وجود بيانات أساسية (name و cycle_id)
                final hasName =
                    existingCycle['name'] != null &&
                    existingCycle['name'].toString().isNotEmpty;
                final hasCycleId = existingCycle['cycle_id'] != null;

                // إذا كانت الدورة لها بيانات أساسية، لا تستبدلها - فقط تحديث إذا كانت البيانات الأساسية مختلفة
                if (hasName && hasCycleId) {
                  // التحقق من أن البيانات الأساسية مختلفة قبل التحديث
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

                  // إذا تغيرت البيانات الأساسية، قم بتحديثها فقط مع الحفاظ على البيانات الكاملة
                  if (nameChanged ||
                      chickCountChanged ||
                      startDateRawChanged ||
                      mortalityChanged ||
                      totalExpensesChanged) {
                    cycles[existingIdx] = {
                      ...existingCycle, // احتفظ بجميع البيانات الموجودة
                      'name':
                          convertedCycle['name'], // تحديث البيانات الأساسية فقط
                      'chickCount': convertedCycle['chickCount'],
                      'startDate': convertedCycle['startDate'],
                      'startDateRaw': convertedCycle['startDateRaw'],
                      'mortality': convertedCycle['mortality'],
                      'total_expenses': convertedCycle['total_expenses'],
                      'total_sales': convertedCycle['total_sales'],
                    };
                  }
                  // إذا لم تتغير البيانات الأساسية، لا تفعل شيئاً - احتفظ بالبيانات الكاملة
                } else {
                  // إذا لم تكن هناك بيانات أساسية، استبدل بالبيانات الجديدة
                  cycles[existingIdx] = convertedCycle;
                }
              } else {
                // إذا لم تكن الدورة موجودة، أضفها
                cycles.add(convertedCycle);
              }
            }

            // إزالة الدورات التي لم تعد في قائمة الاستجابة من الـ API
            // (المستخدم غادر هذه الدورات أو تم حذفه منها)
            final convertedCycleIds =
                convertedCycles.map((c) => c['cycle_id']).toSet();
            cycles.removeWhere((cycle) {
              final cycleId = cycle['cycle_id'];
              return cycleId != null && !convertedCycleIds.contains(cycleId);
            });

            // إخطار GetX بالتغيير فوراً حتى يُحدّث الـ UI
            cycles.refresh();

            // فلترة الدورات المحذوفة محلياً (تم حذفها عند إنهائها)
            final deletedCycles =
                myServices.getStorage.read<List<dynamic>>(_deletedCyclesKey) ??
                <dynamic>[];
            if (deletedCycles.isNotEmpty) {
              cycles.removeWhere((cycle) {
                final cycleName = cycle['name']?.toString();
                return cycleName != null && deletedCycles.contains(cycleName);
              });
            }

            // لا نستبدل currentCycle إذا كان يحتوي على بيانات صحيحة
            // فقط نتأكد من أن الدورة موجودة في cycles
            if (cycles.isNotEmpty) {
              final currentCycleId = currentCycle['cycle_id'];
              final currentCycleName = currentCycle['name']?.toString();
              final hasCurrentCycleData =
                  currentCycleName != null &&
                  currentCycleName.isNotEmpty &&
                  currentCycle.isNotEmpty &&
                  currentCycleId != null;

              // إذا كانت هناك بيانات في currentCycle، تأكد من أن الدورة موجودة في cycles
              if (hasCurrentCycleData) {
                final currentIdx = cycles.indexWhere(
                  (c) => c['cycle_id'] == currentCycleId,
                );
                if (currentIdx == -1) {
                  // إذا لم تكن الدورة موجودة في cycles، أضفها
                  cycles.add(Map<String, dynamic>.from(currentCycle));
                } else {
                  // إذا كانت موجودة، تأكد من أن البيانات الكاملة محفوظة
                  final cycleInList = cycles[currentIdx];
                  final hasFullDataInList =
                      (cycleInList['mortalityEntries'] as List?)?.isNotEmpty ==
                          true ||
                      (cycleInList['averageWeightEntries'] as List?)
                              ?.isNotEmpty ==
                          true ||
                      (cycleInList['medicationEntries'] as List?)?.isNotEmpty ==
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

                  // إذا كان currentCycle يحتوي على بيانات كاملة و cycles لا يحتوي، استبدل
                  if (hasFullDataInCurrent && !hasFullDataInList) {
                    cycles[currentIdx] = Map<String, dynamic>.from(
                      currentCycle,
                    );
                  }
                }
              } else {
                // إذا لم تكن هناك بيانات في currentCycle، قم بالتحديث
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

            // حفظ الدورات في GetStorage بعد تحديثها من API
            myServices.getStorage.write(_storageKey, cycles.toList());

            // تحديث UI بعد الفلترة والحفظ
            cycles.refresh();
          }
        },
      );
    } catch (e) {
      // ignore
    } finally {
      // فحص الأتمتة بعد جلب البيانات
      _checkAndAutoEndCycles();
    }
  }

  void _checkAndAutoEndCycles() {
    if (cycles.isEmpty) return;

    // العمل على نسخة لتجنب مشاكل التعديل المتزامن
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
        // حساب العمر: اليوم الأول هو تاريخ البدء
        final age = now.difference(startD).inDays + 1;

        if (age >= 40) {
          // حساب تاريخ اليوم الـ 40 بدقة (تاريخ البدء + 39 يوماً)
          final day40 = startD.add(const Duration(days: 39));
          final autoEndDate = DateFormat('yyyy-MM-dd').format(day40);
          cyclesToEnd.add((cycle: cycle, autoEndDate: autoEndDate));
        }
      } catch (e) {
        // تجاهل أخطاء تحليل التاريخ
      }
    }

    if (cyclesToEnd.isNotEmpty) {
      _showSalesBeforeCloseDialog(cyclesToEnd, 0);
    }
  }

  /// يعرض رسالة إدخال المبيعات قبل إغلاق الدورة تلقائياً عند الوصول لعمر 40 يوماً.
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
          // إغلاق بدون مبيعات
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
          // إدخال المبيعات ثم الإغلاق
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
              // تعيين الدورة الحالية لضمان ربط المبيعات بها
              currentCycle.assignAll(cycle);
              // التأكد من تسجيل CycleExpensesController قبل الانتقال
              if (!Get.isRegistered<CycleExpensesController>()) {
                Get.put(CycleExpensesController());
              }
              // الانتقال لشاشة المبيعات والانتظار حتى يعود المستخدم
              await Get.toNamed<void>(AppRoute.cycleSales);
              // بعد العودة، أغلق الدورة
              unawaited(closeCycleAndProceed());
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> fetchCycleDetails(int cycleId, {bool silent = false}) async {
    // منع استدعاءات متعددة لنفس الدورة
    if (_loadingCycleDetails.contains(cycleId)) {
      return;
    }

    try {
      _isCycleOpen = true; // تعيين flag أن هناك دورة مفتوحة
      _loadingCycleDetails.add(cycleId);

      // تحديث حالة التحميل إلى loading (فقط إذا لم يكن silent)
      if (!silent) cycleDetailsStatus.value = StatusRequest.loading;

      final isLoggedIn =
          myServices.getStorage.read<bool>('is_logged_in') ?? false;
      if (!isLoggedIn) {
        _loadingCycleDetails.remove(cycleId);
        if (!silent) cycleDetailsStatus.value = StatusRequest.none;
        return;
      }

      final user = _auth.currentUser;
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

      final response = await _cycleData.getCycleDetails(
        token: token,
        cycleId: cycleId,
      );

      response.fold(
        (failure) {
          // في حالة الفشل، نستخدم البيانات المحلية
          _loadingCycleDetails.remove(cycleId);

          // تحديث حالة التحميل حسب نوع الفشل (فقط إذا لم يكن silent)
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
            // API يعيد البيانات بصيغة: { cycle: {...}, data: [...], expenses: [...] }
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
              // تحديث currentCycle بالبيانات من API
              final cycleDetails = _convertCycleDetailsFromApi(
                cycleData,
                cycleDataList: cycleDataList,
                expensesList: expensesList,
                membersList: membersList,
                salesList: salesList,
              );

              // البحث عن الدورة في cycles وتحديثها
              final idx = cycles.indexWhere((c) => c['cycle_id'] == cycleId);
              if (idx != -1) {
                final existing = cycles[idx];
                final merged = Map<String, dynamic>.from(cycleDetails);
                // الحفاظ على العدد إذا لم يرجعه الـ API
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
                // إذا لم تكن الدورة موجودة، أضفها
                cycles.add(Map<String, dynamic>.from(cycleDetails));
              }

              // لا نحفظ البيانات التفصيلية (مصاريف، مبيعات، بيانات) في GetStorage
              // لضمان أن كل مستخدم يرى البيانات المحدثة من قاعدة البيانات

              // تحديث currentCycle إذا كانت هذه هي الدورة الحالية
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

                  // Schedule notifications for the current cycle
                  final startDateRaw =
                      cycleDetails['startDateRaw']?.toString() ?? '';
                  if (startDateRaw.isNotEmpty) {
                    final date = DateTime.tryParse(startDateRaw);
                    if (date != null) {
                      // Pass cycleName to notification service
                      NotificationService.instance.scheduleCycleNotifications(
                        date,
                        cycleDetails['name']?.toString() ?? '',
                      );
                    }
                  }

                  // تحديث المصروفات في CycleExpensesController
                  final expenses = cycleDetails['expenses'] as List<dynamic>?;
                  if (expenses != null &&
                      expenses.isNotEmpty &&
                      Get.isRegistered<CycleExpensesController>()) {
                    try {
                      final expensesCtrl = Get.find<CycleExpensesController>();
                      expensesCtrl.reloadExpensesFromCycle();
                    } catch (e) {
                      // في حالة عدم وجود controller، لا شيء
                    }
                  }

                  // تحديث البيانات المخصصة في CycleCustomDataController
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
                      // في حالة عدم وجود controller، لا شيء
                    }
                  }
                }
              } else if (currentCycle['name'] == cycleDetails['name']) {
                // إذا كان name متطابق، قم بالتحديث أيضاً
                currentCycle.assignAll(cycleDetails);
                cycleDataVersion.value++;

                // تحديث المصروفات في CycleExpensesController
                final expenses = cycleDetails['expenses'] as List<dynamic>?;
                if (expenses != null &&
                    expenses.isNotEmpty &&
                    Get.isRegistered<CycleExpensesController>()) {
                  try {
                    final expensesCtrl = Get.find<CycleExpensesController>();
                    expensesCtrl.reloadExpensesFromCycle();
                  } catch (e) {
                    // في حالة عدم وجود controller، لا شيء
                  }
                }

                // تحديث البيانات المخصصة في CycleCustomDataController
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
                    // في حالة عدم وجود controller، لا شيء
                  }
                }
              }
            }
          }

          // تحديث حالة التحميل إلى success ثم إعادة تعيينها بعد قليل (فقط إذا لم يكن silent)
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
      // ignore
      _loadingCycleDetails.remove(cycleId);
      if (!silent) cycleDetailsStatus.value = StatusRequest.serverFailure;
      _isCycleOpen = false; // إزالة flag عند الخطأ
    }
  }

  Future<void> fetchHistoricCycleDetails(int cycleId) async {
    try {
      historicCycleStatus.value = StatusRequest.loading;

      final isLoggedIn =
          myServices.getStorage.read<bool>('is_logged_in') ?? false;
      if (!isLoggedIn) {
        historicCycleStatus.value = StatusRequest.none;
        return;
      }

      final user = _auth.currentUser;
      if (user == null) {
        historicCycleStatus.value = StatusRequest.none;
        return;
      }

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        historicCycleStatus.value = StatusRequest.none;
        return;
      }

      final response = await _cycleData.getCycleDetails(
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
              final cycleDetails = _convertCycleDetailsFromApi(
                cycleData,
                cycleDataList: cycleDataList,
                expensesList: expensesList,
                notesList: notesList,
                membersList: membersList,
                salesList: salesList,
              );

              // الابقاء على البيانات المحسوبة مسبقاً من get_history (مثل تاريخ الانتهاء، الدخل، الفوائد)
              // وإضافة القوائم التفصيلية التي جلبناها من get_cycle_details
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

  // Method لإزالة flag عند إغلاق الدورة
  void closeCycle() {
    _isCycleOpen = false;
  }

  /// إجبار إعادة تحميل تفاصيل الدورة الحالية من السيرفر (تجاوز dedup guard)
  Future<void> forceRefreshCurrentCycle() async {
    final cycleId = currentCycle['cycle_id'];
    if (cycleId == null) return;
    final cycleIdInt =
        cycleId is int ? cycleId : int.tryParse(cycleId.toString());
    if (cycleIdInt == null || cycleIdInt <= 0) return;
    // إزالة من dedup guard لضمان إعادة الجلب
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

    // تحويل التاريخ إلى صيغة عربية
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

    // تحويل cycle_data إلى entries
    final mortalityEntries = <Map<String, dynamic>>[];
    final averageWeightEntries = <Map<String, dynamic>>[];
    final medicationEntries = <Map<String, dynamic>>[];
    final feedConsumptionEntries = <Map<String, dynamic>>[];
    final waterConsumptionEntries = <Map<String, dynamic>>[];
    final customDataEntries = <Map<String, dynamic>>[];

    // معالجة cycle_data إذا كانت موجودة
    if (cycleDataList != null && cycleDataList.isNotEmpty) {
      for (var item in cycleDataList) {
        final label = item['label']?.toString() ?? '';
        final value = item['value']?.toString() ?? '';
        final entryDateStr = item['entry_date']?.toString() ?? '';

        // تحويل entry_date إلى صيغة yyyy/MM/dd

        // دعم labels بالعربية والإنجليزية
        final labelLower = label.toLowerCase().trim();
        final labelOriginal = label.trim();

        // التحقق من mortality
        final isMortality =
            labelLower == 'mortality' ||
            labelLower == 'نافق' ||
            labelLower == 'عدد النافق' ||
            labelOriginal == 'عدد النافق' ||
            (label.contains('نافق') && !label.contains('غير'));

        // التحقق من average_weight
        final isAverageWeight =
            labelLower == 'average_weight' ||
            labelLower == 'averageweight' ||
            labelOriginal == 'الوزن المتوسط' ||
            labelOriginal == 'متوسط وزن القطيع' ||
            labelLower == 'متوسط وزن القطيع' ||
            labelLower == 'الوزن المتوسط' ||
            labelLower == 'متوسط الوزن' ||
            (label.contains('وزن') && label.contains('متوسط'));

        // التحقق من medication
        final isMedication =
            labelLower == 'medication' ||
            labelOriginal == 'التحصينات' ||
            labelLower == 'التحصينات' ||
            labelLower == 'تحصين' ||
            (label.contains('تحصين') && !label.contains('غير')) ||
            label.contains('دواء');

        // التحقق من feed_consumption
        final isFeedConsumption =
            labelLower == 'feed_consumption' ||
            labelLower == 'feedconsumption' ||
            labelOriginal == 'الاستهلاك اليومي' ||
            labelOriginal == 'استهلاك العلف' ||
            labelLower == 'الاستهلاك اليومي' ||
            labelLower == 'استهلاك العلف' ||
            (label.contains('استهلاك') && !label.contains('غير')) ||
            (label.contains('علف') && label.contains('استهلاك'));

        // helper: parse entry_date string to "yyyy/MM/dd"
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
          // البيانات المخصصة بما فيها الملاحظات اليدوية التي كتبها المستخدم
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

    // حساب mortality من mortalityEntries بدلاً من استخدام القيمة من API
    final calculatedMortality = mortalityEntries.fold<int>(
      0,
      (sum, entry) =>
          sum + (int.tryParse(entry['count']?.toString() ?? '0') ?? 0),
    );

    // حساب total_expenses من cycleData إذا كان متوفراً، وإلا من expensesList
    double totalExpenses = 0.0;
    if (cycleData['total_expenses'] != null) {
      totalExpenses =
          (cycleData['total_expenses'] is num)
              ? (cycleData['total_expenses'] as num).toDouble()
              : (double.tryParse(cycleData['total_expenses'].toString()) ??
                  0.0);
    }

    // معالجة expenses إذا كانت موجودة
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

    // معالجة الملاحظات من cycle_notes
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
          // أيضاً أضفها إلى customDataEntries لتظهر في التايملاين اليومي
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

    // إذا لم يكن total_expenses محسوباً من cycleData، احسبه من processedExpenses
    if (totalExpenses == 0.0 && processedExpenses.isNotEmpty) {
      totalExpenses = processedExpenses.fold<double>(
        0.0,
        (sum, expense) => sum + ((expense['value'] as num?)?.toDouble() ?? 0.0),
      );
    }

    // حساب المبيعات من salesList
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
      // المفاتيح المتوقعة من الواجهة (cycle_history_details_screen.dart)
      'feedEntries': feedConsumptionEntries,
      'mortalityEntries': mortalityEntries,
      'weightEntries': averageWeightEntries,
      'customDataEntries': customDataEntries,
      'expenses': processedExpenses,
      'notes': processedNotes,
      // المفاتيح القديمة للتوافق مع بقية التطبيق
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

  /// تحويل سلسلة تاريخ (Y-m-d H:i:s أو ISO8601) إلى صيغة yyyy/MM/dd
  String _parseDateToString(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      // محاولة 1: صيغة ISO8601
      DateTime? parsed = DateTime.tryParse(dateStr);

      // محاولة 2: صيغة "Y-m-d H:i:s" (MySQL)
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

  /// Cancels the daily data notification for the current day
  Future<void> _cancelDailyNotification() async {
    final start = DateTime.tryParse(
      currentCycle['startDate']?.toString() ?? '',
    );
    if (start == null) return;

    final now = DateTime.now();
    // Calculate current day of cycle
    // We strive to match the logic in NotificationService loop:
    // scheduleCycleNotifications iterates i=0 to max, date = start + i days.
    // dayOfCycle = i + 1.
    // So if today is start + 0 days, dayOfCycle is 1.
    final dayOfCycle = now.difference(start).inDays + 1;

    if (dayOfCycle > 0) {
      await NotificationService.instance.cancelDailyDataNotification(
        dayOfCycle,
      );
    }
  }

  Future<void> onNext() async {
    if (cycleSaveStatus.value == StatusRequest.loading) return;
    if (!formKey.currentState!.validate()) return;

    final name = nameController.text.trim();
    final chickCount = int.tryParse(countController.text.trim()) ?? 0;
    final space = double.tryParse(spaceController.text.trim()) ?? 0.0;
    const breed = 'تسمين';
    // نستخرج systemType (إذا كانت الواجهة الأمامية سترسلها من Dropdown مثلاً، حالياً نستخدم أرضي مبدئياً ريثما نعدل UI)
    const systemType = 'أرضي'; // سيتم تعديله لاحقاً عند استخدام Dropdown
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
      // 'lastStageShown' removed
    };

    if (isEdit.value &&
        editIndex.value >= 0 &&
        editIndex.value < cycles.length) {
      cycles[editIndex.value] = entry;
      currentCycle.assignAll(entry);
      cycleDataVersion.value++;
      isEdit.value = false;
      isEdit.value = false;
      editIndex.value = -1;

      // Schedule notifications
      if (entry['startDateRaw'] != null) {
        final date = DateTime.tryParse(entry['startDateRaw'].toString());
        if (date != null) {
          NotificationService.instance.scheduleCycleNotifications(
            date,
            entry['name']?.toString() ?? '',
          );
        }
      }

      // حفظ محلياً فقط للدورات المحلية (بدون cycle_id)
      if (entry['cycle_id'] == null) {
        await myServices.getStorage.write(_storageKey, cycles.toList());
      }
      clearFields();

      Get.back<void>();
      return;
    }

    // Edit state was set but list is empty or index out of range (e.g. list cleared elsewhere) — treat as new cycle
    if (isEdit.value) {
      isEdit.value = false;
      editIndex.value = -1;
    }

    // إنشاء دورة جديدة
    // التأكد من حذف أي بيانات قديمة مرتبطة بنفس الاسم (في حالة إعادة إنشاء دورة محذوفة)
    final existingCycle = cycles.indexWhere((c) => c['name'] == name);
    if (existingCycle == -1) {
      // إذا لم تكن الدورة موجودة، حذف أي بيانات قديمة مرتبطة بنفس الاسم
      _deleteCycleRelatedData(name);
    }

    isCreatingCycle.value = true;
    cycleSaveStatus.value = StatusRequest.loading;

    try {
      // التحقق من تسجيل الدخول
      final isLoggedIn =
          myServices.getStorage.read<bool>('is_logged_in') ?? false;
      if (!isLoggedIn) {
        // إذا لم يكن المستخدم مسجل دخول، احفظ محلياً فقط
        cycles.add(entry);
        await myServices.getStorage.write(_storageKey, cycles.toList());
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

      // الحصول على Firebase token
      final user = _auth.currentUser;
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

      // استدعاء API لإنشاء الدورة
      final response = await _cycleData.createCycle(
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
          // في حالة فشل API، احفظ محلياً على أي حال
          cycles.add(entry);
          myServices.getStorage.write(_storageKey, cycles.toList());
          if (failure == StatusRequest.offlineFailure) {
            cycleSaveStatus.value = StatusRequest.offlineFailure;
          } else if (failure == StatusRequest.serverFailure) {
            cycleSaveStatus.value = StatusRequest.serverFailure;
          } else {
            cycleSaveStatus.value = StatusRequest.failure;
          }
        },
        (Map<String, dynamic> result) {
          // نجح API
          final data = result;
          final isSuccess = data['status'] == 'success';

          if (isSuccess && data['data'] != null) {
            final cycleData = data['data'] as Map<String, dynamic>;
            final cycleId = cycleData['cycle_id'];

            // إضافة cycle_id إلى الدورة
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
          myServices.getStorage.write(_storageKey, cycles.toList());
          cycleSaveStatus.value = StatusRequest.success;

          // Schedule notifications
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

      // إعادة تعيين الحالة بعد قليل
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
      // في حالة أي خطأ، احفظ محلياً
      cycles.add(entry);
      await myServices.getStorage.write(_storageKey, cycles.toList());
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

  /// حذف جميع البيانات المرتبطة بالدورة من GetStorage
  void _deleteCycleRelatedData(String cycleName) {
    try {
      // حذف المصروفات
      final expensesKey = 'expenses_$cycleName';
      if (myServices.getStorage.hasData(expensesKey)) {
        myServices.getStorage.remove(expensesKey);
      }

      // حذف البيانات المخصصة
      final customDataKey = 'custom_data_$cycleName';
      if (myServices.getStorage.hasData(customDataKey)) {
        myServices.getStorage.remove(customDataKey);
      }

      // حذف الملاحظات
      final notesKey = 'notes_$cycleName';
      if (myServices.getStorage.hasData(notesKey)) {
        myServices.getStorage.remove(notesKey);
      }
    } catch (e) {
      // في حالة الفشل، لا شيء (لا نريد أن نوقف عملية الحذف)
    }
  }

  Future<bool> deleteCurrentCycle() async {
    final idx = cycles.indexWhere((c) => c['name'] == currentCycle['name']);
    if (idx == -1) return false;

    cycleDeleteStatus.value = StatusRequest.loading;

    try {
      final cycleId = currentCycle['cycle_id'];
      final cycleName = currentCycle['name']?.toString();

      // محاولة حذف الدورة من API إذا كان cycle_id موجوداً
      bool apiDeleteFailed = false;
      if (cycleId != null) {
        try {
          final isLoggedIn =
              myServices.getStorage.read<bool>('is_logged_in') ?? false;
          if (isLoggedIn) {
            final user = _auth.currentUser;
            if (user != null) {
              final token = await user.getIdToken();
              if (token != null && token.isNotEmpty) {
                final cycleIdInt =
                    cycleId is int
                        ? cycleId
                        : int.tryParse(cycleId.toString()) ?? 0;
                if (cycleIdInt > 0) {
                  await _cycleData.deleteCycle(
                    token: token,
                    cycleId: cycleIdInt,
                  );
                }
              }
            }
          }
        } catch (e) {
          // في حالة فشل API، استمر في الحذف المحلي
          apiDeleteFailed = true;
        }
      }

      // حذف جميع البيانات المرتبطة بالدورة من GetStorage
      if (cycleName != null && cycleName.isNotEmpty) {
        _deleteCycleRelatedData(cycleName);
      }

      // Cancel notifications
      await NotificationService.instance.cancelCycleNotifications();

      // حذف الدورة محلياً
      cycles.removeAt(idx);

      // حفظ محلياً
      await myServices.getStorage.write(_storageKey, cycles.toList());

      if (cycles.isNotEmpty) {
        currentCycle.assignAll(cycles.last);
      } else {
        currentCycle.clear();
      }

      // تحديد حالة الحذف بناءً على نجاح/فشل API
      if (apiDeleteFailed) {
        cycleDeleteStatus.value = StatusRequest.serverFailure;
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (cycleDeleteStatus.value == StatusRequest.serverFailure) {
            cycleDeleteStatus.value = StatusRequest.none;
          }
        });
      } else {
        cycleDeleteStatus.value = StatusRequest.success;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (cycleDeleteStatus.value == StatusRequest.success) {
            cycleDeleteStatus.value = StatusRequest.none;
          }
        });
      }

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

    // التحقق من أن الدورة لم تنتهِ بالفعل
    if (cycleToEnd['endDateRaw'] != null &&
        cycleToEnd['endDateRaw'].toString().isNotEmpty) {
      return false;
    }

    final cycleId = cycleToEnd['cycle_id'];
    final cycleName = cycleToEnd['name']?.toString();

    // حذف الدورة من القائمة فوراً لتحديث الواجهة
    cycles.removeAt(idx);

    // مسح currentCycle إذا كانت الدورة المنتهية هي الحالية
    if (currentCycle['name'] == cycleName) {
      currentCycle.clear();
      if (cycles.isNotEmpty) {
        currentCycle.assignAll(cycles.first);
      }
    }

    // تحديث UI فوراً بعد الحذف
    cycles.refresh();

    // تحديث إضافي للتأكد من تحديث الواجهة
    unawaited(
      Future.microtask(() {
        cycles.refresh();
      }),
    );

    // Cancel notifications (in background)
    unawaited(NotificationService.instance.cancelCycleNotifications());

    // حذف الدورة محلياً فوراً قبل إرسال الطلب إلى API
    if (cycleName != null && cycleName.isNotEmpty) {
      _deleteCycleRelatedData(cycleName);

      // إضافة اسم الدورة إلى قائمة الدورات المحذوفة لمنع إعادة إضافتها من API
      final deletedCycles =
          myServices.getStorage.read<List<dynamic>>(_deletedCyclesKey) ??
          <dynamic>[];
      if (!deletedCycles.contains(cycleName)) {
        deletedCycles.add(cycleName);
        unawaited(
          myServices.getStorage.write(_deletedCyclesKey, deletedCycles),
        );
      }
    }

    // حفظ التغييرات فوراً (يمكن انتظاره لأنه ليس بطيئاً جداً، لكنه يأتي بعد تحديث الواجهة)
    await myServices.getStorage.write(_storageKey, cycles.toList());

    cycleEndStatus.value = StatusRequest.loading;

    // إرسال طلب إنهاء الدورة إلى API في الخلفية
    if (cycleId != null) {
      unawaited(_endCycleFromServerInBackground(cycleId, endDate: endDate));
    } else {
      // للدورات المحلية فقط
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
          myServices.getStorage.read<bool>('is_logged_in') ?? false;
      if (!isLoggedIn) {
        cycleEndStatus.value = StatusRequest.success;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (cycleEndStatus.value == StatusRequest.success) {
            cycleEndStatus.value = StatusRequest.none;
          }
        });
        return;
      }

      final user = _auth.currentUser;
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

      final result = await _cycleData.endCycle(
        token: token,
        cycleId: cycleIdInt,
        endDate: endDate,
      );

      result.fold(
        (failure) {
          // في حالة الفشل، لا نعيد الدورة لأنها منتهية بالفعل محلياً
          cycleEndStatus.value = StatusRequest.success;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (cycleEndStatus.value == StatusRequest.success) {
              cycleEndStatus.value = StatusRequest.none;
            }
          });
        },
        (response) {
          // التحقق من نجاح العملية من API
          if (response['status'] == 'success') {
            cycleEndStatus.value = StatusRequest.success;
            Future.delayed(const Duration(milliseconds: 500), () {
              if (cycleEndStatus.value == StatusRequest.success) {
                cycleEndStatus.value = StatusRequest.none;
              }
            });
          } else {
            // في حالة الفشل، لا نعيد الدورة لأنها منتهية بالفعل محلياً
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
      // في حالة الخطأ، لا نعيد الدورة لأنها منتهية بالفعل محلياً
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

  Future<void> updateCycleData({
    String? mortality,
    String? averageWeight,
    String? medication,
    String? feedConsumption,
  }) async {
    final cycleName = currentCycle['name'];
    if (cycleName == null) return;

    final idx = cycles.indexWhere((c) => c['name'] == cycleName);
    if (idx == -1) return;

    if (mortality != null) {
      cycles[idx]['mortality'] = mortality;
      currentCycle['mortality'] = mortality;
    }

    if (averageWeight != null) {
      cycles[idx]['averageWeight'] = averageWeight;
      currentCycle['averageWeight'] = averageWeight;
    }

    if (medication != null) {
      cycles[idx]['medication'] = medication;
      currentCycle['medication'] = medication;
    }

    if (feedConsumption != null) {
      cycles[idx]['feedConsumption'] = feedConsumption;
      currentCycle['feedConsumption'] = feedConsumption;
    }

    // حفظ محلياً فقط للدورات المحلية (بدون cycle_id)
    if (cycles[idx]['cycle_id'] == null) {
      await myServices.getStorage.write(_storageKey, cycles.toList());
    }
  }

  List<WeightEntry> getAverageWeightEntries() {
    final cycle = currentCycle;
    final entriesData = cycle['averageWeightEntries'] as List<dynamic>?;
    if (entriesData == null) return [];
    return entriesData
        .map((e) => WeightEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _sendDataToServer({
    required String label,
    required String value,
  }) async {
    try {
      final cycleId = currentCycle['cycle_id'];
      if (cycleId == null) {
        return; // إذا لم يكن cycle_id موجوداً، لا ترسل إلى API
      }

      final isLoggedIn =
          myServices.getStorage.read<bool>('is_logged_in') ?? false;
      if (!isLoggedIn) return;

      final user = _auth.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) return;

      await _cycleData.addCycleData(
        token: token,
        cycleId:
            cycleId is int ? cycleId : int.tryParse(cycleId.toString()) ?? 0,
        label: label,
        value: value,
      );
    } catch (e) {
      // في حالة الفشل، لا نفعل شيئاً - البيانات محفوظة محلياً
    }
  }

  void _deleteItemFromServerInBackground({
    required String type,
    required String deleteType,
    int? itemId,
    String? label,
    required dynamic cycleId,
  }) {
    // تنفيذ الحذف من API في الخلفية
    Future<void>(() async {
      try {
        final isLoggedIn =
            myServices.getStorage.read<bool>('is_logged_in') ?? false;
        if (!isLoggedIn) return;

        final user = _auth.currentUser;
        if (user == null) return;

        final token = await user.getIdToken();
        if (token == null || token.isEmpty) return;

        await _cycleData.deleteCycleItem(
          token: token,
          cycleId:
              cycleId is int ? cycleId : int.tryParse(cycleId.toString()) ?? 0,
          type: type,
          deleteType: deleteType,
          itemId: itemId,
          label: label,
        );

        // بعد نجاح الحذف، إعادة تحميل البيانات من API
        final cycleIdInt =
            cycleId is int ? cycleId : int.tryParse(cycleId.toString());
        if (cycleIdInt != null && cycleIdInt > 0) {
          await fetchCycleDetails(cycleIdInt);
        }
      } catch (e) {
        // في حالة الفشل، لا شيء
      }
    });
  }

  Future<void> addAverageWeightEntry(double weight) async {
    final cycleName = currentCycle['name'];
    if (cycleName == null) return;

    final idx = cycles.indexWhere((c) => c['name'] == cycleName);
    if (idx == -1) return;

    cycleDataStatus.value = StatusRequest.loading;

    try {
      final entries = getAverageWeightEntries();
      final now = DateTime.now();
      final newEntry = WeightEntry(
        id: now.millisecondsSinceEpoch.toString(),
        weight: weight,
        date: now,
      );
      entries.add(newEntry);

      cycles[idx]['averageWeightEntries'] =
          entries.map((e) => e.toJson()).toList();
      currentCycle['averageWeightEntries'] =
          entries.map((e) => e.toJson()).toList();

      // حفظ آخر وزن كقيمة averageWeight للتوافق مع الكود القديم
      cycles[idx]['averageWeight'] = weight.toString();
      currentCycle['averageWeight'] = weight.toString();

      // تحديث cycles لضمان إعادة بناء الواجهة
      cycles.refresh();

      // حفظ في GetStorage دائماً (للدورات المحلية والمن API)
      await myServices.getStorage.write(_storageKey, cycles.toList());

      // إرسال البيانات إلى API
      await _sendDataToServer(
        label: 'متوسط وزن القطيع',
        value: weight.toString(),
      );

      cycleDataStatus.value = StatusRequest.success;
      // إعادة تعيين الحالة بعد قليل
      Future.delayed(const Duration(milliseconds: 500), () {
        if (cycleDataStatus.value == StatusRequest.success) {
          cycleDataStatus.value = StatusRequest.none;
        }
      });
    } catch (e) {
      cycleDataStatus.value = StatusRequest.serverFailure;
      Future.delayed(const Duration(milliseconds: 2000), () {
        cycleDataStatus.value = StatusRequest.none;
      });
    }
  }

  Future<void> removeAverageWeightEntry(String entryId) async {
    final cycleName = currentCycle['name'];
    if (cycleName == null) return;

    final idx = cycles.indexWhere((c) => c['name'] == cycleName);
    if (idx == -1) return;

    // الحذف المحلي فوراً
    final entries = getAverageWeightEntries();
    entries.removeWhere((e) => e.id == entryId);

    cycles[idx]['averageWeightEntries'] =
        entries.map((e) => e.toJson()).toList();
    currentCycle['averageWeightEntries'] =
        entries.map((e) => e.toJson()).toList();

    // تحديث آخر وزن
    if (entries.isNotEmpty) {
      final lastWeight = entries.last.weight;
      cycles[idx]['averageWeight'] = lastWeight.toString();
      currentCycle['averageWeight'] = lastWeight.toString();
    } else {
      cycles[idx]['averageWeight'] = '';
      currentCycle['averageWeight'] = '';
    }

    cycles.refresh();

    // حفظ محلياً
    unawaited(myServices.getStorage.write(_storageKey, cycles.toList()));

    // حذف من API في الخلفية
    final cycleId = currentCycle['cycle_id'];
    final itemId = int.tryParse(entryId);

    if (itemId != null && itemId > 0 && cycleId != null) {
      _deleteItemFromServerInBackground(
        type: 'data',
        deleteType: 'single',
        itemId: itemId,
        cycleId: cycleId,
      );
    }
  }

  List<MedicationEntry> getMedicationEntries() {
    final cycle = currentCycle;
    final entriesData = cycle['medicationEntries'] as List<dynamic>?;
    if (entriesData == null) return [];
    return entriesData
        .map((e) => MedicationEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addMedicationEntry(String text) async {
    final cycleName = currentCycle['name'];
    if (cycleName == null) return;

    final idx = cycles.indexWhere((c) => c['name'] == cycleName);
    if (idx == -1) return;

    cycleDataStatus.value = StatusRequest.loading;

    try {
      final entries = getMedicationEntries();
      final now = DateTime.now();
      final newEntry = MedicationEntry(
        id: now.millisecondsSinceEpoch.toString(),
        text: text,
        date: now,
      );
      entries.add(newEntry);

      cycles[idx]['medicationEntries'] =
          entries.map((e) => e.toJson()).toList();
      currentCycle['medicationEntries'] =
          entries.map((e) => e.toJson()).toList();

      // حفظ آخر نص كقيمة medication للتوافق مع الكود القديم
      cycles[idx]['medication'] = text;
      currentCycle['medication'] = text;

      // تحديث cycles لضمان إعادة بناء الواجهة
      cycles.refresh();

      // حفظ في GetStorage دائماً (للدورات المحلية والمن API)
      await myServices.getStorage.write(_storageKey, cycles.toList());

      // إرسال البيانات إلى API
      await _sendDataToServer(label: 'التحصينات', value: text);

      cycleDataStatus.value = StatusRequest.success;
      // إعادة تعيين الحالة بعد قليل
      Future.delayed(const Duration(milliseconds: 500), () {
        if (cycleDataStatus.value == StatusRequest.success) {
          cycleDataStatus.value = StatusRequest.none;
        }
      });
    } catch (e) {
      cycleDataStatus.value = StatusRequest.serverFailure;
      Future.delayed(const Duration(milliseconds: 2000), () {
        cycleDataStatus.value = StatusRequest.none;
      });
    }
  }

  Future<void> removeMedicationEntry(String entryId) async {
    final cycleName = currentCycle['name'];
    if (cycleName == null) return;

    final idx = cycles.indexWhere((c) => c['name'] == cycleName);
    if (idx == -1) return;

    // الحذف المحلي فوراً
    final entries = getMedicationEntries();
    entries.removeWhere((e) => e.id == entryId);

    cycles[idx]['medicationEntries'] = entries.map((e) => e.toJson()).toList();
    currentCycle['medicationEntries'] = entries.map((e) => e.toJson()).toList();

    // تحديث آخر نص
    if (entries.isNotEmpty) {
      final lastText = entries.last.text;
      cycles[idx]['medication'] = lastText;
      currentCycle['medication'] = lastText;
    } else {
      cycles[idx]['medication'] = '';
      currentCycle['medication'] = '';
    }

    cycles.refresh();

    // حفظ محلياً
    unawaited(myServices.getStorage.write(_storageKey, cycles.toList()));

    // حذف من API في الخلفية
    final cycleId = currentCycle['cycle_id'];
    final itemId = int.tryParse(entryId);

    if (itemId != null && itemId > 0 && cycleId != null) {
      _deleteItemFromServerInBackground(
        type: 'data',
        deleteType: 'single',
        itemId: itemId,
        cycleId: cycleId,
      );
    }
  }

  List<FeedConsumptionEntry> getFeedConsumptionEntries() {
    final cycle = currentCycle;
    final entriesData = cycle['feedConsumptionEntries'] as List<dynamic>?;
    if (entriesData == null) return [];
    return entriesData
        .map((e) => FeedConsumptionEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFeedConsumptionEntry(double amount) async {
    final cycleName = currentCycle['name'];
    if (cycleName == null) return;

    final idx = cycles.indexWhere((c) => c['name'] == cycleName);
    if (idx == -1) return;

    cycleDataStatus.value = StatusRequest.loading;

    try {
      final entries = getFeedConsumptionEntries();
      final now = DateTime.now();
      final newEntry = FeedConsumptionEntry(
        id: now.millisecondsSinceEpoch.toString(),
        amount: amount,
        date: now,
      );
      entries.add(newEntry);

      cycles[idx]['feedConsumptionEntries'] =
          entries.map((e) => e.toJson()).toList();
      currentCycle['feedConsumptionEntries'] =
          entries.map((e) => e.toJson()).toList();

      // حفظ آخر قيمة كقيمة feedConsumption للتوافق مع الكود القديم
      cycles[idx]['feedConsumption'] = amount.toString();
      currentCycle['feedConsumption'] = amount.toString();

      // تحديث cycles لضمان إعادة بناء الواجهة
      cycles.refresh();

      // حفظ في GetStorage دائماً (للدورات المحلية والمن API)
      await myServices.getStorage.write(_storageKey, cycles.toList());

      // إرسال البيانات إلى API
      await _sendDataToServer(label: 'استهلاك العلف', value: amount.toString());

      // Cancel daily notification if data is entered
      await _cancelDailyNotification();

      cycleDataStatus.value = StatusRequest.success;

      cycleDataStatus.value = StatusRequest.success;
      // إعادة تعيين الحالة بعد قليل
      Future.delayed(const Duration(milliseconds: 500), () {
        if (cycleDataStatus.value == StatusRequest.success) {
          cycleDataStatus.value = StatusRequest.none;
        }
      });
    } catch (e) {
      cycleDataStatus.value = StatusRequest.serverFailure;
      Future.delayed(const Duration(milliseconds: 2000), () {
        cycleDataStatus.value = StatusRequest.none;
      });
    }
  }

  Future<void> removeFeedConsumptionEntry(String entryId) async {
    final cycleName = currentCycle['name'];
    if (cycleName == null) return;

    final idx = cycles.indexWhere((c) => c['name'] == cycleName);
    if (idx == -1) return;

    // الحذف المحلي فوراً
    final entries = getFeedConsumptionEntries();
    entries.removeWhere((e) => e.id == entryId);

    cycles[idx]['feedConsumptionEntries'] =
        entries.map((e) => e.toJson()).toList();
    currentCycle['feedConsumptionEntries'] =
        entries.map((e) => e.toJson()).toList();

    // تحديث آخر قيمة
    if (entries.isNotEmpty) {
      final lastAmount = entries.last.amount;
      cycles[idx]['feedConsumption'] = lastAmount.toString();
      currentCycle['feedConsumption'] = lastAmount.toString();
    } else {
      cycles[idx]['feedConsumption'] = '';
      currentCycle['feedConsumption'] = '';
    }

    cycles.refresh();

    // حفظ محلياً
    unawaited(myServices.getStorage.write(_storageKey, cycles.toList()));

    // حذف من API في الخلفية
    final cycleId = currentCycle['cycle_id'];
    final itemId = int.tryParse(entryId);

    if (itemId != null && itemId > 0 && cycleId != null) {
      _deleteItemFromServerInBackground(
        type: 'data',
        deleteType: 'single',
        itemId: itemId,
        cycleId: cycleId,
      );
    }
  }

  List<MortalityEntry> getMortalityEntries() {
    final cycle = currentCycle;
    final entriesData = cycle['mortalityEntries'];
    if (entriesData == null) return [];
    // التحقق من أن البيانات هي List وليس String
    if (entriesData is! List) return [];
    return entriesData
        .map((e) {
          if (e is Map<String, dynamic>) {
            return MortalityEntry.fromJson(e);
          }
          return null;
        })
        .whereType<MortalityEntry>()
        .toList();
  }

  Future<void> addMortalityEntry(int count) async {
    final cycleName = currentCycle['name'];
    if (cycleName == null) return;

    final idx = cycles.indexWhere((c) => c['name'] == cycleName);
    if (idx == -1) return;

    cycleDataStatus.value = StatusRequest.loading;

    try {
      final entries = getMortalityEntries();
      final now = DateTime.now();
      final newEntry = MortalityEntry(
        id: now.millisecondsSinceEpoch.toString(),
        count: count,
        date: now,
      );
      entries.add(newEntry);

      final entriesList = entries.map((e) => e.toJson()).toList();

      // حساب الإجمالي من جميع المدخلات
      final total = entries.fold<int>(0, (sum, e) => sum + e.count);

      // التأكد من أن mortalityEntries موجود وليس String
      // إنشاء نسخة جديدة من الـ Map لضمان التحديث الصحيح
      cycles[idx] = {
        ...cycles[idx],
        'mortalityEntries': entriesList,
        'mortality': total.toString(),
      };

      currentCycle.assignAll({
        ...currentCycle,
        'mortalityEntries': entriesList,
        'mortality': total.toString(),
      });

      // تحديث cycles لضمان إعادة بناء الواجهة
      cycles.refresh();

      // حفظ في GetStorage دائماً (للدورات المحلية والمن API)
      await myServices.getStorage.write(_storageKey, cycles.toList());

      // إرسال البيانات إلى API
      await _sendDataToServer(label: 'عدد النافق', value: count.toString());

      cycleDataStatus.value = StatusRequest.success;
      // إعادة تعيين الحالة بعد قليل
      Future.delayed(const Duration(milliseconds: 500), () {
        if (cycleDataStatus.value == StatusRequest.success) {
          cycleDataStatus.value = StatusRequest.none;
        }
      });
    } catch (e) {
      cycleDataStatus.value = StatusRequest.serverFailure;
      Future.delayed(const Duration(milliseconds: 2000), () {
        cycleDataStatus.value = StatusRequest.none;
      });
    }
  }

  Future<void> removeMortalityEntry(String entryId) async {
    final cycleName = currentCycle['name'];
    if (cycleName == null) return;

    final idx = cycles.indexWhere((c) => c['name'] == cycleName);
    if (idx == -1) return;

    // الحذف المحلي فوراً
    final entries = getMortalityEntries();
    entries.removeWhere((e) => e.id == entryId);

    final entriesList = entries.map((e) => e.toJson()).toList();

    // حساب الإجمالي من جميع المدخلات المتبقية
    final total =
        entries.isNotEmpty
            ? entries.fold<int>(0, (sum, e) => sum + e.count)
            : 0;

    // إنشاء نسخة جديدة من الـ Map لضمان التحديث الصحيح
    cycles[idx] = {
      ...cycles[idx],
      'mortalityEntries': entriesList,
      'mortality': total.toString(),
    };

    currentCycle.assignAll({
      ...currentCycle,
      'mortalityEntries': entriesList,
      'mortality': total.toString(),
    });

    cycles.refresh();

    // حفظ محلياً
    unawaited(myServices.getStorage.write(_storageKey, cycles.toList()));

    // حذف من API في الخلفية
    final cycleId = currentCycle['cycle_id'];
    final itemId = int.tryParse(entryId);

    if (itemId != null && itemId > 0 && cycleId != null) {
      _deleteItemFromServerInBackground(
        type: 'data',
        deleteType: 'single',
        itemId: itemId,
        cycleId: cycleId,
      );
    }
  }

  // ======================== إدارة الأعضاء = [NEW] ========================

  Future<Map<String, dynamic>?> addMember({
    required int cycleId,
    required String phone,
    String role = 'member',
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      final token = await user.getIdToken();
      if (token == null || token.isEmpty) return null;

      final response = await _cycleData.addMember(
        token: token,
        cycleId: cycleId,
        phone: phone,
        role: role,
      );

      return response.fold(
        (failure) {
          return {'status': 'fail', 'message': 'فشل الاتصال بالسيرفر'};
        },
        (result) {
          return result;
        },
      );
    } catch (e) {
      return {'status': 'fail', 'message': 'حدث خطأ: $e'};
    }
  }

  Future<Map<String, dynamic>?> addMemberByPhone(
    String phone, {
    int? cycleId,
    String role = 'member',
  }) async {
    final effectiveCycleId =
        cycleId ??
        (currentCycle['cycle_id'] is int
            ? currentCycle['cycle_id'] as int
            : int.tryParse(currentCycle['cycle_id']?.toString() ?? ''));

    if (effectiveCycleId == null) {
      return {'status': 'fail', 'message': 'لا توجد دورة محددة'};
    }

    final result = await addMember(
      cycleId: effectiveCycleId,
      phone: phone,
      role: role,
    );
    if (result != null) {
      if (result['status'] == 'success') {
        // تحديث تفاصيل الدورة لإظهار العضو الجديد مع حالة pending
        await fetchCycleDetails(effectiveCycleId);
      }
    }
    return result;
  }

  Future<void> leaveCycle() async {
    try {
      final cycleId = currentCycle['cycle_id'];
      if (cycleId == null) return;
      final cycleIdInt =
          cycleId is int ? cycleId : int.tryParse(cycleId.toString());
      if (cycleIdInt == null) return;

      cycleLeaveStatus.value = StatusRequest.loading;
      final user = _auth.currentUser;
      if (user == null) {
        cycleLeaveStatus.value = StatusRequest.failure;
        return;
      }
      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        cycleLeaveStatus.value = StatusRequest.failure;
        return;
      }

      final response = await _cycleData.leaveCycle(
        token: token,
        cycleId: cycleIdInt,
      );

      response.fold(
        (l) {
          // API call failed - log for debugging
          print('❌ Leave Cycle API Failed: $l');
          cycleLeaveStatus.value = l;
        },
        (r) {
          print('✅ Leave Cycle Response: $r');
          print('📊 Rows deleted from DB: ${r['rows_deleted'] ?? 0}');
          if (r['status'] == 'success') {
            print('✅ Successfully left cycle $cycleIdInt');
            cycleLeaveStatus.value = StatusRequest.success;
            _isCycleOpen = false;
            fetchCyclesFromServer();
            Get.offAllNamed<void>(AppRoute.home);
            // Show snackbar with longer delay after navigation completes
            Future.delayed(const Duration(milliseconds: 800), () {
              Get.snackbar(
                'نجاح',
                'تمت مغادرة الدورة بنجاح',
                snackPosition: SnackPosition.BOTTOM,
              );
            });
          } else {
            // API returned fail status
            print('❌ Leave Cycle API Error: ${r['message']}');
            if (r['debug_error'] != null) {
              print('🔧 Debug Error: ${r['debug_error']}');
              print(
                '🔧 Debug File: ${r['debug_file']} at line ${r['debug_line']}',
              );
            }
            cycleLeaveStatus.value = StatusRequest.failure;
          }
        },
      );
    } catch (e) {
      cycleLeaveStatus.value = StatusRequest.serverFailure;
    }
  }

  Future<void> removeMember(int targetUserId) async {
    final int? cycleId =
        currentCycle['cycle_id'] is int
            ? currentCycle['cycle_id'] as int
            : int.tryParse(currentCycle['cycle_id']?.toString() ?? '');
    if (cycleId == null) return;

    unawaited(
      Get.defaultDialog<void>(
        title: 'حذف عضو',
        middleText: 'هل أنت متأكد من حذف هذا العضو من الدورة؟',
        textConfirm: 'حذف',
        textCancel: 'إلغاء',
        confirmTextColor: Colors.white,
        buttonColor: Colors.red,
        onConfirm: () async {
          Get.back<void>();
          final user = _auth.currentUser;
          if (user == null) return;
          final token = await user.getIdToken();
          if (token == null) return;

          cycleLeaveStatus.value = StatusRequest.loading;
          update();

          final response = await _cycleData.removeMember(
            token: token,
            cycleId: cycleId,
            targetUserId: targetUserId,
          );

          response.fold(
            (failure) {
              cycleLeaveStatus.value = StatusRequest.serverFailure;
              update();
              Get.snackbar('خطأ', 'فشل الاتصال بالسيرفر');
            },
            (result) {
              if (result['status'] == 'success') {
                // تحديث قائمة الأعضاء في currentCycle
                bool matchMember(dynamic m) {
                  final rawId = (m as Map)['id'] ?? m['user_id'];
                  final memberId =
                      rawId is int
                          ? rawId
                          : int.tryParse(rawId?.toString() ?? '');
                  return memberId == targetUserId;
                }

                final List<dynamic> currentMembers = List<dynamic>.from(
                  currentCycle['members'] as List? ?? [],
                );
                currentMembers.removeWhere(matchMember);
                currentCycle['members'] = currentMembers;
                currentCycle.refresh();

                // تحديث cycles list أيضاً
                final cycleIdx = cycles.indexWhere((c) {
                  final cId = c['cycle_id'];
                  final cIdInt =
                      cId is int ? cId : int.tryParse(cId?.toString() ?? '');
                  return cIdInt == cycleId;
                });
                if (cycleIdx != -1) {
                  final cycleMap = Map<String, dynamic>.from(cycles[cycleIdx]);
                  final cycleMembers = List<dynamic>.from(
                    cycleMap['members'] as List? ?? [],
                  );
                  cycleMembers.removeWhere(matchMember);
                  cycleMap['members'] = cycleMembers;
                  cycles[cycleIdx] = cycleMap;
                }

                Get.snackbar('نجاح', 'تم حذف العضو بنجاح');
              } else {
                Get.snackbar(
                  'تنبيه',
                  (result['message'] ?? 'فشل حذف العضو').toString(),
                );
              }
              cycleLeaveStatus.value = StatusRequest.none;
              update();
            },
          );
        },
      ),
    );
  }

  /// إزالة عضو مباشرة بدون dialog تأكيد — يرجع نتيجة ليعرضها الـ UI
  Future<Map<String, dynamic>> removeMemberDirect(int targetUserId) async {
    final int? cycleId =
        currentCycle['cycle_id'] is int
            ? currentCycle['cycle_id'] as int
            : int.tryParse(currentCycle['cycle_id']?.toString() ?? '');
    if (cycleId == null) {
      return {'status': 'fail', 'message': 'تعذر تحديد الدورة'};
    }

    final user = _auth.currentUser;
    if (user == null) return {'status': 'fail', 'message': 'غير مسجل'};
    final token = await user.getIdToken();
    if (token == null) return {'status': 'fail', 'message': 'فشل التوثق'};

    cycleLeaveStatus.value = StatusRequest.loading;
    update();

    final response = await _cycleData.removeMember(
      token: token,
      cycleId: cycleId,
      targetUserId: targetUserId,
    );

    return response.fold(
      (failure) {
        cycleLeaveStatus.value = StatusRequest.serverFailure;
        update();
        return {'status': 'fail', 'message': 'فشل الاتصال بالسيرفر'};
      },
      (result) {
        if (result['status'] == 'success') {
          bool matchMember(dynamic m) {
            final rawId = (m as Map)['id'] ?? m['user_id'];
            final memberId =
                rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
            return memberId == targetUserId;
          }

          final currentMembers = List<dynamic>.from(
            currentCycle['members'] as List? ?? [],
          );
          currentMembers.removeWhere(matchMember);
          currentCycle['members'] = currentMembers;
          currentCycle.refresh();

          final cycleIdx = cycles.indexWhere((c) {
            final cId = c['cycle_id'];
            final cIdInt =
                cId is int ? cId : int.tryParse(cId?.toString() ?? '');
            return cIdInt == cycleId;
          });
          if (cycleIdx != -1) {
            final cycleMap = Map<String, dynamic>.from(cycles[cycleIdx]);
            final cycleMembers = List<dynamic>.from(
              cycleMap['members'] as List? ?? [],
            );
            cycleMembers.removeWhere(matchMember);
            cycleMap['members'] = cycleMembers;
            cycles[cycleIdx] = cycleMap;
          }

          cycleLeaveStatus.value = StatusRequest.none;
          update();
          return {'status': 'success', 'message': 'تم حذف العضو بنجاح'};
        } else {
          cycleLeaveStatus.value = StatusRequest.none;
          update();
          return {
            'status': 'fail',
            'message': (result['message'] ?? 'فشل حذف العضو').toString(),
          };
        }
      },
    );
  }

  Future<Map<String, dynamic>?> createInvitation(int cycleId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      final token = await user.getIdToken();
      if (token == null || token.isEmpty) return null;

      final response = await _cycleData.createInvitation(
        token: token,
        cycleId: cycleId,
      );

      return response.fold(
        (failure) {
          return {'status': 'fail', 'message': 'فشل إنشاء رابط الدعوة'};
        },
        (result) {
          return result;
        },
      );
    } catch (e) {
      return {'status': 'fail', 'message': 'حدث خطأ: $e'};
    }
  }

  Future<void> joinByCode(String code) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('خطأ', 'يجب تسجيل الدخول أولاً');
        return;
      }
      final token = await user.getIdToken();
      if (token == null || token.isEmpty) return;

      final response = await _cycleData.joinByCode(token: token, code: code);

      response.fold(
        (failure) {
          Get.snackbar('خطأ', 'فشل الاتصال بالسيرفر');
        },
        (result) {
          if (result['status'] == 'success') {
            Get.snackbar(
              'نجاح',
              result['message']?.toString() ?? 'تم الانضمام بنجاح',
            );
            fetchCyclesFromServer();
          } else {
            Get.snackbar('فشل', result['message']?.toString() ?? 'حدث خطأ');
          }
        },
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back<void>();
      Get.snackbar('خطأ', 'حدث خطأ: $e');
    }
  }

  Future<List<Map<String, dynamic>>?> searchUsers(String searchTerm) async {
    try {
      if (searchTerm.length < 2) return [];

      final user = _auth.currentUser;
      if (user == null) return null;
      final token = await user.getIdToken();
      if (token == null || token.isEmpty) return null;

      final response = await _cycleData.searchUsers(
        token: token,
        searchTerm: searchTerm,
      );

      return response.fold((failure) => null, (result) {
        if (result['status'] == 'success') {
          final data = result['data'] as List?;
          if (data != null) return List<Map<String, dynamic>>.from(data);
        }
        return null;
      });
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateMemberRole({
    required int targetUserId,
    required String newRole,
  }) async {
    final int? cycleId =
        currentCycle['cycle_id'] is int
            ? currentCycle['cycle_id'] as int
            : int.tryParse(currentCycle['cycle_id']?.toString() ?? '');
    if (cycleId == null)
      return {'status': 'fail', 'message': 'لا توجد دورة محددة'};

    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      final token = await user.getIdToken();
      if (token == null || token.isEmpty) return null;

      final response = await _cycleData.updateMemberRole(
        token: token,
        cycleId: cycleId,
        targetUserId: targetUserId,
        newRole: newRole,
      );

      return response.fold(
        (failure) => {'status': 'fail', 'message': 'فشل الاتصال بالسيرفر'},
        (result) {
          if (result['status'] == 'success') {
            // تحديث الدور محلياً في currentCycle و cycles list
            void updateInList(List<dynamic> membersList) {
              for (int i = 0; i < membersList.length; i++) {
                final m = membersList[i] as Map;
                // الـ API يرجع الـ id في حقل 'id'
                final rawId = m['id'] ?? m['user_id'];
                final memberId =
                    rawId is int
                        ? rawId
                        : int.tryParse(rawId?.toString() ?? '');
                if (memberId == targetUserId) {
                  membersList[i] = {
                    ...Map<String, dynamic>.from(m),
                    'role': newRole,
                  };
                  break;
                }
              }
            }

            final currentMembers = List<dynamic>.from(
              currentCycle['members'] as List? ?? [],
            );
            updateInList(currentMembers);
            currentCycle['members'] = currentMembers;
            currentCycle.refresh();

            // تحديث cycles list أيضاً
            final cycleIdx = cycles.indexWhere((c) {
              final cId = c['cycle_id'];
              final cIdInt =
                  cId is int ? cId : int.tryParse(cId?.toString() ?? '');
              return cIdInt == cycleId;
            });
            if (cycleIdx != -1) {
              final cycleMap = Map<String, dynamic>.from(cycles[cycleIdx]);
              final cycleMembers = List<dynamic>.from(
                cycleMap['members'] as List? ?? [],
              );
              updateInList(cycleMembers);
              cycleMap['members'] = cycleMembers;
              cycles[cycleIdx] = cycleMap;
            }
          }
          return result;
        },
      );
    } catch (e) {
      return {'status': 'fail', 'message': 'حدث خطأ: $e'};
    }
  }

  // ======================== إدارة الدعوات ========================

  Future<void> fetchInvitations() async {
    final user = _auth.currentUser;
    if (user == null) {
      invitations.clear();
      return;
    }

    invitationsStatus.value = StatusRequest.loading;

    try {
      final token = await user.getIdToken();
      if (token == null) {
        invitationsStatus.value = StatusRequest.failure;
        return;
      }

      final response = await _cycleData.getInvitations(token: token);

      response.fold(
        (failure) {
          invitationsStatus.value = failure;
        },
        (result) {
          if (result['status'] == 'success') {
            final List<dynamic> data = result['data'] as List<dynamic>? ?? [];
            invitations.assignAll(
              data.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
            );
            invitationsStatus.value = StatusRequest.success;
          } else {
            invitationsStatus.value = StatusRequest.failure;
          }
        },
      );
    } catch (e) {
      invitationsStatus.value = StatusRequest.serverFailure;
    }
  }

  Future<Map<String, dynamic>?> respondToInvitation(
    int cycleId,
    String action,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    invitationResponseStatus.value = StatusRequest.loading;

    try {
      final token = await user.getIdToken();
      if (token == null) {
        invitationResponseStatus.value = StatusRequest.failure;
        return {'status': 'fail', 'message': 'فشل المصادقة'};
      }

      final response = await _cycleData.respondToInvitation(
        token: token,
        cycleId: cycleId,
        action: action,
      );

      return response.fold(
        (failure) {
          invitationResponseStatus.value = failure;
          return {'status': 'fail', 'message': 'فشل تنفيذ العملية'};
        },
        (result) {
          if (result['status'] == 'success') {
            invitationResponseStatus.value = StatusRequest.success;
            invitations.removeWhere((inv) => inv['cycle_id'] == cycleId);

            if (action == 'accept') {
              fetchCyclesFromServer();
            }

            return {
              'status': 'success',
              'message':
                  action == 'accept' ? 'تم قبول الدعوة بنجاح' : 'تم رفض الدعوة',
            };
          } else {
            invitationResponseStatus.value = StatusRequest.failure;
            return {
              'status': 'fail',
              'message': (result['message'] ?? 'فشل تنفيذ العملية').toString(),
            };
          }
        },
      );
    } catch (e) {
      invitationResponseStatus.value = StatusRequest.serverFailure;
      return {'status': 'fail', 'message': 'حدث خطأ غير متوقع'};
    }
  }
}
