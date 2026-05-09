import 'dart:math';

import 'package:get/get.dart';

import '../../../../data/data_source/static/chicken_data.dart';
import '../../../../logic/controller/cycle_controller.dart';
import '../../../../logic/controller/cycle_expenses_controller.dart';
import '../../../../logic/controller/tools_controller/broiler_controller.dart';

const double maxReasonableGramsPerBird = 5000;

double calculateFCR(CycleController cycleCtrl, BroilerController broilerCtrl) {
  final feedEntries = cycleCtrl.getFeedConsumptionEntries();
  double totalFeedConsumed = 0.0;
  for (var entry in feedEntries) {
    totalFeedConsumed += entry.amount;
  }
  if (totalFeedConsumed == 0.0) return 0.0;

  final weightEntries = cycleCtrl.getAverageWeightEntries();
  final lastWeight = weightEntries.isNotEmpty ? weightEntries.last.weight : 0.0;
  if (lastWeight == 0.0) return 0.0;

  double totalLiveWeight;
  if (lastWeight > 10.0) {
    totalLiveWeight = lastWeight;
  } else {
    final cycle = cycleCtrl.currentCycle;
    final chickCount = int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0;
    final mortality = int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
    totalLiveWeight = lastWeight * (chickCount - mortality);
  }

  if (totalLiveWeight > 0 && totalFeedConsumed > 0) {
    return totalFeedConsumed / totalLiveWeight;
  }
  return 0.0;
}

double getCurrentAverageWeight(CycleController cycleCtrl) {
  final weightEntries = cycleCtrl.getAverageWeightEntries();
  if (weightEntries.isEmpty) return 0.0;
  final lastWeight = weightEntries.last.weight;
  if (lastWeight > 10.0) {
    final cycle = cycleCtrl.currentCycle;
    final chickCount = int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0;
    final mortality = int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
    final alive = chickCount - mortality;
    return alive > 0 ? lastWeight / alive : 0.0;
  }
  return lastWeight;
}

double getExpectedWeight(BroilerController broilerCtrl) {
  final ageDays = (broilerCtrl.selectedChickenAge.value as num?)?.toInt() ?? 0;
  if (ageDays <= 0 || ageDays > weightsList.length) return 0.0;
  return weightsList[ageDays - 1] / 1000.0;
}

double calculateProductionEfficiency(CycleController cycleCtrl, BroilerController broilerCtrl) {
  final ageDays = (broilerCtrl.selectedChickenAge.value as num?)?.toInt() ?? 0;
  if (ageDays <= 0) return 0.0;
  final fcr = calculateFCR(cycleCtrl, broilerCtrl);
  if (fcr <= 0) return 0.0;

  final weightEntries = cycleCtrl.getAverageWeightEntries();
  if (weightEntries.isEmpty) return 0.0;
  final averageWeight = weightEntries.last.weight;
  final cycle = cycleCtrl.currentCycle;
  final chickCount = int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0;
  final mortality = int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
  final aliveChickens = chickCount - mortality;

  double avgWeightPerChicken;
  if (averageWeight > 10.0) {
    avgWeightPerChicken = aliveChickens > 0 ? averageWeight / aliveChickens : 0.0;
  } else {
    avgWeightPerChicken = averageWeight;
  }
  if (avgWeightPerChicken <= 0) return 0.0;
  final double survivalRate = (chickCount > 0 && aliveChickens > 0) ? (aliveChickens / chickCount) * 100.0 : 0.0;
  if (survivalRate <= 0) return 0.0;

  final denominator = ageDays * fcr;
  return denominator > 0 ? (avgWeightPerChicken * survivalRate / denominator) * 100.0 : 0.0;
}

double calculateCostPerChicken(CycleController cycleCtrl) {
  try {
    final expensesCtrl = Get.find<CycleExpensesController>();
    final totalExpenses = expensesCtrl.totalExpenses.value;
    final cycle = cycleCtrl.currentCycle;
    final chickCount = int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0;
    final mortality = int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
    final aliveChickens = chickCount - mortality;
    return (aliveChickens > 0 && totalExpenses > 0) ? totalExpenses / aliveChickens : 0.0;
  } catch (_) {
    return 0.0;
  }
}

String formatWeight(double w) {
  if (w < 1.0) return '${(w * 1000).round()} جرام';
  if (w % 1 == 0) return '${w.round()} كيلو';
  return '${w.toStringAsFixed(1)} كيلو';
}

String formatWeightValue(double w) {
  if (w < 1.0) return (w * 1000).round().toString();
  if (w % 1 == 0) return w.round().toString();
  return w.toStringAsFixed(1);
}

String weightUnit(double w) => w < 1.0 ? 'جرام' : 'كيلو';

double normalizeWeightToGrams(CycleController cycleCtrl, double raw) {
  if (raw <= 0) return 0;
  if (raw > 10.0) {
    final cycle = cycleCtrl.currentCycle;
    final alive = (int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0) -
        (int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0);
    if (alive > 0) {
      final perBird = (raw / alive) * 1000;
      if (perBird <= maxReasonableGramsPerBird) return perBird;
    }
    return raw <= maxReasonableGramsPerBird ? raw : 0;
  }
  return raw * 1000;
}

DateTime? parseDate(String s) {
  if (s.isEmpty) return null;
  return DateTime.tryParse(s) ?? DateTime.tryParse(s.replaceAll('/', '-'));
}

int calcAgeDays(String? startRaw) {
  if (startRaw == null || startRaw.isEmpty) return 0;
  final start = parseDate(startRaw);
  if (start == null) return 0;
  return DateTime.now().difference(start).inDays + 1;
}

int dayOfCycle(String? startRaw, String entryDate) {
  final start = parseDate(startRaw ?? '');
  final entry = parseDate(entryDate);
  if (start == null || entry == null) return 0;
  return entry.difference(start).inDays + 1;
}

double chartInterval(double max) {
  if (max <= 0) return 100;
  final raw = max / 5;
  final logVal = (raw == 0) ? 0.0 : (log(raw) / ln10);
  final mag = pow(10, logVal.floor()).toDouble();
  final res = raw / mag;
  double nice;
  if (res <= 1.5) {
    nice = 1;
  } else if (res <= 3) {
    nice = 2;
  } else if (res <= 7) {
    nice = 5;
  } else {
    nice = 10;
  }
  return nice * mag;
}
