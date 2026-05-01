import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/constant/storage_keys.dart';
import '../../../core/services/initialization.dart';
import '../../../logic/controller/auth/login_controller.dart';
import '../../../logic/controller/cycle_controller.dart';
import 'cycle_card_actions.dart';
import 'cycle_card_stats.dart';

class CardCycle extends StatefulWidget {
  const CardCycle({super.key});

  @override
  State<CardCycle> createState() => _CardCycleState();
}

class _CardCycleState extends State<CardCycle> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getCurrentStage(int days) {
    if (days <= 14) return 'تحضين';
    if (days <= 30) return 'تسمين';
    return 'بيع';
  }

  int _getStageIndex(int days) {
    if (days <= 14) return 0;
    if (days <= 30) return 1;
    return 2;
  }

  Color _getStageColor(int stageIndex, ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    switch (stageIndex) {
      case 0:
        return colorScheme.primary;
      case 1:
        return colorScheme.primary;
      case 2:
        return isDark
            ? (Colors.orange[300] ?? Colors.orange)
            : (Colors.orange[600] ?? Colors.orange);
      default:
        return isDark
            ? colorScheme.surface.withValues(alpha: 0.5)
            : Colors.grey[300]!;
    }
  }

  double _getCycleTotalExpenses(String cycleName) {
    try {
      final storage = GetStorage();
      final storageKey = '${StorageKeys.expensesPrefix}$cycleName';
      final saved = storage.read<List<dynamic>>(storageKey);
      if (saved != null && saved.isNotEmpty) {
        double total = 0.0;
        for (var expense in saved) {
          final payments = expense['payments'] as List<dynamic>?;
          if (payments != null) {
            for (var payment in payments) {
              total += (payment['amount'] as num?)?.toDouble() ?? 0.0;
            }
          }
        }
        return total;
      }
    } catch (e) {
      // ignore errors
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final cycleCtrl =
        Get.isRegistered<CycleController>()
            ? Get.find<CycleController>()
            : Get.put(CycleController());
    final loginCtrl =
        Get.isRegistered<LoginController>()
            ? Get.find<LoginController>()
            : Get.put(LoginController(), permanent: true);

    return Obx(() {
      if (Get.isRegistered<MyServices>()) {
        final myServices = Get.find<MyServices>();
        final storedValue =
            myServices.getStorage.read<bool>(StorageKeys.isLoggedIn) ?? false;
        if (loginCtrl.isLoggedIn.value != storedValue) {
          loginCtrl.isLoggedIn.value = storedValue;
        }
      }

      final allCycles = cycleCtrl.cycles;
      final isLoggedIn = loginCtrl.isLoggedIn.value;

      final cycles =
          allCycles.where((cycle) {
            final status = cycle['status']?.toString();
            return status != 'finished';
          }).toList();

      if (cycles.isNotEmpty && !isLoggedIn) {
        return Container(
          width: double.infinity,
          height: 47.h,
          margin: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: colorScheme.surface,
            border: Border.all(),
          ),
          child: Center(
            child: GestureDetector(
              onTap: () {
                Get.toNamed<void>(AppRoute.login);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 24.sp,
                    color: colorScheme.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'يجب تسجيل الدخول لمتابعة الدورات',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      if (cycles.isEmpty) {
        return Container(
          width: double.infinity,
          height: 47.h,
          margin: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: colorScheme.surface,
            border: Border.all(),
          ),
          child: Stack(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed<void>(AppRoute.addCycle);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 24.sp,
                        color: colorScheme.primary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'اضف دورة جديدة',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8.r),
                      bottomRight: Radius.circular(8.r),
                    ),
                    border: Border(
                      right: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.history,
                      color: colorScheme.onPrimary,
                      size: 20.sp,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    onPressed: () {
                      Get.toNamed<void>(AppRoute.history);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 101.h,
            child: PageView.builder(
              controller: _pageController,
              itemCount: cycles.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final cycle = cycles[index];
                return _buildCycleCard(context, cycle, index, isDark);
              },
            ),
          ),
          if (cycles.length > 1)
            Transform.translate(
              offset: Offset(0, -5.h),
              child: _buildPageIndicator(cycles.length, isDark),
            ),
          SizedBox(height: 8.h),
        ],
      );
    });
  }

  Widget _buildCycleCard(
    BuildContext context,
    Map<String, dynamic> cycle,
    int index,
    bool isDark,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final cycleCtrl =
        Get.isRegistered<CycleController>()
            ? Get.find<CycleController>()
            : Get.put(CycleController());

    return Obx(() {
      final updatedCycle = cycleCtrl.cycles.firstWhere(
        (c) => c['cycle_id'] == cycle['cycle_id'],
        orElse: () => cycle,
      );

      final startDateRaw =
          updatedCycle['startDateRaw'] as String? ??
          updatedCycle['startDate'] as String? ??
          '';
      final ageText = cycleCtrl.ageOf(startDateRaw);
      final age =
          ageText.isEmpty || ageText == 'لم تبدأ' ? 'لم تبدأ' : '$ageText يوم';

      final start =
          startDateRaw.isNotEmpty ? DateTime.tryParse(startDateRaw) : null;
      final isCycleNotStarted = start != null && DateTime.now().isBefore(start);

      int ageDays = 0;
      String currentStage = 'لم تبدأ';
      int stageIndex = -1;
      if (startDateRaw.isNotEmpty && start != null && !isCycleNotStarted) {
        ageDays = DateTime.now().difference(start).inDays;
        stageIndex = _getStageIndex(ageDays);
        currentStage = _getCurrentStage(ageDays);
      }

      final mortality =
          int.tryParse(updatedCycle['mortality']?.toString() ?? '0') ?? 0;
      final chickCount =
          int.tryParse(
            updatedCycle['chickCount']?.toString() ??
                updatedCycle['chick_count']?.toString() ??
                '0',
          ) ??
          0;

      double totalExpenses = 0.0;
      if (updatedCycle['total_expenses'] != null) {
        totalExpenses =
            double.tryParse(updatedCycle['total_expenses'].toString()) ?? 0.0;
      } else {
        final cycleName = updatedCycle['name'] as String? ?? '';
        totalExpenses = _getCycleTotalExpenses(cycleName);
      }

      final liveChickCount = chickCount - mortality;
      final costPerChick =
          liveChickCount > 0 ? (totalExpenses / liveChickCount) : 0.0;

      return GestureDetector(
        onTap: () {
          Get.toNamed<void>(AppRoute.cycle, arguments: {'index': index});
        },
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(17),
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 4.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (stageIndex >= 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getStageColor(stageIndex, colorScheme),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: colorScheme.primary,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            currentStage,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        updatedCycle['name'] as String? ?? 'دورة بدون اسم',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CycleCardPopupMenu(
                        cycle: updatedCycle,
                        cycleIndex: index,
                        isDark: isDark,
                        ageText: ageText,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              if (isCycleNotStarted)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Center(
                    child: Text(
                      'ستبدأ الدورة في : ${DateFormat('MM-dd').format(start)} (${DateFormat('EEEE', 'ar').format(start)})',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              else
                CycleCardStatsRow(
                  age: age,
                  liveCount: chickCount - mortality,
                  totalExpenses: totalExpenses,
                  costPerChick: costPerChick,
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPageIndicator(int itemCount, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: _currentPage == index ? 8.w : 6.w,
          height: 6.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                _currentPage == index
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
