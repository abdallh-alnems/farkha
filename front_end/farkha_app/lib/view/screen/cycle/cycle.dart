import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../data/data_source/static/chicken_data.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_expenses_controller.dart';
import '../../../logic/controller/cycle_feedback_controller.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';
import '../../../logic/controller/tools_controller/darkness_schedule_controller.dart';
import '../../../logic/controller/weather_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/appbar/appbar_cycle.dart';
import '../../widget/cycle/cycle_fab.dart';
import '../../widget/cycle/cycle_tab_bar.dart';
import '../../widget/cycle/cycle_tabs.dart';
import '../../widget/cycle/overview_tab.dart';
import '../../widget/cycle/performance_tab.dart';
import '../../widget/cycle/financial_tab.dart';
import '../../widget/cycle/farm_tab.dart';

class CycleScreen extends StatefulWidget {
  const CycleScreen({super.key});

  @override
  State<CycleScreen> createState() => _CycleState();
}

class _CycleState extends State<CycleScreen>
    with TickerProviderStateMixin {
  late final CycleController cycleCtrl;
  late final BroilerController broilerCtrl;

  late final PageController _pageController;
  late final TabController _tabController;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    cycleCtrl = Get.isRegistered<CycleController>()
        ? Get.find<CycleController>()
        : Get.put(CycleController());
    broilerCtrl = Get.isRegistered<BroilerController>()
        ? Get.find<BroilerController>()
        : Get.put(BroilerController());

    if (!Get.isRegistered<CycleExpensesController>()) {
      Get.put(CycleExpensesController());
    }
    if (!Get.isRegistered<WeatherController>()) {
      Get.put(WeatherController(), permanent: true);
    }
    if (!Get.isRegistered<DarknessScheduleController>()) {
      Get.put(DarknessScheduleController());
    }

    _tabController = TabController(length: 4, vsync: this);

    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      final index = args['index'] as int?;
      if (index != null) {
        _currentPage = index;
      } else {
        final cycleIdRaw = args['cycle_id'];
        if (cycleIdRaw != null) {
          final cycleId = cycleIdRaw is int
              ? cycleIdRaw
              : int.tryParse(cycleIdRaw.toString());
          if (cycleId != null) {
            final idx = cycleCtrl.cycles.indexWhere((c) {
              final cId = c['cycle_id'];
              final cIdInt =
                  cId is int ? cId : int.tryParse(cId?.toString() ?? '');
              return cIdInt == cycleId;
            });
            if (idx != -1) _currentPage = idx;
          }
        }
      }
    }

    _pageController = PageController(initialPage: _currentPage);

    ever(cycleCtrl.cycleDataVersion, (_) {
      if (mounted) _refreshFromCurrentCycle();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeCycleData();
      }
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _triggerCycleFeedback();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    broilerCtrl.reset();
    cycleCtrl.closeCycle();
    cycleCtrl.cycleDetailsStatus.value = StatusRequest.none;
    super.dispose();
  }

  void _triggerCycleFeedback() {
    if (!mounted) return;
    if (!Get.isRegistered<CycleFeedbackController>()) return;
    try {
      final ctrl = Get.find<CycleFeedbackController>();
      ctrl.recordCycleOpen();
      ctrl.maybeShowDialog();
    } catch (_) {}
  }

  void _initializeCycleData() {
    if (!mounted || cycleCtrl.cycles.isEmpty) return;

    if (_currentPage < 0 || _currentPage >= cycleCtrl.cycles.length) {
      _currentPage = 0;
    }

    try {
      final first = cycleCtrl.cycles[_currentPage];

      if (first['name'] != null && first['name'].toString().isNotEmpty) {
        cycleCtrl.currentCycle.assignAll(first);

        final startDateRaw = first['startDateRaw']?.toString() ?? '';
        final chickCount = first['chickCount']?.toString() ?? '0';

        if (startDateRaw.isNotEmpty && chickCount.isNotEmpty) {
          _updateBroilerForCycle(startDateRaw, chickCount);
        }

        final cycleId = first['cycle_id'];
        if (cycleId != null) {
          final cycleIdInt =
              cycleId is int ? cycleId : int.tryParse(cycleId.toString());
          if (cycleIdInt != null && cycleIdInt > 0) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (!mounted) return;
              final currentCycleId = cycleCtrl.currentCycle['cycle_id'];
              final currentCycleIdInt = currentCycleId is int
                  ? currentCycleId
                  : int.tryParse(currentCycleId.toString());
              if (currentCycleIdInt == cycleIdInt && mounted) {
                cycleCtrl.fetchCycleDetails(cycleIdInt);
              }
            });
          }
        }
      }
    } catch (_) {}
  }

  void _refreshFromCurrentCycle() {
    if (!mounted) return;
    try {
      final current = cycleCtrl.currentCycle;
      final startDateRaw = current['startDateRaw']?.toString() ?? '';
      final chickCount = current['chickCount']?.toString() ??
          current['chick_count']?.toString() ??
          '0';
      if (startDateRaw.isNotEmpty && chickCount.isNotEmpty) {
        _updateBroilerForCycle(startDateRaw, chickCount);
      }
    } catch (_) {}
  }

  void _updateBroilerForCycle(String startRaw, String chickCount) {
    Future.microtask(() {
      if (!mounted) return;
      try {
        final startDate = DateTime.tryParse(startRaw);
        if (startDate == null) return;

        int ageDays = DateTime.now().difference(startDate).inDays + 1;
        final maxDays = temperatureList.length;
        ageDays = ageDays.clamp(1, maxDays);

        if (!mounted) return;

        broilerCtrl.selectedChickenAge.value = ageDays;
        broilerCtrl.chickensCountController.text = chickCount;
        broilerCtrl.ageOfChickens();
        broilerCtrl.getTemperature();
        broilerCtrl.calculateArea();
        broilerCtrl.getLighting();
        broilerCtrl.getWeight();
        broilerCtrl.calculateFeedConsumption();

        if (!mounted) return;
        broilerCtrl.onPressed();

        if (!mounted) return;
        if (Get.isRegistered<DarknessScheduleController>()) {
          final ctrl = Get.find<DarknessScheduleController>();
          ctrl.updateSchedule(startDateRaw: startRaw, ageInDays: ageDays);
          ctrl.checkDarknessFeatureSuggestion(ageDays);
        }
      } catch (_) {}
    });
  }

  void _onPageChanged(int index) {
    if (!mounted) return;
    if (index < 0 || index >= cycleCtrl.cycles.length) return;

    cycleCtrl.cycleDetailsStatus.value = StatusRequest.none;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        setState(() {
          _currentPage = index;
        });

        if (index >= cycleCtrl.cycles.length || index < 0) return;

        final cycle = cycleCtrl.cycles[index];

        if (cycle['name'] != null && cycle['name'].toString().isNotEmpty) {
          cycleCtrl.currentCycle.assignAll(cycle);

          final startDateRaw = cycle['startDateRaw']?.toString() ?? '';
          final chickCount = cycle['chickCount']?.toString() ?? '0';

          if (startDateRaw.isNotEmpty && chickCount.isNotEmpty) {
            _updateBroilerForCycle(startDateRaw, chickCount);
          }

          final cycleId = cycle['cycle_id'];
          if (cycleId != null) {
            final cycleIdInt =
                cycleId is int ? cycleId : int.tryParse(cycleId.toString());
            if (cycleIdInt != null && cycleIdInt > 0) {
              Future.delayed(const Duration(milliseconds: 300), () {
                if (!mounted) return;
                final currentCycleId = cycleCtrl.currentCycle['cycle_id'];
                final currentCycleIdInt = currentCycleId is int
                    ? currentCycleId
                    : int.tryParse(currentCycleId.toString());
                if (currentCycleIdInt == cycleIdInt && mounted) {
                  cycleCtrl.fetchCycleDetails(cycleIdInt);
                }
              });
            }
          }
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackGroundColor
          : AppColors.lightPageBackgroundColor,
      appBar: AppBarCycle(
        onCycleSwitch: _onPageChanged,
      ),
      floatingActionButton: CycleFab(isDark: isDark),
      bottomNavigationBar: const AdBannerWidget(),
      body: Obx(() {
        final cycles = cycleCtrl.cycles;
        if (cycles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 12.h),
                CycleTabBar(
                  controller: _tabController,
                  isDark: isDark,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      OverviewTab(),
                      PerformanceTab(),
                      FinancialTab(),
                      FarmTab(),
                    ],
                  ),
                ),
              ],
            ),
            CycleDetailsOverlay(isDark: isDark),
            CycleEndOverlay(isDark: isDark),
          ],
        );
      }),
    );
  }
}
