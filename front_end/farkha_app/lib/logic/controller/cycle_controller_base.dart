import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/storage_keys.dart';
import '../../core/services/initialization.dart';
import '../../data/data_source/remote/cycle_data/cycle_data.dart';
import '../../data/model/cycle/weight_entry.dart';
import '../../data/model/cycle/medication_entry.dart';
import '../../data/model/cycle/feed_consumption_entry.dart';
import '../../data/model/cycle/mortality_entry.dart';

abstract class CycleControllerBase extends GetxController {
  late CycleData cycleData;
  late FirebaseAuth auth;
  late MyServices myServices;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController countController = TextEditingController();
  final TextEditingController spaceController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController dateRawController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxList<Map<String, dynamic>> cycles = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> historyCycles = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> currentCycle = <String, dynamic>{}.obs;

  final RxBool isEdit = false.obs;
  final RxInt editIndex = (-1).obs;
  final RxBool isCreatingCycle = false.obs;

  final Set<int> loadingCycleDetails = <int>{};
  bool isCycleOpen = false;

  final Rx<StatusRequest> cycleDetailsStatus = StatusRequest.none.obs;
  final Rx<StatusRequest> cycleSaveStatus = StatusRequest.none.obs;
  final Rx<StatusRequest> cycleDeleteStatus = StatusRequest.none.obs;
  final Rx<StatusRequest> cycleEndStatus = StatusRequest.none.obs;
  final RxInt cycleDataVersion = 0.obs;

  Future<void> fetchCycleDetails(int cycleId, {bool silent = false});
  Future<void> fetchCyclesFromServer();

  Map<String, dynamic> convertCycleDetailsFromApi(
    Map<String, dynamic> cycleData, {
    List<dynamic>? cycleDataList,
    List<dynamic>? expensesList,
    List<dynamic>? notesList,
    List<dynamic>? membersList,
    List<dynamic>? salesList,
  }) {
    final cycleId = cycleData['id'] ?? cycleData['cycle_id'];
    final name = cycleData['name'] ?? '';
    final chickCount = cycleData['chick_count']?.toString() ?? cycleData['chickCount']?.toString() ?? '0';
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

        final isMortality = labelLower == 'mortality' || labelLower == 'نافق' || labelLower == 'عدد النافق' || labelOriginal == 'عدد النافق' || (label.contains('نافق') && !label.contains('غير'));

        final isAverageWeight = labelLower == 'average_weight' || labelLower == 'averageweight' || labelOriginal == 'الوزن المتوسط' || labelOriginal == 'متوسط وزن القطيع' || labelLower == 'متوسط وزن القطيع' || labelLower == 'الوزن المتوسط' || labelLower == 'متوسط الوزن' || (label.contains('وزن') && label.contains('متوسط'));

        final isMedication = labelLower == 'medication' || labelOriginal == 'التحصينات' || labelLower == 'التحصينات' || labelLower == 'تحصين' || (label.contains('تحصين') && !label.contains('غير')) || label.contains('دواء');

        final isFeedConsumption = labelLower == 'feed_consumption' || labelLower == 'feedconsumption' || labelOriginal == 'الاستهلاك اليومي' || labelOriginal == 'استهلاك العلف' || labelLower == 'الاستهلاك اليومي' || labelLower == 'استهلاك العلف' || (label.contains('استهلاك') && !label.contains('غير')) || (label.contains('علف') && label.contains('استهلاك'));

        final dateFormatted = parseDateToString(entryDateStr);

        if (isMortality) {
          final count = int.tryParse(value) ?? 0;
          if (count > 0) {
            mortalityEntries.add({'id': item['id']?.toString() ?? '', 'count': count, 'date': dateFormatted});
          }
        } else if (isAverageWeight) {
          final weight = double.tryParse(value) ?? 0.0;
          if (weight > 0) {
            averageWeightEntries.add({'id': item['id']?.toString() ?? '', 'weight': weight, 'date': dateFormatted});
          }
        } else if (isMedication) {
          if (value.isNotEmpty) {
            medicationEntries.add({'id': item['id']?.toString() ?? '', 'text': value, 'date': dateFormatted});
          }
        } else if (isFeedConsumption) {
          final amount = double.tryParse(value) ?? 0.0;
          if (amount > 0) {
            feedConsumptionEntries.add({'id': item['id']?.toString() ?? '', 'amount': amount, 'date': dateFormatted});
          }
        } else {
          if (value.isNotEmpty) {
            customDataEntries.add({'id': item['id']?.toString() ?? '', 'element_type': 'note', 'label': label, 'value': value, 'date': dateFormatted});
          }
        }
      }
    }

    final calculatedMortality = mortalityEntries.fold<int>(0, (sum, entry) => sum + (int.tryParse(entry['count']?.toString() ?? '0') ?? 0));

    double totalExpenses = 0.0;
    if (cycleData['total_expenses'] != null) {
      totalExpenses = (cycleData['total_expenses'] is num) ? (cycleData['total_expenses'] as num).toDouble() : (double.tryParse(cycleData['total_expenses'].toString()) ?? 0.0);
    }

    final processedExpenses = <Map<String, dynamic>>[];
    if (expensesList != null && expensesList.isNotEmpty) {
      for (var expense in expensesList) {
        final label = expense['label']?.toString() ?? '';
        final rawValue = expense['value'];
        final entryDateStr = expense['entry_date']?.toString() ?? '';
        final dateFormatted = parseDateToString(entryDateStr);
        final amount = (rawValue is num) ? rawValue.toDouble() : (double.tryParse(rawValue?.toString() ?? '0') ?? 0.0);

        if (label.isNotEmpty) {
          processedExpenses.add({'id': expense['id']?.toString() ?? '', 'type': label, 'amount': amount, 'created_at': dateFormatted, 'notes': ''});
          totalExpenses += amount;
        }
      }
    }

    final processedNotes = <Map<String, dynamic>>[];
    if (notesList != null && notesList.isNotEmpty) {
      for (var note in notesList) {
        final content = note['content']?.toString() ?? '';
        final noteDateStr = note['entry_date']?.toString() ?? '';
        final dateFormatted = parseDateToString(noteDateStr);
        if (content.isNotEmpty) {
          processedNotes.add({'id': note['id']?.toString() ?? '', 'content': content, 'date': dateFormatted});
          customDataEntries.add({'id': note['id']?.toString() ?? '', 'element_type': 'note', 'label': 'ملاحظة', 'value': content, 'date': dateFormatted});
        }
      }
    }

    if (totalExpenses == 0.0 && processedExpenses.isNotEmpty) {
      totalExpenses = processedExpenses.fold<double>(0.0, (sum, expense) => sum + ((expense['value'] as num?)?.toDouble() ?? 0.0));
    }

    double calculatedTotalSales = (double.tryParse(totalSales) ?? 0.0);
    if (calculatedTotalSales == 0.0 && salesList != null && salesList.isNotEmpty) {
      calculatedTotalSales = salesList.fold<double>(0.0, (sum, sale) => sum + (double.tryParse(sale['total_price']?.toString() ?? '0.0') ?? 0.0));
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

  String parseDateToString(String dateStr) {
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
    return dateStr.length >= 10 ? dateStr.substring(0, 10).replaceAll('-', '/') : dateStr;
  }
}
