import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/class/status_request.dart';
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
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }
}

class ExpenseItem {
  final String id;
  final String label;
  final IconData icon;
  final RxList<ExpensePayment> payments;

  // Map للأيقونات الشائعة - const للسماح لـ tree-shaking بالعمل
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

  // Helper method للحصول على اسم الأيقونة من IconData
  static String _getIconName(IconData icon) {
    for (final entry in _iconMap.entries) {
      if (entry.value.codePoint == icon.codePoint) {
        return entry.key;
      }
    }
    return 'receipt'; // افتراضي
  }

  // Helper method للحصول على IconData من اسم الأيقونة
  static IconData _getIconFromName(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.receipt; // أيقونة افتراضية
    }
    return _iconMap[iconName] ?? Icons.receipt;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'icon': _getIconName(icon), // حفظ اسم الأيقونة بدلاً من codePoint
      'payments': payments.map((p) => p.toJson()).toList(),
    };
  }

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    final paymentsList =
        (json['payments'] as List<dynamic>?)
            ?.map((p) => ExpensePayment.fromJson(p as Map<String, dynamic>))
            .toList() ??
        <ExpensePayment>[];

    // دعم البيانات القديمة (codePoint) والجديدة (icon name)
    final iconValue = json['icon'];
    IconData iconData;

    if (iconValue is String) {
      // البيانات الجديدة: اسم الأيقونة
      iconData = _getIconFromName(iconValue);
    } else if (iconValue is int) {
      // البيانات القديمة: codePoint - نحولها إلى أيقونة افتراضية
      iconData = Icons.receipt;
    } else {
      // قيمة غير معروفة - أيقونة افتراضية
      iconData = Icons.receipt;
    }

    return ExpenseItem(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      icon: iconData,
      payments: paymentsList,
    );
  }
}

class CycleExpensesController extends GetxController {
  final GetStorage _storage = GetStorage();
  final RxList<ExpenseItem> expenses = <ExpenseItem>[].obs;
  final RxDouble totalExpenses = 0.0.obs;
  late final CycleData _cycleData;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MyServices myServices = Get.find<MyServices>();

  String? _lastCycleId;
  bool _isUpdatingTotalExpenses = false;

  // حالة التحميل للمصروفات
  final Rx<StatusRequest> expensesStatus = StatusRequest.none.obs;

  @override
  void onInit() {
    super.onInit();
    _cycleData = CycleData();
    _loadDefaultExpenses();
    _loadSavedExpenses();
    _calculateTotal();
    _updateLastCycleId();

    // مراقبة تغيير الدورة
    final cycleCtrl = Get.find<CycleController>();
    ever(cycleCtrl.currentCycle, (cycle) {
      // _checkAndReloadExpenses تتحقق من تغيير الدورة والمصروفات وتمنع التحديثات المتكررة
      _checkAndReloadExpenses();
    });
  }

  void _updateLastCycleId() {
    final cycleCtrl = Get.find<CycleController>();
    final cycle = cycleCtrl.currentCycle;
    _lastCycleId = cycle['name'] ?? 'default';
  }

  String? _lastExpensesHash;

  String _getExpensesHash(List<dynamic> expenses) {
    // إنشاء hash بسيط للمصروفات لتحديد ما إذا تغيرت
    return expenses
        .map((e) => '${e['id']}_${e['label']}_${e['value']}')
        .join('|');
  }

  void _checkAndReloadExpenses() {
    // منع التحديثات المتكررة أثناء تحديث total_expenses
    if (_isUpdatingTotalExpenses) return;

    final cycleCtrl = Get.find<CycleController>();
    final cycle = cycleCtrl.currentCycle;
    final currentCycleId = cycle['name'] ?? 'default';

    // إعادة تحميل المصروفات فقط إذا تغيرت الدورة
    if (_lastCycleId != currentCycleId) {
      _lastCycleId = currentCycleId;
      _lastExpensesHash = null; // إعادة تعيين hash عند تغيير الدورة
      _reloadExpensesForCurrentCycle();
      return;
    }

    // التحقق من تغيير المصروفات فقط (وليس total_expenses)
    final expensesFromApi = cycle['expenses'] as List<dynamic>?;
    if (expensesFromApi != null && expensesFromApi.isNotEmpty) {
      final newHash = _getExpensesHash(expensesFromApi);
      if (_lastExpensesHash != newHash) {
        _lastExpensesHash = newHash;
        // _loadExpensesFromApi تستدعي _calculateTotal() داخلياً
        _loadExpensesFromApi(expensesFromApi);
      }
    } else if (_lastExpensesHash != null) {
      // إذا لم تكن هناك مصروفات من API بعد أن كانت موجودة
      _lastExpensesHash = null;
      _reloadExpensesForCurrentCycle();
    }
  }

  void _reloadExpensesForCurrentCycle() {
    // إعادة تحميل المصروفات للدورة الحالية
    expenses.clear();
    _loadDefaultExpenses();
    _loadSavedExpenses();
    _calculateTotal();
  }

  // طريقة عامة لإعادة تحميل المصروفات من API
  void reloadExpensesFromCycle() {
    final cycleCtrl = Get.find<CycleController>();
    final cycle = cycleCtrl.currentCycle;
    final expensesFromApi = cycle['expenses'] as List<dynamic>?;
    if (expensesFromApi != null && expensesFromApi.isNotEmpty) {
      // _loadExpensesFromApi تستدعي _calculateTotal() داخلياً، لا حاجة لاستدعائها هنا
      _loadExpensesFromApi(expensesFromApi);
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
          icon: ExpenseItem._getIconFromName('receipt'),
        ),
        ExpenseItem(
          id: 'feed',
          label: 'العلف',
          icon: ExpenseItem._getIconFromName('grain'),
        ),
        ExpenseItem(
          id: 'medication',
          label: 'الأدوية والتحصينات',
          icon: ExpenseItem._getIconFromName('medication'),
        ),
        ExpenseItem(
          id: 'electricity',
          label: 'الكهرباء',
          icon: ExpenseItem._getIconFromName('bolt'),
        ),
        ExpenseItem(
          id: 'water',
          label: 'المياه',
          icon: ExpenseItem._getIconFromName('water_drop'),
        ),
        ExpenseItem(
          id: 'transport',
          label: 'النقل',
          icon: ExpenseItem._getIconFromName('local_shipping'),
        ),
        ExpenseItem(
          id: 'labor',
          label: 'العمالة',
          icon: ExpenseItem._getIconFromName('people'),
        ),
      ]);
    }
  }

  void _loadSavedExpenses() {
    final cycleCtrl = Get.find<CycleController>();
    final cycle = cycleCtrl.currentCycle;
    final cycleId = cycle['name'] ?? 'default';
    final storageKey = 'expenses_$cycleId';

    // التحقق من أن الدورة موجودة فعلاً في cycles (لم يتم حذفها)
    final cycleExists = cycleCtrl.cycles.any((c) => c['name'] == cycleId);
    if (!cycleExists) {
      // إذا لم تكن الدورة موجودة، لا تحمل البيانات القديمة
      expenses.clear();
      _loadDefaultExpenses();
      _calculateTotal();
      return;
    }

    // أولاً: جلب المصروفات من API إذا كانت موجودة
    final expensesFromApi = cycle['expenses'] as List<dynamic>?;
    if (expensesFromApi != null && expensesFromApi.isNotEmpty) {
      _loadExpensesFromApi(expensesFromApi);
      return;
    }

    // إذا لم تكن هناك مصروفات من API، جلب من التخزين المحلي
    // فقط إذا كانت الدورة تحتوي على cycle_id (من API) أو إذا كانت موجودة في cycles
    final saved = _storage.read<List>(storageKey);
    if (saved != null && saved.isNotEmpty && cycleExists) {
      final savedExpenses =
          saved
              .map((e) => ExpenseItem.fromJson(e as Map<String, dynamic>))
              .toList();

      // استبدال المصروفات الافتراضية بالمحفوظة
      expenses.clear();
      expenses.addAll(savedExpenses);
    }
  }

  void _loadExpensesFromApi(List<dynamic> expensesFromApi) {
    // تجميع المصروفات حسب label
    final expensesMap = <String, List<Map<String, dynamic>>>{};

    for (var expense in expensesFromApi) {
      final label = expense['label']?.toString() ?? '';
      final value = expense['value'];
      final entryDateStr = expense['entry_date']?.toString() ?? '';

      if (label.isEmpty) continue;

      // تحويل entry_date من ISO8601 إلى DateTime
      DateTime entryDate = DateTime.now();
      if (entryDateStr.isNotEmpty) {
        try {
          entryDate = DateTime.tryParse(entryDateStr) ?? DateTime.now();
        } catch (e) {
          entryDate = DateTime.now();
        }
      }

      // تحويل value إلى double
      double amount = 0.0;
      if (value is num) {
        amount = value.toDouble();
      } else if (value is String) {
        amount = double.tryParse(value) ?? 0.0;
      }

      if (amount <= 0) continue;

      // إضافة إلى الخريطة
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

    // الحفاظ على ترتيب المصروفات الافتراضية
    // تحديث المدفوعات فقط دون تغيير الترتيب
    for (var expense in expenses) {
      final label = expense.label;
      final paymentsFromApi = expensesMap[label];

      if (paymentsFromApi != null && paymentsFromApi.isNotEmpty) {
        // إنشاء قائمة جديدة من المدفوعات من API
        final apiPayments =
            paymentsFromApi
                .map(
                  (p) => ExpensePayment(
                    id: p['id'] as String,
                    amount: p['amount'] as double,
                    date:
                        DateTime.tryParse(p['date'] as String) ??
                        DateTime.now(),
                  ),
                )
                .toList();

        // دمج المدفوعات المحلية (التي لم يتم إرسالها إلى API بعد)
        for (var localPayment in expense.payments) {
          // إذا كان payment ID يبدأ بـ 'payment_' فهو محلي
          if (localPayment.id.startsWith('payment_')) {
            // التحقق من أن هذه المدفوعة المحلية لم تُضاف بعد إلى API
            // عن طريق مقارنة المبلغ والتاريخ (مع هامش 5 دقائق)
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

            // إذا لم تكن موجودة في API، أضفها
            if (!existsInApi) {
              apiPayments.add(localPayment);
            }
          }
        }

        // تحديث المدفوعات فقط (بدون تغيير الترتيب)
        expense.payments.clear();
        expense.payments.addAll(apiPayments);
      }
    }

    // إضافة المصروفات الجديدة من API التي لم تكن موجودة في القائمة الافتراضية
    final existingLabels = expenses.map((e) => e.label).toSet();
    expensesMap.forEach((label, payments) {
      if (!existingLabels.contains(label)) {
        // إنشاء ExpenseItem جديد
        final icon = _getIconForLabel(label);
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
        // إضافة في النهاية للحفاظ على ترتيب المصروفات الافتراضية
        expenses.add(newItem);
      }
    });

    // تحديث إجمالي المصروفات بعد تحميل البيانات من API
    _calculateTotal();
  }

  IconData _getIconForLabel(String label) {
    // تحديد الأيقونة المناسبة حسب الـ label
    final labelLower = label.toLowerCase();
    String iconName = 'receipt'; // افتراضي

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

    return ExpenseItem._getIconFromName(iconName);
  }

  void _saveExpenses() {
    final cycleCtrl = Get.find<CycleController>();
    final cycle = cycleCtrl.currentCycle;
    final cycleId = cycle['name'] ?? 'default';
    final storageKey = 'expenses_$cycleId';

    final expensesJson = expenses.map((e) => e.toJson()).toList();
    _storage.write(storageKey, expensesJson);
  }

  Future<Map<String, dynamic>?> _sendExpenseToServer({
    required String label,
    required double value,
  }) async {
    try {
      final cycleCtrl = Get.find<CycleController>();
      final cycleId = cycleCtrl.currentCycle['cycle_id'];
      if (cycleId == null) return null;

      final isLoggedIn =
          myServices.getStorage.read<bool>('is_logged_in') ?? false;
      if (!isLoggedIn) return null;

      final user = _auth.currentUser;
      if (user == null) return null;

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) return null;

      final result = await _cycleData.addCycleExpense(
        token: token,
        cycleId:
            cycleId is int ? cycleId : int.tryParse(cycleId.toString()) ?? 0,
        label: label,
        value: value,
      );

      // إرجاع البيانات من API
      return result.fold(
        (l) => null, // فشل
        (r) {
          // نجح - التحقق من status وإرجاع البيانات
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
      // في حالة الفشل، لا نفعل شيئاً - البيانات محفوظة محلياً
      return null;
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
        _calculateTotal();
        _saveExpenses();

        // إرسال المصروف إلى API
        final result = await _sendExpenseToServer(
          label: expenses[expenseIndex].label,
          value: amount,
        );

        // إذا تم الإرسال بنجاح، تحديث ID المدفوعة المحلية بالـ ID من API
        if (result != null && result['expense_id'] != null) {
          final apiId = result['expense_id'].toString();
          // البحث عن المدفوعة المحلية وتحديث ID
          final paymentIndex = expenses[expenseIndex].payments.indexWhere(
            (p) => p.id == paymentId,
          );
          if (paymentIndex != -1) {
            // إنشاء مدفوعة جديدة بالـ ID من API
            final updatedPayment = ExpensePayment(
              id: apiId,
              amount: payment.amount,
              date: payment.date,
            );
            expenses[expenseIndex].payments[paymentIndex] = updatedPayment;
            _calculateTotal();
            _saveExpenses();
          }
        }

        expensesStatus.value = StatusRequest.success;
        // إعادة تعيين الحالة بعد قليل
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
      // الحذف المحلي فوراً
      final payment = expenses[expenseIndex].payments[paymentIndex];
      expenses[expenseIndex].payments.removeAt(paymentIndex);
      _calculateTotal();
      _saveExpenses();

      // حذف من API في الخلفية
      final cycleCtrl = Get.find<CycleController>();
      final cycleId = cycleCtrl.currentCycle['cycle_id'];
      final itemId = int.tryParse(payment.id);

      if (itemId != null && itemId > 0 && cycleId != null) {
        _deleteExpenseFromServerInBackground(cycleId: cycleId, itemId: itemId);
      }
    }
  }

  void addExpense(String label, IconData icon) {
    final newId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    expenses.add(ExpenseItem(id: newId, label: label, icon: icon));
    _saveExpenses();
  }

  Future<void> removeExpense(int index) async {
    if (index >= 0 && index < expenses.length) {
      // الحذف المحلي فوراً
      final expense = expenses[index];
      expenses.removeAt(index);
      _calculateTotal();
      _saveExpenses();

      // حذف من API في الخلفية
      final cycleCtrl = Get.find<CycleController>();
      final cycleId = cycleCtrl.currentCycle['cycle_id'];

      if (cycleId != null) {
        _deleteExpenseFromServerInBackground(
          cycleId: cycleId,
          label: expense.label,
        );
      }
    }
  }

  void _calculateTotal() {
    totalExpenses.value = expenses.fold(
      0.0,
      (sum, expense) => sum + expense.totalAmount,
    );

    // تحديث total_expenses في cycles و currentCycle
    _updateCycleTotalExpenses();
  }

  void _updateCycleTotalExpenses() {
    try {
      if (!Get.isRegistered<CycleController>()) return;

      // منع التحديثات المتكررة
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

      // التحقق من أن القيمة تغيرت فعلاً قبل التحديث
      final currentTotalStr =
          cycleCtrl.cycles[idx]['total_expenses']?.toString() ?? '0';
      final needsUpdate = currentTotalStr != totalStr;

      if (needsUpdate) {
        // تحديث total_expenses في cycles
        cycleCtrl.cycles[idx]['total_expenses'] = totalStr;

        // تحديث total_expenses في currentCycle مباشرة (دون assignAll لتجنب إعادة تشغيل ever)
        // لأن _checkAndReloadExpenses تتحقق من تغيير expenses فقط، وليس total_expenses
        if (cycleCtrl.currentCycle['total_expenses'] != totalStr) {
          cycleCtrl.currentCycle['total_expenses'] = totalStr;
        }

        // حفظ في GetStorage
        final cycleStorageKey = 'cycles';
        myServices.getStorage.write(cycleStorageKey, cycleCtrl.cycles.toList());

        // تحديث cycles لإعادة بناء الواجهة (فقط عند التغيير)
        cycleCtrl.cycles.refresh();
      }

      _isUpdatingTotalExpenses = false;
    } catch (e) {
      _isUpdatingTotalExpenses = false;
      // في حالة حدوث خطأ، لا شيء
    }
  }

  double getTotalExpenses() => totalExpenses.value;

  void _deleteExpenseFromServerInBackground({
    required dynamic cycleId,
    int? itemId,
    String? label,
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
          type: 'expense',
          deleteType: itemId != null ? 'single' : 'by_label',
          itemId: itemId,
          label: label,
        );

        // بعد نجاح الحذف، إعادة تحميل البيانات من API
        final cycleCtrl = Get.find<CycleController>();
        final cycleIdInt =
            cycleId is int ? cycleId : int.tryParse(cycleId.toString());
        if (cycleIdInt != null && cycleIdInt > 0) {
          await cycleCtrl.fetchCycleDetails(cycleIdInt);
          // إعادة تحميل المصروفات من currentCycle
          reloadExpensesFromCycle();
        }
      } catch (e) {
        // في حالة الفشل، لا شيء
      }
    });
  }
}
