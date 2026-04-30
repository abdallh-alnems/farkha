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

mixin CycleDataEntryMixin on CycleControllerBase {
  final Rx<StatusRequest> cycleDataStatus =
      StatusRequest.none.obs;

  Future<void> _cancelDailyNotification() async {
    final start = DateTime.tryParse(
      currentCycle['startDate']?.toString() ?? '',
    );
    if (start == null) return;

    final now = DateTime.now();
    final dayOfCycle = now.difference(start).inDays + 1;

    if (dayOfCycle > 0) {
      await NotificationService.instance.cancelDailyDataNotification(
        dayOfCycle,
      );
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

    if (cycles[idx]['cycle_id'] == null) {
      await myServices.getStorage.write(StorageKeys.cycles, cycles.toList());
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
        return;
      }

      final isLoggedIn =
          myServices.getStorage.read<bool>(StorageKeys.isLoggedIn) ?? false;
      if (!isLoggedIn) return;

      final user = auth.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) return;

      await cycleData.addCycleData(
        token: token,
        cycleId:
            cycleId is int ? cycleId : int.tryParse(cycleId.toString()) ?? 0,
        label: label,
        value: value,
      );
    } catch (e) {
      // ignore
    }
  }

  void _deleteItemFromServerInBackground({
    required String type,
    required String deleteType,
    int? itemId,
    String? label,
    required dynamic cycleId,
  }) {
    Future<void>(() async {
      try {
        final isLoggedIn =
            myServices.getStorage.read<bool>(StorageKeys.isLoggedIn) ?? false;
        if (!isLoggedIn) return;

        final user = auth.currentUser;
        if (user == null) return;

        final token = await user.getIdToken();
        if (token == null || token.isEmpty) return;

        await cycleData.deleteCycleItem(
          token: token,
          cycleId:
              cycleId is int ? cycleId : int.tryParse(cycleId.toString()) ?? 0,
          type: type,
          deleteType: deleteType,
          itemId: itemId,
          label: label,
        );

        final cycleIdInt =
            cycleId is int ? cycleId : int.tryParse(cycleId.toString());
        if (cycleIdInt != null && cycleIdInt > 0) {
          await fetchCycleDetails(cycleIdInt);
        }
      } catch (e) {
        // ignore
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

      cycles[idx]['averageWeight'] = weight.toString();
      currentCycle['averageWeight'] = weight.toString();

      cycles.refresh();

      await myServices.getStorage.write(StorageKeys.cycles, cycles.toList());

      await _sendDataToServer(
        label: 'متوسط وزن القطيع',
        value: weight.toString(),
      );

      cycleDataStatus.value = StatusRequest.success;
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

    final entries = getAverageWeightEntries();
    entries.removeWhere((e) => e.id == entryId);

    cycles[idx]['averageWeightEntries'] =
        entries.map((e) => e.toJson()).toList();
    currentCycle['averageWeightEntries'] =
        entries.map((e) => e.toJson()).toList();

    if (entries.isNotEmpty) {
      final lastWeight = entries.last.weight;
      cycles[idx]['averageWeight'] = lastWeight.toString();
      currentCycle['averageWeight'] = lastWeight.toString();
    } else {
      cycles[idx]['averageWeight'] = '';
      currentCycle['averageWeight'] = '';
    }

    cycles.refresh();

    unawaited(myServices.getStorage.write(StorageKeys.cycles, cycles.toList()));

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

      cycles[idx]['medication'] = text;
      currentCycle['medication'] = text;

      cycles.refresh();

      await myServices.getStorage.write(StorageKeys.cycles, cycles.toList());

      await _sendDataToServer(label: 'التحصينات', value: text);

      cycleDataStatus.value = StatusRequest.success;
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

    final entries = getMedicationEntries();
    entries.removeWhere((e) => e.id == entryId);

    cycles[idx]['medicationEntries'] = entries.map((e) => e.toJson()).toList();
    currentCycle['medicationEntries'] = entries.map((e) => e.toJson()).toList();

    if (entries.isNotEmpty) {
      final lastText = entries.last.text;
      cycles[idx]['medication'] = lastText;
      currentCycle['medication'] = lastText;
    } else {
      cycles[idx]['medication'] = '';
      currentCycle['medication'] = '';
    }

    cycles.refresh();

    unawaited(myServices.getStorage.write(StorageKeys.cycles, cycles.toList()));

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

      cycles[idx]['feedConsumption'] = amount.toString();
      currentCycle['feedConsumption'] = amount.toString();

      cycles.refresh();

      await myServices.getStorage.write(StorageKeys.cycles, cycles.toList());

      await _sendDataToServer(label: 'استهلاك العلف', value: amount.toString());

      await _cancelDailyNotification();

      cycleDataStatus.value = StatusRequest.success;
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

    final entries = getFeedConsumptionEntries();
    entries.removeWhere((e) => e.id == entryId);

    cycles[idx]['feedConsumptionEntries'] =
        entries.map((e) => e.toJson()).toList();
    currentCycle['feedConsumptionEntries'] =
        entries.map((e) => e.toJson()).toList();

    if (entries.isNotEmpty) {
      final lastAmount = entries.last.amount;
      cycles[idx]['feedConsumption'] = lastAmount.toString();
      currentCycle['feedConsumption'] = lastAmount.toString();
    } else {
      cycles[idx]['feedConsumption'] = '';
      currentCycle['feedConsumption'] = '';
    }

    cycles.refresh();

    unawaited(myServices.getStorage.write(StorageKeys.cycles, cycles.toList()));

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

      final total = entries.fold<int>(0, (sum, e) => sum + e.count);

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

      await myServices.getStorage.write(StorageKeys.cycles, cycles.toList());

      await _sendDataToServer(label: 'عدد النافق', value: count.toString());

      cycleDataStatus.value = StatusRequest.success;
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

    final entries = getMortalityEntries();
    entries.removeWhere((e) => e.id == entryId);

    final entriesList = entries.map((e) => e.toJson()).toList();

    final total =
        entries.isNotEmpty
            ? entries.fold<int>(0, (sum, e) => sum + e.count)
            : 0;

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

    unawaited(myServices.getStorage.write(StorageKeys.cycles, cycles.toList()));

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
