import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/storage_keys.dart';
import '../../core/services/notification_service.dart';
import 'cycle_controller_base.dart';
import 'cycle_expenses_controller.dart';

mixin CycleEndMixin on CycleControllerBase {
  @override
  void checkAndAutoEndCycles() {
    if (cycles.isEmpty) return;

    final List<Map<String, dynamic>> activeCycles =
        List<Map<String, dynamic>>.from(cycles);
    final List<({Map<String, dynamic> cycle, String autoEndDate})> cyclesToEnd =
        [];

    for (final cycle in activeCycles) {
      final startDateRaw = cycle['startDateRaw']?.toString() ?? '';
      if (startDateRaw.isEmpty) continue;

      try {
        final startD = DateTime.parse(startDateRaw);
        final now = DateTime.now();
        final age = now.difference(startD).inDays + 1;

        if (age >= 45) {
          final day45 = startD.add(const Duration(days: 44));
          final autoEndDate = DateFormat('yyyy-MM-dd').format(day45);
          cyclesToEnd.add((cycle: cycle, autoEndDate: autoEndDate));
        }
      } catch (_) {}
    }

    if (cyclesToEnd.isNotEmpty) {
      _showSalesBeforeCloseDialog(cyclesToEnd, 0);
    }
  }

  void _showSalesBeforeCloseDialog(
    List<({Map<String, dynamic> cycle, String autoEndDate})> pendingCycles,
    int index,
  ) {
    if (index >= pendingCycles.length) return;

    final entry = pendingCycles[index];
    final cycle = entry.cycle;
    final autoEndDate = entry.autoEndDate;
    final cycleName = cycle['name']?.toString() ?? 'الدورة';

    void proceedToNext() {
      _showSalesBeforeCloseDialog(pendingCycles, index + 1);
    }

    Future<void> closeCycleAndProceed() async {
      await endCurrentCycle(endDate: autoEndDate, cycleOverride: cycle);
      proceedToNext();
    }

    Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'تنبيه – إغلاق دورة "$cycleName"',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          ],
        ),
        content: const Text(
          'وصلت الدورة إلى عمر 45 يوماً وستُغلق تلقائياً.\n\nيُنصح بإدخال بيانات المبيعات أولاً لضمان دقة التقارير المالية.',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back<void>();
              unawaited(closeCycleAndProceed());
            },
            child: const Text(
              'إغلاق',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
            icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
            label: const Text(
              'إدخال المبيعات',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onPressed: () async {
              Get.back<void>();
              currentCycle.assignAll(cycle);
              if (!Get.isRegistered<CycleExpensesController>()) {
                Get.put(CycleExpensesController());
              }
              await Get.toNamed<void>('/cycleSales');
              unawaited(closeCycleAndProceed());
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<bool> endCurrentCycle({
    String? endDate,
    Map<String, dynamic>? cycleOverride,
  }) async {
    final cycleToEnd = cycleOverride ?? currentCycle;
    final idx = cycles.indexWhere((c) => c['name'] == cycleToEnd['name']);
    if (idx == -1) return false;

    if (cycleToEnd['endDateRaw'] != null &&
        cycleToEnd['endDateRaw'].toString().isNotEmpty) {
      return false;
    }

    final cycleId = cycleToEnd['cycle_id'];
    final cycleName = cycleToEnd['name']?.toString();

    cycles.removeAt(idx);

    if (currentCycle['name'] == cycleName) {
      currentCycle.clear();
      if (cycles.isNotEmpty) {
        currentCycle.assignAll(cycles.first);
      }
    }

    cycles.refresh();

    unawaited(
      Future.microtask(() {
        cycles.refresh();
      }),
    );

    unawaited(NotificationService.instance.cancelCycleNotifications());

    if (cycleName != null && cycleName.isNotEmpty) {
      deleteCycleRelatedData(cycleName);

      final deletedCycles =
          myServices.getStorage.read<List<dynamic>>(
            StorageKeys.deletedCycles,
          ) ??
          <dynamic>[];
      if (!deletedCycles.contains(cycleName)) {
        deletedCycles.add(cycleName);
        unawaited(
          myServices.getStorage.write(
            StorageKeys.deletedCycles,
            deletedCycles,
          ),
        );
      }
    }

    await myServices.getStorage.write(StorageKeys.cycles, cycles.toList());

    cycleEndStatus.value = StatusRequest.loading;

    if (cycleId != null) {
      unawaited(_endCycleFromServerInBackground(cycleId, endDate: endDate));
    } else {
      cycleEndStatus.value = StatusRequest.success;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (cycleEndStatus.value == StatusRequest.success) {
          cycleEndStatus.value = StatusRequest.none;
        }
      });
    }

    return true;
  }

  Future<void> _endCycleFromServerInBackground(
    dynamic cycleId, {
    String? endDate,
  }) async {
    try {
      final isLoggedIn =
          myServices.getStorage.read<bool>(StorageKeys.isLoggedIn) ?? false;
      if (!isLoggedIn) {
        _markEndSuccess();
        return;
      }

      final user = auth.currentUser;
      if (user == null) {
        _markEndSuccess();
        return;
      }

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        _markEndSuccess();
        return;
      }

      final cycleIdInt =
          cycleId is int ? cycleId : int.tryParse(cycleId.toString()) ?? 0;
      if (cycleIdInt <= 0) {
        _markEndSuccess();
        return;
      }

      final result = await cycleData.endCycle(
        token: token,
        cycleId: cycleIdInt,
        endDate: endDate,
      );

      result.fold(
        (failure) {
          _markEndSuccess();
        },
        (response) {
          _markEndSuccess();
        },
      );
    } catch (_) {
      _markEndSuccess();
    }
  }

  void _markEndSuccess() {
    cycleEndStatus.value = StatusRequest.success;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (cycleEndStatus.value == StatusRequest.success) {
        cycleEndStatus.value = StatusRequest.none;
      }
    });
  }

  bool isCycleEnded(Map<String, dynamic> cycle) {
    return cycle['endDateRaw'] != null &&
        cycle['endDateRaw'].toString().isNotEmpty;
  }
}
