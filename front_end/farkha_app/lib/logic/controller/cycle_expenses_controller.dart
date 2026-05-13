import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/services/initialization.dart';
import '../../data/data_source/remote/cycle_data/cycle_data.dart';
import 'cycle_controller.dart';
import 'cycle_expenses_sync_mixin.dart';

export 'cycle_expenses_sync_mixin.dart';

class CycleExpensesController extends GetxController
    with CycleExpensesSyncMixin {
  CycleExpensesController({
    CycleData? cycleData,
    FirebaseAuth? auth,
    MyServices? myServices,
  })  : _cycleDataOverride = cycleData,
        _authOverride = auth,
        _myServicesOverride = myServices;

  final CycleData? _cycleDataOverride;
  final FirebaseAuth? _authOverride;
  final MyServices? _myServicesOverride;

  @override
  final RxList<ExpenseItem> expenses = <ExpenseItem>[].obs;
  final RxDouble totalExpenses = 0.0.obs;
  late final CycleData _cycleData;
  late final FirebaseAuth _auth;
  @override
  late final MyServices myServices;

  String? _lastCycleId;
  bool _isUpdatingTotalExpenses = false;

  final Rx<StatusRequest> expensesStatus = StatusRequest.none.obs;

  @override
  CycleData get cycleData => _cycleData;

  @override
  FirebaseAuth get auth => _auth;

  @override
  void onInit() {
    super.onInit();
    _cycleData = _cycleDataOverride ?? CycleData();
    _auth = _authOverride ?? FirebaseAuth.instance;
    myServices = _myServicesOverride ?? Get.find<MyServices>();
    _loadDefaultExpenses();
    _loadSavedExpenses();
    calculateTotal();
    _updateLastCycleId();

    final cycleCtrl = Get.find<CycleController>();
    ever(cycleCtrl.currentCycle, (cycle) {
      _checkAndReloadExpenses();
    });
  }

  void _updateLastCycleId() {
    final cycleCtrl = Get.find<CycleController>();
    final cycle = cycleCtrl.currentCycle;
    _lastCycleId = (cycle['name'] ?? 'default').toString();
  }

  String? _lastExpensesHash;

  String _getExpensesHash(List<dynamic> expenses) {
    return expenses
        .map((e) => '${e['id']}_${e['label']}_${e['value']}')
        .join('|');
  }

  void _checkAndReloadExpenses() {
    if (_isUpdatingTotalExpenses) return;

    final cycleCtrl = Get.find<CycleController>();
    final cycle = cycleCtrl.currentCycle;
    final currentCycleId = (cycle['name'] ?? 'default').toString();

    if (_lastCycleId != currentCycleId) {
      _lastCycleId = currentCycleId;
      _lastExpensesHash = null;
      _reloadExpensesForCurrentCycle();
      return;
    }

    final expensesFromApi = cycle['expenses'] as List<dynamic>?;
    if (expensesFromApi != null && expensesFromApi.isNotEmpty) {
      final newHash = _getExpensesHash(expensesFromApi);
      if (_lastExpensesHash != newHash) {
        _lastExpensesHash = newHash;
        loadExpensesFromApi(expensesFromApi);
      }
    } else if (_lastExpensesHash != null) {
      _lastExpensesHash = null;
      _reloadExpensesForCurrentCycle();
    }
  }

  void _reloadExpensesForCurrentCycle() {
    expenses.clear();
    _loadDefaultExpenses();
    _loadSavedExpenses();
    calculateTotal();
  }

  @override
  void reloadExpensesFromCycle() {
    final cycleCtrl = Get.find<CycleController>();
    final cycle = cycleCtrl.currentCycle;
    final expensesFromApi = cycle['expenses'] as List<dynamic>?;
    if (expensesFromApi != null && expensesFromApi.isNotEmpty) {
      loadExpensesFromApi(expensesFromApi);
    } else {
      _reloadExpensesForCurrentCycle();
    }
  }

  void _loadDefaultExpenses() {
    if (expenses.isEmpty) {
      expenses.addAll([
        ExpenseItem(
          id: 'chickens',
          label: 'الكتاكيت',
          icon: ExpenseItem.getIconFromName('receipt'),
        ),
        ExpenseItem(
          id: 'feed',
          label: 'العلف',
          icon: ExpenseItem.getIconFromName('grain'),
        ),
        ExpenseItem(
          id: 'medication',
          label: 'الأدوية والتحصينات',
          icon: ExpenseItem.getIconFromName('medication'),
        ),
        ExpenseItem(
          id: 'electricity',
          label: 'الكهرباء',
          icon: ExpenseItem.getIconFromName('bolt'),
        ),
        ExpenseItem(
          id: 'water',
          label: 'المياه',
          icon: ExpenseItem.getIconFromName('water_drop'),
        ),
        ExpenseItem(
          id: 'transport',
          label: 'النقل',
          icon: ExpenseItem.getIconFromName('local_shipping'),
        ),
        ExpenseItem(
          id: 'labor',
          label: 'العمالة',
          icon: ExpenseItem.getIconFromName('people'),
        ),
      ]);
    }
  }

  void _loadSavedExpenses() {
    final cycleCtrl = Get.find<CycleController>();
    final cycle = cycleCtrl.currentCycle;

    final expensesFromApi = cycle['expenses'] as List<dynamic>?;
    if (expensesFromApi != null && expensesFromApi.isNotEmpty) {
      loadExpensesFromApi(expensesFromApi);
    }
  }

  Future<void> addPayment(int expenseIndex, double amount) async {
    if (expenseIndex >= 0 && expenseIndex < expenses.length && amount > 0) {
      expensesStatus.value = StatusRequest.loading;

      try {
        final now = DateTime.now();
        final paymentId = 'payment_${now.millisecondsSinceEpoch}';
        final payment = ExpensePayment(
          id: paymentId,
          amount: amount,
          date: now,
        );
        expenses[expenseIndex].payments.add(payment);
        calculateTotal();

        final result = await sendExpenseToServer(
          label: expenses[expenseIndex].label,
          value: amount,
        );

        if (result != null && result['expense_id'] != null) {
          final apiId = result['expense_id'].toString();
          final paymentIndex = expenses[expenseIndex].payments.indexWhere(
            (p) => p.id == paymentId,
          );
          if (paymentIndex != -1) {
            final updatedPayment = ExpensePayment(
              id: apiId,
              amount: payment.amount,
              date: payment.date,
            );
            expenses[expenseIndex].payments[paymentIndex] = updatedPayment;
            calculateTotal();
          }
        }

        expensesStatus.value = StatusRequest.success;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (expensesStatus.value == StatusRequest.success) {
            expensesStatus.value = StatusRequest.none;
          }
        });
      } catch (e) {
        expensesStatus.value = StatusRequest.serverFailure;
        Future.delayed(const Duration(milliseconds: 2000), () {
          expensesStatus.value = StatusRequest.none;
        });
      }
    }
  }

  Future<void> removePayment(int expenseIndex, int paymentIndex) async {
    if (expenseIndex >= 0 &&
        expenseIndex < expenses.length &&
        paymentIndex >= 0 &&
        paymentIndex < expenses[expenseIndex].payments.length) {
      final payment = expenses[expenseIndex].payments[paymentIndex];
      expenses[expenseIndex].payments.removeAt(paymentIndex);
      calculateTotal();

      final cycleCtrl = Get.find<CycleController>();
      final cycleId = cycleCtrl.currentCycle['cycle_id'];
      final itemId = int.tryParse(payment.id);

      if (itemId != null && itemId > 0 && cycleId != null) {
        deleteExpenseFromServerInBackground(cycleId: cycleId, itemId: itemId);
      }
    }
  }

  void addExpense(String label, IconData icon) {
    final newId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    expenses.add(ExpenseItem(id: newId, label: label, icon: icon));
  }

  Future<void> removeExpense(int index) async {
    if (index >= 0 && index < expenses.length) {
      final expense = expenses[index];
      expenses.removeAt(index);
      calculateTotal();

      final cycleCtrl = Get.find<CycleController>();
      final cycleId = cycleCtrl.currentCycle['cycle_id'];

      if (cycleId != null) {
        deleteExpenseFromServerInBackground(
          cycleId: cycleId,
          label: expense.label,
        );
      }
    }
  }

  @override
  void calculateTotal() {
    totalExpenses.value = expenses.fold(
      0.0,
      (sum, expense) => sum + expense.totalAmount,
    );

    _updateCycleTotalExpenses();
  }

  void _updateCycleTotalExpenses() {
    try {
      if (!Get.isRegistered<CycleController>()) return;

      if (_isUpdatingTotalExpenses) return;
      _isUpdatingTotalExpenses = true;

      final cycleCtrl = Get.find<CycleController>();
      final cycleName = cycleCtrl.currentCycle['name'];
      if (cycleName == null || cycleName.toString().isEmpty) {
        _isUpdatingTotalExpenses = false;
        return;
      }

      final idx = cycleCtrl.cycles.indexWhere((c) => c['name'] == cycleName);
      if (idx == -1) {
        _isUpdatingTotalExpenses = false;
        return;
      }

      final total = totalExpenses.value;
      final totalStr = total.toString();

      final currentTotalStr =
          cycleCtrl.cycles[idx]['total_expenses']?.toString() ?? '0';
      final needsUpdate = currentTotalStr != totalStr;

      if (needsUpdate) {
        cycleCtrl.cycles[idx]['total_expenses'] = totalStr;

        if (cycleCtrl.currentCycle['total_expenses'] != totalStr) {
          cycleCtrl.currentCycle['total_expenses'] = totalStr;
        }

        cycleCtrl.cycles.refresh();
      }

      _isUpdatingTotalExpenses = false;
    } catch (e) {
      _isUpdatingTotalExpenses = false;
    }
  }

  double getTotalExpenses() => totalExpenses.value;
}
