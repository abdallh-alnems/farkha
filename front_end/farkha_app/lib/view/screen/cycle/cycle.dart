// في ملف cycle.dart - استبدال المحتوى الموجود

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/data_source/static/growth_parameters.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/follow_up_tools_controller/broiler_controller.dart';
import '../../widget/app_bar/app_bar_cycle.dart';
import '../../widget/cycle/cycle_stats_bar.dart';
import '../../widget/cycle/environment_status.dart';
import '../../widget/cycle/page_turning_tips.dart';
import '../../widget/cycle/stage_indicator.dart';

class Cycle extends StatefulWidget {
  const Cycle({super.key});

  @override
  State<Cycle> createState() => _CycleState();
}

class _CycleState extends State<Cycle> with TickerProviderStateMixin {
  final cycleCtrl = Get.find<CycleController>();
  final broilerCtrl = Get.put(BroilerController(), permanent: true);

  late final PageController _pageController;
  late final AnimationController _arrowController;
  late final Animation<Offset> _arrowAnimation;

  int _currentPage = 0;
  bool _showTutorialOverlay = false;

  @override
  void initState() {
    super.initState();

    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _arrowAnimation = Tween<Offset>(
      begin: const Offset(-0.2, 0),
      end: const Offset(0.2, 0),
    ).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );

    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      _currentPage = args['index'] as int? ?? 0;
      _showTutorialOverlay = args['showTutorial'] as bool? ?? false;
    }

    _pageController = PageController(initialPage: _currentPage);

    // تأخير تحديث البيانات حتى انتهاء بناء الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCycleData();
    });
  }

  void _initializeCycleData() {
    if (cycleCtrl.cycles.isNotEmpty) {
      final first = cycleCtrl.cycles[_currentPage];
      cycleCtrl.currentCycle.assignAll(first);
      _updateBroilerForCycle(
        first['startDateRaw'] as String,
        first['chickCount'] as String,
      );
    }
  }

  @override
  void dispose() {
    _arrowController.dispose();
    _pageController.dispose();
    Future.microtask(() => broilerCtrl.reset());
    super.dispose();
  }

  void _updateBroilerForCycle(String startRaw, String chickCount) {
    // استخدام Future.microtask لتأخير التحديث
    Future.microtask(() {
      // حساب عمر الأيام
      final startDate = DateTime.tryParse(startRaw);
      if (startDate == null) return;

      int ageDays = DateTime.now().difference(startDate).inDays + 1;
      final maxDays = temperatureList.length;
      ageDays = ageDays.clamp(1, maxDays);

      // املأ العمر وعدد الفراخ في الكنترولر
      broilerCtrl.selectedChickenAge.value = ageDays;
      broilerCtrl.chickensCountController.text = chickCount;

      // احسب المتغيرات الداخلة
      broilerCtrl.ageOfChickens();
      broilerCtrl.getTemperature();
      broilerCtrl.calculateArea();
      broilerCtrl.getLighting();
      broilerCtrl.getWeight();
      broilerCtrl.calculateFeedConsumption();

      // ثم جلب بيانات الطقس
      broilerCtrl.onPressed();
    });
  }

  void _onPageChanged(int index) {
    // إخفاء السهم عند التنقل
    if (_showTutorialOverlay) {
      setState(() {
        _showTutorialOverlay = false;
      });
    }

    // تأخير تحديث الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _currentPage = index;
      });

      final cycle = cycleCtrl.cycles[index];
      cycleCtrl.currentCycle.assignAll(cycle);
      _updateBroilerForCycle(
        cycle['startDateRaw'] as String,
        cycle['chickCount'] as String,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCycle(),
      body: Obx(() {
        final cycles = cycleCtrl.cycles;
        if (cycles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return PageView.builder(
          controller: _pageController,
          itemCount: cycles.length,
          onPageChanged: _onPageChanged,
          itemBuilder: (_, i) {
            final cycle = cycles[i];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 24.h),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        StageIndicator(
                          startDateRaw: cycle['startDateRaw'] as String,
                        ),
                        SizedBox(height: 20.h),
                        CycleStatsBar(),
                        SizedBox(height: 20.h),
                        const EnvironmentStatus(),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                  if (_showTutorialOverlay && _currentPage == 1)
                    Positioned.fill(
                      child: Center(
                        child: PageTurningTips(arrowAnimation: _arrowAnimation),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
