// في ملف cycle.dart - استبدال المحتوى الموجود

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../data/data_source/static/chicken_data.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/appbar_cycle.dart';
import '../../widget/cycle/area_darkness_card.dart';
import '../../widget/cycle/cycle_stats_bar.dart';
import '../../widget/cycle/environment_status.dart';
import '../../widget/cycle/feed_consumption_card.dart';
import '../../widget/cycle/financial_summary_card.dart';
import '../../widget/cycle/page_turning_tips.dart';
import '../../widget/cycle/performance_metrics_card.dart';

class Cycle extends StatefulWidget {
  const Cycle({super.key});

  @override
  State<Cycle> createState() => _CycleState();
}

class _CycleState extends State<Cycle> with TickerProviderStateMixin {
  final cycleCtrl = Get.find<CycleController>();
  late final BroilerController broilerCtrl;

  late final PageController _pageController;
  late final AnimationController _arrowController;
  late final Animation<Offset> _arrowAnimation;
  late final AnimationController _fabController;
  late final Animation<double> _fabAnimation;

  int _currentPage = 0;
  bool _showTutorialOverlay = false;
  bool _isFabExpanded = false;

  @override
  void initState() {
    super.initState();

    // تهيئة BroilerController بشكل آمن
    broilerCtrl =
        Get.isRegistered<BroilerController>()
            ? Get.find<BroilerController>()
            : Get.put(BroilerController());

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

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );

    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      _currentPage = args['index'] as int? ?? 0;
      _showTutorialOverlay = args['showTutorial'] as bool? ?? false;
    }

    _pageController = PageController(initialPage: _currentPage);

    // تأخير تحديث البيانات حتى انتهاء بناء الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeCycleData();
      }
    });
  }

  void _initializeCycleData() {
    if (!mounted || cycleCtrl.cycles.isEmpty) return;

    // التحقق من صحة index
    if (_currentPage < 0 || _currentPage >= cycleCtrl.cycles.length) {
      _currentPage = 0;
    }

    try {
      final first = cycleCtrl.cycles[_currentPage];

      // التحقق من أن الدورة تحتوي على بيانات صحيحة
      if (first['name'] != null && first['name'].toString().isNotEmpty) {
        cycleCtrl.currentCycle.assignAll(first);

        // تحسين type safety
        final startDateRaw = first['startDateRaw']?.toString() ?? '';
        final chickCount = first['chickCount']?.toString() ?? '0';

        if (startDateRaw.isNotEmpty && chickCount.isNotEmpty) {
          _updateBroilerForCycle(startDateRaw, chickCount);
        }

        // جلب بيانات الدورة من API إذا كان cycle_id موجوداً
        final cycleId = first['cycle_id'];
        if (cycleId != null) {
          final cycleIdInt =
              cycleId is int ? cycleId : int.tryParse(cycleId.toString());
          if (cycleIdInt != null && cycleIdInt > 0) {
            // تأخير استدعاء fetchCycleDetails قليلاً لضمان أن currentCycle تم تعيينه
            Future.delayed(const Duration(milliseconds: 300), () {
              if (!mounted) return;

              // التحقق من أن currentCycle لا يزال يحتوي على نفس cycle_id
              final currentCycleId = cycleCtrl.currentCycle['cycle_id'];
              final currentCycleIdInt =
                  currentCycleId is int
                      ? currentCycleId
                      : int.tryParse(currentCycleId.toString());
              if (currentCycleIdInt == cycleIdInt && mounted) {
                cycleCtrl.fetchCycleDetails(cycleIdInt);
              }
            });
          }
        }
      }
    } catch (e) {
      // معالجة الأخطاء
      if (mounted) {
        // يمكن إضافة logging هنا
      }
    }
  }

  @override
  void dispose() {
    _arrowController.dispose();
    _fabController.dispose();
    _pageController.dispose();
    // تنفيذ مباشر بدلاً من Future.microtask لتجنب memory leaks
    broilerCtrl.reset();
    // إزالة flag عند إغلاق الدورة وإعادة تعيين حالة التحميل
    cycleCtrl.closeCycle();
    cycleCtrl.cycleDetailsStatus.value = StatusRequest.none;
    super.dispose();
  }

  void _updateBroilerForCycle(String startRaw, String chickCount) {
    // استخدام Future.microtask لتأخير التحديث
    Future.microtask(() {
      if (!mounted) return;

      try {
        // حساب عمر الأيام
        final startDate = DateTime.tryParse(startRaw);
        if (startDate == null) return;

        int ageDays = DateTime.now().difference(startDate).inDays + 1;
        final maxDays = temperatureList.length;
        ageDays = ageDays.clamp(1, maxDays);

        if (!mounted) return;

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

        if (!mounted) return;

        // ثم جلب بيانات الطقس
        broilerCtrl.onPressed();
      } catch (e) {
        // معالجة الأخطاء
        if (mounted) {
          // يمكن إضافة logging هنا
        }
      }
    });
  }

  void _onPageChanged(int index) {
    if (!mounted) return;

    // التحقق من صحة index
    if (index < 0 || index >= cycleCtrl.cycles.length) {
      return;
    }

    // إخفاء السهم عند التنقل
    if (_showTutorialOverlay) {
      if (mounted) {
        setState(() {
          _showTutorialOverlay = false;
        });
      }
    }

    // إعادة تعيين حالة التحميل عند تغيير الصفحة
    cycleCtrl.cycleDetailsStatus.value = StatusRequest.none;

    // تأخير تحديث الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        setState(() {
          _currentPage = index;
        });

        // التحقق مرة أخرى من صحة index بعد setState
        if (index >= cycleCtrl.cycles.length || index < 0) {
          return;
        }

        final cycle = cycleCtrl.cycles[index];

        // التحقق من أن الدورة تحتوي على بيانات صحيحة
        if (cycle['name'] != null && cycle['name'].toString().isNotEmpty) {
          cycleCtrl.currentCycle.assignAll(cycle);

          // تحسين type safety
          final startDateRaw = cycle['startDateRaw']?.toString() ?? '';
          final chickCount = cycle['chickCount']?.toString() ?? '0';

          if (startDateRaw.isNotEmpty && chickCount.isNotEmpty) {
            _updateBroilerForCycle(startDateRaw, chickCount);
          }

          // جلب بيانات الدورة من API إذا كان cycle_id موجوداً
          final cycleId = cycle['cycle_id'];
          if (cycleId != null) {
            final cycleIdInt =
                cycleId is int ? cycleId : int.tryParse(cycleId.toString());
            if (cycleIdInt != null && cycleIdInt > 0) {
              // تأخير استدعاء fetchCycleDetails قليلاً لضمان أن currentCycle تم تعيينه
              Future.delayed(const Duration(milliseconds: 300), () {
                if (!mounted) return;

                // التحقق من أن currentCycle لا يزال يحتوي على نفس cycle_id
                final currentCycleId = cycleCtrl.currentCycle['cycle_id'];
                final currentCycleIdInt =
                    currentCycleId is int
                        ? currentCycleId
                        : int.tryParse(currentCycleId.toString());
                if (currentCycleIdInt == cycleIdInt && mounted) {
                  cycleCtrl.fetchCycleDetails(cycleIdInt);
                }
              });
            }
          }
        }
      } catch (e) {
        // معالجة الأخطاء
        if (mounted) {
          // يمكن إضافة logging هنا
        }
      }
    });
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? AppColors.darkBackGroundColor
              : AppColors.lightPageBackgroundColor,
      appBar: const AppBarCycle(),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: const AdBannerWidget(),
      body: Obx(() {
        final cycles = cycleCtrl.cycles;

        if (cycles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            // PageView دائماً مرئي للسماح بالتنقل حتى أثناء التحميل
            PageView.builder(
              controller: _pageController,
              itemCount: cycles.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (_, i) {
                final cycle = cycles[i];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17.w),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            CycleStatsBar(
                              startDateRaw: cycle['startDateRaw'] as String,
                            ),
                            SizedBox(height: 12.h),
                            const EnvironmentStatus(),
                            SizedBox(height: 12.h),
                            const AdNativeWidget(),
                            SizedBox(height: 12.h),
                            const PerformanceMetricsCard(),
                            SizedBox(height: 12.h),
                            const FeedConsumptionCard(),
                            SizedBox(height: 12.h),
                            const FinancialSummaryCard(),
                            SizedBox(height: 12.h),
                            const AreaDarknessCard(),
                            SizedBox(height: 11.h),
                          ],
                        ),
                      ),
                      if (_showTutorialOverlay && _currentPage == 1)
                        Positioned.fill(
                          child: Center(
                            child: PageTurningTips(
                              arrowAnimation: _arrowAnimation,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            // Overlay للتحميل وأخطاء تفاصيل الدورة (لا يمنع التنقل)
            Obx(() {
              final detailsStatus = cycleCtrl.cycleDetailsStatus.value;

              if (detailsStatus == StatusRequest.loading ||
                  detailsStatus == StatusRequest.serverFailure ||
                  detailsStatus == StatusRequest.offlineFailure ||
                  detailsStatus == StatusRequest.failure) {
                return Positioned.fill(
                  child: IgnorePointer(
                    ignoring: detailsStatus != StatusRequest.loading,
                    child: Container(
                      color: (isDark
                              ? AppColors.darkBackGroundColor
                              : AppColors.lightPageBackgroundColor)
                          .withOpacity(0.7),
                      child: HandlingDataView(
                        statusRequest: detailsStatus,
                        widget: const SizedBox.shrink(),
                      ),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            }),
            // مؤشر التحميل لإنهاء الدورة
            Obx(() {
              final endStatus = cycleCtrl.cycleEndStatus.value;

              if (endStatus == StatusRequest.loading ||
                  endStatus == StatusRequest.serverFailure ||
                  endStatus == StatusRequest.offlineFailure ||
                  endStatus == StatusRequest.failure) {
                return Positioned.fill(
                  child: IgnorePointer(
                    ignoring: endStatus != StatusRequest.loading,
                    child: Container(
                      color: (isDark
                              ? AppColors.darkBackGroundColor
                              : AppColors.lightPageBackgroundColor)
                          .withOpacity(0.8),
                      child: HandlingDataView(
                        statusRequest: endStatus,
                        widget: const SizedBox.shrink(),
                      ),
                    ),
                  ),
                );
              }

              // التحقق من نجاح إنهاء الدورة والرجوع إلى الصفحة الرئيسية
              if (endStatus == StatusRequest.success) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (!mounted) return;
                    // إعادة تعيين حالة التحميل
                    cycleCtrl.cycleEndStatus.value = StatusRequest.none;
                    // الرجوع إلى الصفحة الرئيسية مباشرة بعد إنهاء الدورة
                    if (mounted) {
                      Get.offAllNamed("/");
                    }
                  });
                });
              }

              return const SizedBox.shrink();
            }),
          ],
        );
      }),
    );
  }

  Widget _buildFloatingActionButton() {
    final theme = Theme.of(Get.context!);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedBuilder(
          animation: _fabAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _fabAnimation.value,
              alignment: Alignment.bottomRight,
              child: Opacity(
                opacity: _fabAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildFabOption(
                      heroTag: "expenses_fab",
                      label: 'المصروفات',
                      color: AppColors.primaryColor,
                      isDark: isDark,
                      onTap: () {
                        _toggleFab();
                        Get.toNamed(AppRoute.cycleExpenses);
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildFabOption(
                      heroTag: "data_fab",
                      label: 'البيانات',
                      color: AppColors.primaryColor,
                      isDark: isDark,
                      onTap: () {
                        _toggleFab();
                        Get.toNamed(AppRoute.cycleData);
                      },
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            );
          },
        ),
        FloatingActionButton(
          heroTag: "main_fab",
          onPressed: _toggleFab,
          backgroundColor: AppColors.primaryColor,
          child: AnimatedRotation(
            turns: _isFabExpanded ? 0.125 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isFabExpanded ? Icons.close : Icons.add,
              color: isDark ? Colors.black87 : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFabOption({
    required String heroTag,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color:
              isDark
                  ? AppColors.darkSurfaceElevatedColor
                  : AppColors.lightCardBackgroundColor,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.black.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDark ? AppColors.darkPrimaryColor : color,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
