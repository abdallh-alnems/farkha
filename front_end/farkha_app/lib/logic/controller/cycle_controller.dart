import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/routes/route.dart';
import '../../core/services/initialization.dart';
import '../../data/data_source/remote/cycle_data/cycle_data.dart';
import 'cycle_custom_data_controller.dart';
import 'cycle_expenses_controller.dart';

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
      id: json['id'] ?? '',
      weight: (json['weight'] ?? 0.0).toDouble(),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
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
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
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
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
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
      id: json['id'] ?? '',
      count: (json['count'] ?? 0) as int,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }
}

class CycleController extends GetxController {
  final MyServices myServices = Get.find<MyServices>();
  late final CycleData _cycleData;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
  
  // حالة التحميل لإضافة البيانات
  final Rx<StatusRequest> cycleDataStatus = StatusRequest.none.obs; // لتتبع ما إذا كانت هناك دورة مفتوحة حالياً
  
  // حالة التحميل لحذف الدورة
  final Rx<StatusRequest> cycleDeleteStatus = StatusRequest.none.obs;
  
  // حالة التحميل لإنهاء الدورة
  final Rx<StatusRequest> cycleEndStatus = StatusRequest.none.obs;

  @override
  void onInit() {
    super.onInit();
    _cycleData = CycleData();
    _loadCycles();
  }

  void _loadCycles() {
    // قراءة الدورات من GetStorage فقط (لا يتم استدعاء API هنا)
    // getCycles يتم استدعاؤه فقط عند تسجيل الدخول في LoginController
    final saved = myServices.getStorage.read<List>(_storageKey);
    if (saved != null && saved.isNotEmpty) {
      final loadedCycles = saved.map((item) => Map<String, dynamic>.from(item)).toList();
      // فلترة الدورات لإخفاء الدورات المنتهية
      cycles.value = loadedCycles.where((cycle) {
        final status = cycle['status']?.toString();
        return status != 'finished';
      }).toList();
      if (cycles.isNotEmpty) {
        currentCycle.assignAll(cycles.first);
      }
    }
  }

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
        },
        (result) {
          final data = result['data'];
          if (data != null && data['cycles'] != null) {
            final apiCycles = data['cycles'] as List;

            // تحويل الدورات من API إلى الصيغة المحلية وفلترة الدورات المنتهية
            final convertedCycles =
                apiCycles.where((cycle) {
                  // فلترة الدورات المنتهية
                  final status = cycle['status']?.toString();
                  return status != 'finished';
                }).map<Map<String, dynamic>>((cycle) {
                  final cycleId = cycle['id'];
                  final name = cycle['name'] ?? '';
                  final chickCount = cycle['chick_count']?.toString() ?? '0';
                  final startDateRaw = cycle['start_date_raw'] ?? '';
                  final mortality = cycle['mortality']?.toString() ?? '0';
                  final totalExpenses =
                      (cycle['total_expenses'] ?? 0).toString();

                  // تحويل التاريخ إلى صيغة عربية
                  String startDate = '';
                  if (startDateRaw.isNotEmpty) {
                    try {
                      final date = DateTime.parse(startDateRaw);
                      final formatter = DateFormat('yyyy/MM/dd', 'ar');
                      startDate = formatter.format(date);
                    } catch (e) {
                      startDate = startDateRaw;
                    }
                  }

                  return {
                    'cycle_id': cycleId,
                    'name': name,
                    'chickCount': chickCount,
                    'startDate': startDate,
                    'startDateRaw': startDateRaw,
                    'mortality': mortality,
                    'total_expenses': totalExpenses,
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

            // فلترة الدورات المنتهية بعد الدمج
            cycles.removeWhere((cycle) {
              final status = cycle['status']?.toString();
              return status == 'finished';
            });
            
            // فلترة الدورات المحذوفة محلياً (تم حذفها عند إنهائها)
            final deletedCycles = myServices.getStorage.read<List>(_deletedCyclesKey) ?? [];
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
      // في حالة حدوث خطأ، نستخدم البيانات المحلية
    }
  }

  Future<void> fetchCycleDetails(int cycleId) async {
    // منع استدعاءات متعددة لنفس الدورة
    if (_loadingCycleDetails.contains(cycleId)) {
      return;
    }

    try {
      _isCycleOpen = true; // تعيين flag أن هناك دورة مفتوحة
      _loadingCycleDetails.add(cycleId);
      
      // تحديث حالة التحميل إلى loading
      cycleDetailsStatus.value = StatusRequest.loading;

      final isLoggedIn =
          myServices.getStorage.read<bool>('is_logged_in') ?? false;
      if (!isLoggedIn) {
        _loadingCycleDetails.remove(cycleId);
        cycleDetailsStatus.value = StatusRequest.none;
        return;
      }

      final user = _auth.currentUser;
      if (user == null) {
        _loadingCycleDetails.remove(cycleId);
        cycleDetailsStatus.value = StatusRequest.none;
        return;
      }

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        _loadingCycleDetails.remove(cycleId);
        cycleDetailsStatus.value = StatusRequest.none;
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
          
          // تحديث حالة التحميل حسب نوع الفشل
          if (failure == StatusRequest.offlineFailure) {
            cycleDetailsStatus.value = StatusRequest.offlineFailure;
          } else if (failure == StatusRequest.serverFailure) {
            cycleDetailsStatus.value = StatusRequest.serverFailure;
          } else {
            cycleDetailsStatus.value = StatusRequest.failure;
          }
        },
        (result) {
          final responseData = result['data'];
          if (responseData != null) {
            // API يعيد البيانات بصيغة: { cycle: {...}, data: [...], expenses: [...] }
            final cycleData = responseData['cycle'];
            final cycleDataList = responseData['data'] ?? <dynamic>[];
            final expensesList = responseData['expenses'] ?? <dynamic>[];

            if (cycleData != null) {
              // تحديث currentCycle بالبيانات من API
              final cycleDetails = _convertCycleDetailsFromApi(
                cycleData,
                cycleDataList: cycleDataList,
                expensesList: expensesList,
              );

              // البحث عن الدورة في cycles وتحديثها
              final idx = cycles.indexWhere((c) => c['cycle_id'] == cycleId);
              if (idx != -1) {
                // استبدال الدورة بالبيانات الكاملة من API
                cycles[idx] = Map<String, dynamic>.from(cycleDetails);
              } else {
                // إذا لم تكن الدورة موجودة، أضفها
                cycles.add(Map<String, dynamic>.from(cycleDetails));
              }
              
              // حفظ الدورات المحدثة في GetStorage
              myServices.getStorage.write(_storageKey, cycles.toList());

              // تحديث currentCycle إذا كانت هذه هي الدورة الحالية
              final currentCycleId = currentCycle['cycle_id'];
              if (currentCycleId != null) {
                final currentCycleIdInt =
                    currentCycleId is int
                        ? currentCycleId
                        : int.tryParse(currentCycleId.toString());
                if (currentCycleIdInt == cycleId) {
                  currentCycle.assignAll(cycleDetails);

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
          
          // تحديث حالة التحميل إلى success ثم إعادة تعيينها بعد قليل
          cycleDetailsStatus.value = StatusRequest.success;
          _loadingCycleDetails.remove(cycleId);
          
          // إعادة تعيين الحالة إلى none بعد قليل لإخفاء رسالة النجاح
          Future.delayed(const Duration(milliseconds: 500), () {
            if (cycleDetailsStatus.value == StatusRequest.success) {
              cycleDetailsStatus.value = StatusRequest.none;
            }
          });
        },
      );
    } catch (e) {
      // في حالة حدوث خطأ، نستخدم البيانات المحلية
      _loadingCycleDetails.remove(cycleId);
      cycleDetailsStatus.value = StatusRequest.serverFailure;
      _isCycleOpen = false; // إزالة flag عند الخطأ
    }
  }

  // Method لإزالة flag عند إغلاق الدورة
  void closeCycle() {
    _isCycleOpen = false;
  }

  Map<String, dynamic> _convertCycleDetailsFromApi(
    Map<String, dynamic> cycleData, {
    List<dynamic>? cycleDataList,
    List<dynamic>? expensesList,
  }) {
    final cycleId = cycleData['id'] ?? cycleData['cycle_id'];
    final name = cycleData['name'] ?? '';
    final chickCount = cycleData['chick_count']?.toString() ?? '0';
    final space = cycleData['space']?.toString() ?? '0';
    final breed = cycleData['breed'] ?? 'تسمين';
    final startDateRaw = cycleData['start_date_raw'] ?? '';

    // تحويل التاريخ إلى صيغة عربية
    String startDate = '';
    if (startDateRaw.isNotEmpty) {
      try {
        final date = DateTime.parse(startDateRaw);
        final formatter = DateFormat('yyyy/MM/dd', 'ar');
        startDate = formatter.format(date);
      } catch (e) {
        startDate = startDateRaw;
      }
    }

    // تحويل cycle_data إلى entries
    final mortalityEntries = <Map<String, dynamic>>[];
    final averageWeightEntries = <Map<String, dynamic>>[];
    final medicationEntries = <Map<String, dynamic>>[];
    final feedConsumptionEntries = <Map<String, dynamic>>[];
    final customDataEntries = <Map<String, dynamic>>[];

    // معالجة cycle_data إذا كانت موجودة
    if (cycleDataList != null && cycleDataList.isNotEmpty) {
      for (var item in cycleDataList) {
        final label = item['label']?.toString() ?? '';
        final value = item['value']?.toString() ?? '';
        final entryDateStr = item['entry_date']?.toString() ?? '';

        // تحويل entry_date من صيغة Y-m-d H:i:s إلى ISO8601
        DateTime entryDate = DateTime.now();
        if (entryDateStr.isNotEmpty) {
          try {
            // محاولة تحويل من صيغة Y-m-d H:i:s مباشرة
            DateTime? parsedDate;

            // محاولة 1: تحويل مباشر (إذا كانت بصيغة ISO8601)
            parsedDate = DateTime.tryParse(entryDateStr);

            // محاولة 2: تحويل من صيغة Y-m-d H:i:s
            if (parsedDate == null) {
              final parts = entryDateStr.split(' ');
              if (parts.length == 2) {
                final datePart = parts[0];
                final timePart = parts[1];
                final dateParts = datePart.split('-');
                final timeParts = timePart.split(':');
                if (dateParts.length == 3 && timeParts.length >= 2) {
                  parsedDate = DateTime(
                    int.tryParse(dateParts[0]) ?? DateTime.now().year,
                    int.tryParse(dateParts[1]) ?? DateTime.now().month,
                    int.tryParse(dateParts[2]) ?? DateTime.now().day,
                    int.tryParse(timeParts[0]) ?? 0,
                    int.tryParse(timeParts[1]) ?? 0,
                    timeParts.length > 2
                        ? (int.tryParse(timeParts[2]) ?? 0)
                        : 0,
                  );
                }
              }
            }

            // محاولة 3: تحويل من صيغة Y-m-d فقط
            if (parsedDate == null && entryDateStr.contains('-')) {
              final dateParts = entryDateStr.split('-');
              if (dateParts.length == 3) {
                parsedDate = DateTime(
                  int.tryParse(dateParts[0]) ?? DateTime.now().year,
                  int.tryParse(dateParts[1]) ?? DateTime.now().month,
                  int.tryParse(dateParts[2]) ?? DateTime.now().day,
                );
              }
            }

            if (parsedDate != null) {
              entryDate = parsedDate;
            }
          } catch (e) {
            entryDate = DateTime.now();
          }
        }

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

        if (isMortality) {
          final count = int.tryParse(value) ?? 0;
          if (count > 0) {
            mortalityEntries.add({
              'id':
                  item['id']?.toString() ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              'count': count,
              'date': entryDate.toIso8601String(),
            });
          }
        } else if (isAverageWeight) {
          final weight = double.tryParse(value) ?? 0.0;
          if (weight > 0) {
            averageWeightEntries.add({
              'id':
                  item['id']?.toString() ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              'weight': weight,
              'date': entryDate.toIso8601String(),
            });
          }
        } else if (isMedication) {
          if (value.isNotEmpty) {
            medicationEntries.add({
              'id':
                  item['id']?.toString() ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              'text': value,
              'date': entryDate.toIso8601String(),
            });
          }
        } else if (isFeedConsumption) {
          final amount = double.tryParse(value) ?? 0.0;
          if (amount > 0) {
            feedConsumptionEntries.add({
              'id':
                  item['id']?.toString() ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              'amount': amount,
              'date': entryDate.toIso8601String(),
            });
          }
        } else {
          // البيانات المخصصة (ليست من الأنواع المعرفة)
          if (value.isNotEmpty) {
            customDataEntries.add({
              'id':
                  item['id']?.toString() ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              'label': label,
              'value': value,
              'entry_date': entryDate.toIso8601String(),
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
        final value = expense['value']?.toString() ?? '';
        final entryDateStr = expense['entry_date']?.toString() ?? '';

        // تحويل entry_date من صيغة Y-m-d H:i:s إلى ISO8601
        DateTime entryDate = DateTime.now();
        if (entryDateStr.isNotEmpty) {
          try {
            // محاولة تحويل من صيغة Y-m-d H:i:s مباشرة
            DateTime? parsedDate;

            // محاولة 1: تحويل مباشر (إذا كانت بصيغة ISO8601)
            parsedDate = DateTime.tryParse(entryDateStr);

            // محاولة 2: تحويل من صيغة Y-m-d H:i:s
            if (parsedDate == null) {
              final parts = entryDateStr.split(' ');
              if (parts.length == 2) {
                final datePart = parts[0];
                final timePart = parts[1];
                final dateParts = datePart.split('-');
                final timeParts = timePart.split(':');
                if (dateParts.length == 3 && timeParts.length >= 2) {
                  parsedDate = DateTime(
                    int.tryParse(dateParts[0]) ?? DateTime.now().year,
                    int.tryParse(dateParts[1]) ?? DateTime.now().month,
                    int.tryParse(dateParts[2]) ?? DateTime.now().day,
                    int.tryParse(timeParts[0]) ?? 0,
                    int.tryParse(timeParts[1]) ?? 0,
                    timeParts.length > 2
                        ? (int.tryParse(timeParts[2]) ?? 0)
                        : 0,
                  );
                }
              }
            }

            // محاولة 3: تحويل من صيغة Y-m-d فقط
            if (parsedDate == null && entryDateStr.contains('-')) {
              final dateParts = entryDateStr.split('-');
              if (dateParts.length == 3) {
                parsedDate = DateTime(
                  int.tryParse(dateParts[0]) ?? DateTime.now().year,
                  int.tryParse(dateParts[1]) ?? DateTime.now().month,
                  int.tryParse(dateParts[2]) ?? DateTime.now().day,
                );
              }
            }

            if (parsedDate != null) {
              entryDate = parsedDate;
            }
          } catch (e) {
            entryDate = DateTime.now();
          }
        }

        final amount = double.tryParse(value) ?? 0.0;
        if (amount > 0 && label.isNotEmpty) {
          processedExpenses.add({
            'id':
                expense['id']?.toString() ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            'label': label,
            'value': amount,
            'entry_date': entryDate.toIso8601String(),
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

    return {
      'cycle_id': cycleId,
      'name': name,
      'chickCount': chickCount,
      'space': space,
      'breed': breed,
      'startDate': startDate,
      'startDateRaw': startDateRaw,
      'mortality': calculatedMortality.toString(),
      'total_expenses': totalExpenses.toString(),
      'mortalityEntries': mortalityEntries,
      'averageWeightEntries': averageWeightEntries,
      'medicationEntries': medicationEntries,
      'feedConsumptionEntries': feedConsumptionEntries,
      'expenses': processedExpenses,
      'customDataEntries': customDataEntries, // البيانات المخصصة من API
    };
  }

  void prepareForEdit(Map<String, dynamic> data, int index) {
    isEdit.value = true;
    editIndex.value = index;
    nameController.text = data['name'] ?? '';
    countController.text = data['chickCount'] ?? '';
    spaceController.text = data['space'] ?? '';
    dateController.text = data['startDate'] ?? '';
    dateRawController.text = data['startDateRaw'] ?? '';
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
    if (!formKey.currentState!.validate()) return;

    final name = nameController.text.trim();
    final chickCount = int.tryParse(countController.text.trim()) ?? 0;
    final space = double.tryParse(spaceController.text.trim()) ?? 0.0;
    final breed = 'تسمين';
    final startDateRaw = dateRawController.text.trim();
    final startDate = dateController.text.trim();

    final entry = {
      'name': name,
      'chickCount': countController.text.trim(),
      'space': spaceController.text.trim(),
      'breed': breed,
      'startDate': startDate,
      'startDateRaw': startDateRaw,
      'mortalityEntries': <Map<String, dynamic>>[],
      'mortality': '0',
      // 'lastStageShown' removed
    };

    if (isEdit.value && editIndex.value >= 0) {
      cycles[editIndex.value] = entry;
      currentCycle.assignAll(entry);
      isEdit.value = false;
      editIndex.value = -1;

      // حفظ محلياً فقط للدورات المحلية (بدون cycle_id)
      if (entry['cycle_id'] == null) {
        await myServices.getStorage.write(_storageKey, cycles.toList());
      }
      clearFields();

      Get.back();
      return;
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

        Get.offNamedUntil(
          AppRoute.cycle,
          ModalRoute.withName('/'),
          arguments: {'index': newIndex, 'showTutorial': shouldShowTutorial},
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
        (result) {
          // نجح API
          final data = result as Map<String, dynamic>;
          final isSuccess = data['status'] == 'success';

          if (isSuccess && data['data'] != null) {
            final cycleData = data['data'] as Map<String, dynamic>;
            final cycleId = cycleData['cycle_id'];

            // إضافة cycle_id إلى الدورة
            entry['cycle_id'] = cycleId;
          }

          cycles.add(entry);
          myServices.getStorage.write(_storageKey, cycles.toList());
          cycleSaveStatus.value = StatusRequest.success;
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

      Get.offNamedUntil(
        AppRoute.cycle,
        ModalRoute.withName('/'),
        arguments: {'index': newIndex, 'showTutorial': shouldShowTutorial},
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

      Get.offNamedUntil(
        AppRoute.cycle,
        ModalRoute.withName('/'),
        arguments: {'index': newIndex, 'showTutorial': shouldShowTutorial},
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
                  await _cycleData.deleteCycle(token: token, cycleId: cycleIdInt);
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

  Future<bool> endCurrentCycle() async {
    final idx = cycles.indexWhere((c) => c['name'] == currentCycle['name']);
    if (idx == -1) return false;

    // التحقق من أن الدورة لم تنتهِ بالفعل
    if (currentCycle['status'] == 'finished') {
      return false;
    }

    final cycleId = currentCycle['cycle_id'];
    final cycleName = currentCycle['name']?.toString();

    // حذف الدورة محلياً فوراً قبل إرسال الطلب إلى API
    if (cycleName != null && cycleName.isNotEmpty) {
      _deleteCycleRelatedData(cycleName);
      
      // إضافة اسم الدورة إلى قائمة الدورات المحذوفة لمنع إعادة إضافتها من API
      final deletedCycles = myServices.getStorage.read<List>(_deletedCyclesKey) ?? [];
      if (!deletedCycles.contains(cycleName)) {
        deletedCycles.add(cycleName);
        myServices.getStorage.write(_deletedCyclesKey, deletedCycles);
      }
    }
    
    // حذف الدورة من القائمة فوراً
    cycles.removeAt(idx);
    
    // حفظ التغييرات فوراً
    await myServices.getStorage.write(_storageKey, cycles.toList());
    
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
    Future.microtask(() {
      cycles.refresh();
    });

    cycleEndStatus.value = StatusRequest.loading;

    // إرسال طلب إنهاء الدورة إلى API في الخلفية
    if (cycleId != null) {
      _endCycleFromServerInBackground(cycleId);
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

  void _endCycleFromServerInBackground(dynamic cycleId) async {
    try {
      final isLoggedIn = myServices.getStorage.read<bool>('is_logged_in') ?? false;
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

      final cycleIdInt = cycleId is int ? cycleId : int.tryParse(cycleId.toString()) ?? 0;
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
    return cycle['status'] == 'finished';
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
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
      if (cycleId == null)
        return; // إذا لم يكن cycle_id موجوداً، لا ترسل إلى API

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
    myServices.getStorage.write(_storageKey, cycles.toList());

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

      cycles[idx]['medicationEntries'] = entries.map((e) => e.toJson()).toList();
      currentCycle['medicationEntries'] = entries.map((e) => e.toJson()).toList();

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
    myServices.getStorage.write(_storageKey, cycles.toList());

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
      await _sendDataToServer(
        label: 'استهلاك العلف',
        value: amount.toString(),
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
    myServices.getStorage.write(_storageKey, cycles.toList());

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
      await _sendDataToServer(
        label: 'عدد النافق',
        value: count.toString(),
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
    myServices.getStorage.write(_storageKey, cycles.toList());

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
}
