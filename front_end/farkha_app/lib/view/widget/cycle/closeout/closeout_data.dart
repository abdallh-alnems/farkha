import 'package:flutter/material.dart';

import '../../../../data/data_source/static/chicken_data.dart';

class CloseoutData {
  final String name;
  final String breed;
  final String systemType;
  final String startDate;
  final String space;
  final int ageDays;
  final int chickCount;
  final int mortality;
  final double mortalityRate;
  final int liveCount;
  final double avgWeight;
  final double totalMeat;
  final double totalFeed;
  final double fcr;
  final double epef;
  final double costPerBird;
  final double expectedWeight;
  final double totalExpenses;
  final double totalSales;
  final double netProfit;

  CloseoutData({
    required this.name,
    required this.breed,
    required this.systemType,
    required this.startDate,
    required this.space,
    required this.ageDays,
    required this.chickCount,
    required this.mortality,
    required this.mortalityRate,
    required this.liveCount,
    required this.avgWeight,
    required this.totalMeat,
    required this.totalFeed,
    required this.fcr,
    required this.epef,
    required this.costPerBird,
    required this.expectedWeight,
    required this.totalExpenses,
    required this.totalSales,
    required this.netProfit,
  });
}

class InfoItem {
  final String label;
  final String value;
  final IconData icon;
  InfoItem(this.label, this.value, this.icon);
}

class MetricData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  MetricData(this.label, this.value, this.icon, this.color);
}

String fmtWeight(double kg) {
  if (kg < 1.0) return '${(kg * 1000).round()} جم';
  return '${kg.toStringAsFixed(2)} كجم';
}

CloseoutData calculateCloseoutData(Map<String, dynamic> cycle) {
  final name = cycle['name']?.toString() ?? 'دورة بدون اسم';
  final breed = cycle['breed']?.toString() ?? 'تسمين';
  final systemType = cycle['systemType']?.toString() ?? 'أرضي';
  final startDate = cycle['startDate']?.toString() ?? '-';
  final space = cycle['space']?.toString() ?? '0';
  final ageDays = int.tryParse(cycle['cycle_age']?.toString() ?? '0') ?? 0;

  final chickCount = int.tryParse(
        cycle['chickCount']?.toString() ??
            cycle['chick_count']?.toString() ??
            '0',
      ) ??
      0;
  final mortality =
      int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
  final mortalityRate = double.tryParse(
          cycle['mortality_rate']?.toString() ?? '0') ??
      0.0;
  final liveCount = chickCount - mortality;

  final avgWeight = double.tryParse(
          cycle['average_weight']?.toString() ?? '0') ??
      0.0;
  final totalMeat = liveCount * avgWeight;
  final totalFeed = double.tryParse(
          cycle['total_feed']?.toString() ?? '0') ??
      0.0;
  final totalExpenses = double.tryParse(
          cycle['total_expenses']?.toString() ?? '0') ??
      0.0;
  final totalSales = double.tryParse(
          cycle['total_sales']?.toString() ?? '0') ??
      0.0;
  final netProfit = double.tryParse(
          cycle['net_profit']?.toString() ?? '0') ??
      0.0;
  final costPerBird = liveCount > 0 ? totalExpenses / liveCount : 0.0;

  final fcr = (avgWeight > 0 && liveCount > 0)
      ? totalFeed / (liveCount * avgWeight)
      : 0.0;

  final survivalRate =
      chickCount > 0 ? (liveCount / chickCount) * 100 : 0.0;
  final epef = (ageDays > 0 && fcr > 0)
      ? (avgWeight * survivalRate) / (ageDays * fcr) * 100
      : 0.0;

  double expectedWeight = 0.0;
  if (ageDays > 0 && ageDays <= weightsList.length) {
    expectedWeight = weightsList[ageDays - 1] / 1000.0;
  }

  return CloseoutData(
    name: name,
    breed: breed,
    systemType: systemType,
    startDate: startDate,
    space: space,
    ageDays: ageDays,
    chickCount: chickCount,
    mortality: mortality,
    mortalityRate: mortalityRate,
    liveCount: liveCount,
    avgWeight: avgWeight,
    totalMeat: totalMeat,
    totalFeed: totalFeed,
    fcr: fcr,
    epef: epef,
    costPerBird: costPerBird,
    expectedWeight: expectedWeight,
    totalExpenses: totalExpenses,
    totalSales: totalSales,
    netProfit: netProfit,
  );
}
