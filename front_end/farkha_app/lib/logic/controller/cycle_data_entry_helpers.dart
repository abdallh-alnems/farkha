import 'dart:async';

import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/storage_keys.dart';
import '../../core/services/notification_service.dart';
import '../../data/model/cycle/weight_entry.dart';
import '../../data/model/cycle/medication_entry.dart';
import '../../data/model/cycle/feed_consumption_entry.dart';
import '../../data/model/cycle/mortality_entry.dart';
import 'cycle_controller_base.dart';

int findCycleIndex(
  RxList<Map<String, dynamic>> cycles,
  RxMap<String, dynamic> currentCycle,
) {
  final cycleName = currentCycle['name'];
  if (cycleName == null) return -1;
  return cycles.indexWhere((c) => c['name'] == cycleName);
}

List<WeightEntry> parseWeightEntries(Map<String, dynamic> cycle) {
  final entriesData = cycle['averageWeightEntries'] as List<dynamic>?;
  if (entriesData == null) return [];
  return entriesData
      .map((e) => WeightEntry.fromJson(e as Map<String, dynamic>))
      .toList();
}

List<MedicationEntry> parseMedicationEntries(Map<String, dynamic> cycle) {
  final entriesData = cycle['medicationEntries'] as List<dynamic>?;
  if (entriesData == null) return [];
  return entriesData
      .map((e) => MedicationEntry.fromJson(e as Map<String, dynamic>))
      .toList();
}

List<FeedConsumptionEntry> parseFeedConsumptionEntries(
  Map<String, dynamic> cycle,
) {
  final entriesData = cycle['feedConsumptionEntries'] as List<dynamic>?;
  if (entriesData == null) return [];
  return entriesData
      .map((e) => FeedConsumptionEntry.fromJson(e as Map<String, dynamic>))
      .toList();
}

List<MortalityEntry> parseMortalityEntries(Map<String, dynamic> cycle) {
  final entriesData = cycle['mortalityEntries'];
  if (entriesData == null) return [];
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

int resolveCycleIdInt(dynamic cycleId) {
  return cycleId is int ? cycleId : int.tryParse(cycleId.toString()) ?? 0;
}

Future<void> sendCycleDataToServer(
  CycleControllerBase c, {
  required String label,
  required String value,
  String? metricType,
}) async {
  try {
    final cycleId = c.currentCycle['cycle_id'];
    if (cycleId == null) return;

    final isLoggedIn =
        c.myServices.getStorage.read<bool>(StorageKeys.isLoggedIn) ?? false;
    if (!isLoggedIn) return;

    final user = c.auth.currentUser;
    if (user == null) return;

    final token = await user.getIdToken();
    if (token == null || token.isEmpty) return;

    await c.cycleData.addCycleData(
      token: token,
      cycleId: resolveCycleIdInt(cycleId),
      label: label,
      value: value,
      metricType: metricType,
    );
  } catch (_) {}
}

void deleteCycleItemInBackground(
  CycleControllerBase c, {
  required String type,
  required String deleteType,
  int? itemId,
  String? label,
  required dynamic cycleId,
}) {
  Future<void>(() async {
    try {
      final isLoggedIn =
          c.myServices.getStorage.read<bool>(StorageKeys.isLoggedIn) ?? false;
      if (!isLoggedIn) return;

      final user = c.auth.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) return;

      await c.cycleData.deleteCycleItem(
        token: token,
        cycleId: resolveCycleIdInt(cycleId),
        type: type,
        deleteType: deleteType,
        itemId: itemId,
        label: label,
      );

      final cycleIdInt = resolveCycleIdInt(cycleId);
      if (cycleIdInt > 0) {
        await c.fetchCycleDetails(cycleIdInt);
      }
    } catch (_) {}
  });
}

Future<void> cancelDailyDataNotification(
  Map<String, dynamic> currentCycle,
) async {
  final start = DateTime.tryParse(
    currentCycle['startDate']?.toString() ?? '',
  );
  if (start == null) return;

  final now = DateTime.now();
  final dayOfCycle = now.difference(start).inDays + 1;

  if (dayOfCycle > 0) {
    await NotificationService.instance.cancelDailyDataNotification(dayOfCycle);
  }
}

void notifyStatusSuccess(Rx<StatusRequest> status) {
  status.value = StatusRequest.success;
  Future.delayed(const Duration(milliseconds: 500), () {
    if (status.value == StatusRequest.success) {
      status.value = StatusRequest.none;
    }
  });
}

void notifyStatusFailure(Rx<StatusRequest> status) {
  status.value = StatusRequest.serverFailure;
  Future.delayed(const Duration(milliseconds: 2000), () {
    status.value = StatusRequest.none;
  });
}
