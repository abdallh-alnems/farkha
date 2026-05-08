import 'dart:async';

import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/storage_keys.dart';
import '../../data/model/cycle/weight_entry.dart';
import '../../data/model/cycle/medication_entry.dart';
import '../../data/model/cycle/feed_consumption_entry.dart';
import '../../data/model/cycle/mortality_entry.dart';
import 'cycle_controller_base.dart';
import 'cycle_data_entry_helpers.dart';

mixin CycleDataEntryMixin on CycleControllerBase {
  final Rx<StatusRequest> cycleDataStatus = StatusRequest.none.obs;

  Future<void> updateCycleData({
    String? mortality,
    String? averageWeight,
    String? medication,
    String? feedConsumption,
  }) async {
    final idx = findCycleIndex(cycles, currentCycle);
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

  Future<void> addAverageWeightEntry(double weight) async {
    final idx = findCycleIndex(cycles, currentCycle);
    if (idx == -1) return;

    cycleDataStatus.value = StatusRequest.loading;

    try {
      final entries = parseWeightEntries(currentCycle);
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

      await sendCycleDataToServer(
        this,
        label: 'متوسط وزن القطيع',
        value: weight.toString(),
        metricType: 'weight',
      );

      notifyStatusSuccess(cycleDataStatus);
    } catch (e) {
      notifyStatusFailure(cycleDataStatus);
    }
  }

  Future<void> removeAverageWeightEntry(String entryId) async {
    final idx = findCycleIndex(cycles, currentCycle);
    if (idx == -1) return;

    final entries = parseWeightEntries(currentCycle);
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

    unawaited(
      myServices.getStorage.write(StorageKeys.cycles, cycles.toList()),
    );

    final cycleId = currentCycle['cycle_id'];
    final itemId = int.tryParse(entryId);

    if (itemId != null && itemId > 0 && cycleId != null) {
      deleteCycleItemInBackground(
        this,
        type: 'data',
        deleteType: 'single',
        itemId: itemId,
        cycleId: cycleId,
      );
    }
  }

  Future<void> addMedicationEntry(String text) async {
    final idx = findCycleIndex(cycles, currentCycle);
    if (idx == -1) return;

    cycleDataStatus.value = StatusRequest.loading;

    try {
      final entries = parseMedicationEntries(currentCycle);
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

      await sendCycleDataToServer(this, label: 'التحصينات', value: text, metricType: 'medicine');

      notifyStatusSuccess(cycleDataStatus);
    } catch (e) {
      notifyStatusFailure(cycleDataStatus);
    }
  }

  Future<void> removeMedicationEntry(String entryId) async {
    final idx = findCycleIndex(cycles, currentCycle);
    if (idx == -1) return;

    final entries = parseMedicationEntries(currentCycle);
    entries.removeWhere((e) => e.id == entryId);

    cycles[idx]['medicationEntries'] =
        entries.map((e) => e.toJson()).toList();
    currentCycle['medicationEntries'] =
        entries.map((e) => e.toJson()).toList();

    if (entries.isNotEmpty) {
      final lastText = entries.last.text;
      cycles[idx]['medication'] = lastText;
      currentCycle['medication'] = lastText;
    } else {
      cycles[idx]['medication'] = '';
      currentCycle['medication'] = '';
    }

    cycles.refresh();

    unawaited(
      myServices.getStorage.write(StorageKeys.cycles, cycles.toList()),
    );

    final cycleId = currentCycle['cycle_id'];
    final itemId = int.tryParse(entryId);

    if (itemId != null && itemId > 0 && cycleId != null) {
      deleteCycleItemInBackground(
        this,
        type: 'data',
        deleteType: 'single',
        itemId: itemId,
        cycleId: cycleId,
      );
    }
  }

  Future<void> addFeedConsumptionEntry(double amount) async {
    final idx = findCycleIndex(cycles, currentCycle);
    if (idx == -1) return;

    cycleDataStatus.value = StatusRequest.loading;

    try {
      final entries = parseFeedConsumptionEntries(currentCycle);
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

      await sendCycleDataToServer(
        this,
        label: 'استهلاك العلف',
        value: amount.toString(),
        metricType: 'feed',
      );

      await cancelDailyDataNotification(currentCycle);

      notifyStatusSuccess(cycleDataStatus);
    } catch (e) {
      notifyStatusFailure(cycleDataStatus);
    }
  }

  Future<void> removeFeedConsumptionEntry(String entryId) async {
    final idx = findCycleIndex(cycles, currentCycle);
    if (idx == -1) return;

    final entries = parseFeedConsumptionEntries(currentCycle);
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

    unawaited(
      myServices.getStorage.write(StorageKeys.cycles, cycles.toList()),
    );

    final cycleId = currentCycle['cycle_id'];
    final itemId = int.tryParse(entryId);

    if (itemId != null && itemId > 0 && cycleId != null) {
      deleteCycleItemInBackground(
        this,
        type: 'data',
        deleteType: 'single',
        itemId: itemId,
        cycleId: cycleId,
      );
    }
  }

  Future<void> addMortalityEntry(int count) async {
    final idx = findCycleIndex(cycles, currentCycle);
    if (idx == -1) return;

    cycleDataStatus.value = StatusRequest.loading;

    try {
      final entries = parseMortalityEntries(currentCycle);
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

      await sendCycleDataToServer(
        this,
        label: 'عدد النافق',
        value: count.toString(),
        metricType: 'mortality',
      );

      notifyStatusSuccess(cycleDataStatus);
    } catch (e) {
      notifyStatusFailure(cycleDataStatus);
    }
  }

  Future<void> removeMortalityEntry(String entryId) async {
    final idx = findCycleIndex(cycles, currentCycle);
    if (idx == -1) return;

    final entries = parseMortalityEntries(currentCycle);
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

    unawaited(
      myServices.getStorage.write(StorageKeys.cycles, cycles.toList()),
    );

    final cycleId = currentCycle['cycle_id'];
    final itemId = int.tryParse(entryId);

    if (itemId != null && itemId > 0 && cycleId != null) {
      deleteCycleItemInBackground(
        this,
        type: 'data',
        deleteType: 'single',
        itemId: itemId,
        cycleId: cycleId,
      );
    }
  }
}
