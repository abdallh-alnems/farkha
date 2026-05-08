import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constant/storage_keys.dart';
import '../../core/services/initialization.dart';
import '../../data/data_source/remote/cycle_data/cycle_data.dart';
import '../../view/widget/cycle/darkness_settings_sheet.dart';
import 'cycle_controller_base.dart';
import 'cycle_crud_mixin.dart';
import 'cycle_data_entry_mixin.dart';
import 'cycle_end_mixin.dart';
import 'cycle_fetch_mixin.dart';
import 'cycle_history_mixin.dart';
import 'cycle_member_mixin.dart';
import 'tools_controller/darkness_schedule_controller.dart';

class CycleController extends CycleControllerBase
    with
        CycleFetchMixin,
        CycleCrudMixin,
        CycleEndMixin,
        CycleHistoryMixin,
        CycleDataEntryMixin,
        CycleMemberMixin {
  CycleController({
    FirebaseAuth? auth,
    MyServices? myServices,
  })  : _authOverride = auth,
        _myServicesOverride = myServices;

  final FirebaseAuth? _authOverride;
  final MyServices? _myServicesOverride;

  @override
  void onInit() {
    super.onInit();
    auth = _authOverride ?? FirebaseAuth.instance;
    myServices = _myServicesOverride ?? Get.find<MyServices>();
    cycleData = CycleData();
    _loadCycles();
    fetchCyclesFromServer();
    fetchInvitations();

    historyScrollController.addListener(() {
      if (historyScrollController.position.pixels ==
          historyScrollController.position.maxScrollExtent) {
        fetchNextHistoryPage();
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    _checkArguments();
  }

  void _checkArguments() {
    final args = Get.arguments;
    if (args != null && args is Map) {
      if (args['action'] == 'open_darkness_settings') {
        unawaited(
          Get.bottomSheet(
            DarknessSettingsSheet(
              controller: Get.find<DarknessScheduleController>(),
            ),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          ),
        );
      }
    }
  }

  void _loadCycles() {
    final saved = myServices.getStorage.read<List<dynamic>>(StorageKeys.cycles);
    if (saved != null && saved.isNotEmpty) {
      final loadedCycles =
          saved.map((item) {
            final cycle = Map<String, dynamic>.from(
              item as Map<dynamic, dynamic>,
            );
            cycle.remove('mortalityEntries');
            cycle.remove('averageWeightEntries');
            cycle.remove('medicationEntries');
            cycle.remove('feedConsumptionEntries');
            cycle.remove('expenses');
            cycle.remove('sales');
            cycle.remove('customDataEntries');
            cycle.remove('members');
            cycle.remove('notes');
            cycle['role'] ??= 'owner';
            return cycle;
          }).toList();
      cycles.value =
          loadedCycles.where((cycle) {
            final status = cycle['status']?.toString();
            return status != 'finished';
          }).toList();

      historyCycles.value =
          loadedCycles.where((cycle) {
            final status = cycle['status']?.toString();
            return status == 'finished';
          }).toList();
      if (cycles.isNotEmpty) {
        currentCycle.assignAll(cycles.first);
      }
    }
  }
}
