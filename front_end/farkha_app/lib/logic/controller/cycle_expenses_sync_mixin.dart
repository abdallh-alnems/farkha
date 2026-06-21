import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constant/storage_keys.dart';
import '../../core/functions/number_format.dart';
import '../../core/functions/parse_entry_date.dart';
import '../../core/services/initialization.dart';
import '../../data/data_source/remote/cycle_data/cycle_data.dart';
import 'cycle_controller.dart';

class ExpensePayment {
  final String id;
  final double amount;
  final DateTime date;

  ExpensePayment({required this.id, required this.amount, required this.date});

  Map<String, dynamic> toJson() {
    return {'id': id, 'amount': amount, 'date': date.toIso8601String()};
  }

  factory ExpensePayment.fromJson(Map<String, dynamic> json) {
    return ExpensePayment(
      id: (json['id'] ?? '').toString(),
      amount: ((json['amount'] ?? 0.0) as num).toDouble(),
      date: parseEntryDate(json['date']),
    );
  }
}

class ExpenseItem {
  final String id;
  final String label;
  final IconData icon;
  final RxList<ExpensePayment> payments;

  static const Map<String, IconData> _iconMap = {
    'receipt': Icons.receipt,
    'grain': Icons.grain,
    'medication': Icons.medication,
    'bolt': Icons.bolt,
    'water_drop': Icons.water_drop,
    'local_shipping': Icons.local_shipping,
    'people': Icons.people,
  };

  ExpenseItem({
    required this.id,
    required this.label,
    required this.icon,
    List<ExpensePayment>? payments,
  }) : payments = (payments ?? <ExpensePayment>[]).obs;

  double get totalAmount {
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  static String getIconName(IconData icon) {
    for (final entry in _iconMap.entries) {
      if (entry.value.codePoint == icon.codePoint) {
        return entry.key;
      }
    }
    return 'receipt';
  }

  static IconData getIconFromName(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.receipt;
    }
    return _iconMap[iconName] ?? Icons.receipt;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'icon': getIconName(icon),
      'payments': payments.map((p) => p.toJson()).toList(),
    };
  }

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    final paymentsList =
        (json['payments'] as List<dynamic>?)
            ?.map((p) => ExpensePayment.fromJson(p as Map<String, dynamic>))
            .toList() ??
        <ExpensePayment>[];

    final iconValue = json['icon'];
    IconData iconData;

    if (iconValue is String) {
      iconData = getIconFromName(iconValue);
    } else if (iconValue is int) {
      iconData = Icons.receipt;
    } else {
      iconData = Icons.receipt;
    }

    return ExpenseItem(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      icon: iconData,
      payments: paymentsList,
    );
  }
}

mixin CycleExpensesSyncMixin on GetxController {
  CycleData get cycleData;
  FirebaseAuth get auth;
  MyServices get myServices;
  RxList<ExpenseItem> get expenses;

  void calculateTotal();
  void reloadExpensesFromCycle();

  Future<Map<String, dynamic>?> sendExpenseToServer({
    required String label,
    required double value,
  }) async {
    try {
      final cycleCtrl = Get.find<CycleController>();
      final cycleId = cycleCtrl.currentCycle['cycle_id'];
      if (cycleId == null) return null;

      final isLoggedIn =
          myServices.getStorage.read<bool>(StorageKeys.isLoggedIn) ?? false;
      if (!isLoggedIn) return null;

      final user = auth.currentUser;
      if (user == null) return null;

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) return null;

      final result = await cycleData.addCycleExpense(
        token: token,
        cycleId:
            cycleId is int ? cycleId : int.tryParse(cycleId.toString()) ?? 0,
        label: label,
        value: value,
      );

      return result.fold(
        (l) => null,
        (r) {
          final status = r['status']?.toString() ?? '';
          if (status == 'success') {
            final data = r['data'];
            if (data is Map) {
              return Map<String, dynamic>.from(data);
            }
            return Map<String, dynamic>.from(r);
          }
          return null;
        },
      );
    } catch (e) {
      return null;
    }
  }

  void deleteExpenseFromServerInBackground({
    required dynamic cycleId,
    int? itemId,
    String? label,
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
          type: 'expense',
          deleteType: itemId != null ? 'single' : 'by_label',
          itemId: itemId,
          label: label,
        );

        final cycleCtrl = Get.find<CycleController>();
        final cycleIdInt =
            cycleId is int ? cycleId : int.tryParse(cycleId.toString());
        if (cycleIdInt != null && cycleIdInt > 0) {
          await cycleCtrl.fetchCycleDetails(cycleIdInt);
          reloadExpensesFromCycle();
        }
      } catch (_) {}
    });
  }

  void loadExpensesFromApi(List<dynamic> expensesFromApi) {
    final expensesMap = <String, List<Map<String, dynamic>>>{};

    for (var expense in expensesFromApi) {
      final label =
          expense['label']?.toString() ?? expense['type']?.toString() ?? '';
      final value = expense['value'] ?? expense['amount'];
      final entryDateStr =
          expense['entry_date']?.toString() ??
          expense['created_at']?.toString() ??
          '';

      if (label.isEmpty) continue;

      final entryDate = parseEntryDate(entryDateStr);

      double amount = 0.0;
      if (value is num) {
        amount = value.toDouble();
      } else if (value is String) {
        amount = tryParseNum(value) ?? 0.0;
      }

      if (amount <= 0) continue;

      if (!expensesMap.containsKey(label)) {
        expensesMap[label] = [];
      }
      expensesMap[label]!.add({
        'id':
            expense['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        'amount': amount,
        'date': entryDate.toIso8601String(),
      });
    }

    for (var expense in expenses) {
      final label = expense.label;
      final paymentsFromApi = expensesMap[label];

      if (paymentsFromApi != null && paymentsFromApi.isNotEmpty) {
        final apiPayments =
            paymentsFromApi
                .map(
                  (p) => ExpensePayment(
                    id: p['id'] as String,
                    amount: p['amount'] as double,
                    date:
                        DateTime.tryParse(p['date'] as String) ?? DateTime.now(),
                  ),
                )
                .toList();

        for (var localPayment in expense.payments) {
          if (localPayment.id.startsWith('payment_')) {
            bool existsInApi = false;
            for (var apiPayment in apiPayments) {
              final amountMatch =
                  (apiPayment.amount - localPayment.amount).abs() < 0.01;
              final dateDiff =
                  apiPayment.date.difference(localPayment.date).abs();
              if (amountMatch && dateDiff.inMinutes <= 5) {
                existsInApi = true;
                break;
              }
            }

            if (!existsInApi) {
              apiPayments.add(localPayment);
            }
          }
        }

        expense.payments.clear();
        expense.payments.addAll(apiPayments);
      }
    }

    final existingLabels = expenses.map((e) => e.label).toSet();
    expensesMap.forEach((label, payments) {
      if (!existingLabels.contains(label)) {
        final icon = getIconForLabel(label);
        final newItem = ExpenseItem(
          id: 'api_${label}_${DateTime.now().millisecondsSinceEpoch}',
          label: label,
          icon: icon,
          payments:
              payments
                  .map(
                    (p) => ExpensePayment(
                      id: p['id'] as String,
                      amount: p['amount'] as double,
                      date:
                          DateTime.tryParse(p['date'] as String) ??
                          DateTime.now(),
                    ),
                  )
                  .toList(),
        );
        expenses.add(newItem);
      }
    });

    calculateTotal();
  }

  IconData getIconForLabel(String label) {
    final labelLower = label.toLowerCase();
    String iconName = 'receipt';

    if (labelLower.contains('كتاكيت') || labelLower.contains('chicken')) {
      iconName = 'receipt';
    } else if (labelLower.contains('علف') || labelLower.contains('feed')) {
      iconName = 'grain';
    } else if (labelLower.contains('دواء') ||
        labelLower.contains('تحصين') ||
        labelLower.contains('medication')) {
      iconName = 'medication';
    } else if (labelLower.contains('كهرباء') ||
        labelLower.contains('electricity')) {
      iconName = 'bolt';
    } else if (labelLower.contains('ماء') || labelLower.contains('water')) {
      iconName = 'water_drop';
    } else if (labelLower.contains('نقل') || labelLower.contains('transport')) {
      iconName = 'local_shipping';
    } else if (labelLower.contains('عامل') || labelLower.contains('labor')) {
      iconName = 'people';
    }

    return ExpenseItem.getIconFromName(iconName);
  }
}
