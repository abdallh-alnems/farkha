import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/constant/storage_keys.dart';
import '../../../core/constant/theme/theme.dart';
import '../../../logic/controller/cycle_controller.dart';
import 'cycle_card_actions.dart';
import 'cycle_card_info.dart';
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
    _pageController = PageController(viewportFraction: 0.92);
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
    } catch (_) {}
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final cycleCtrl = Get.isRegistered<CycleController>()
        ? Get.find<CycleController>()
        : Get.put(CycleController());

    return Obx(() {
      final allCycles = cycleCtrl.cycles;

      final cycles = allCycles.where((cycle) {
        final status = cycle['status']?.toString();
        return status != 'finished';
      }).toList();

      if (cycles.isEmpty) {
        return CycleCardEmptyState(colorScheme: colorScheme);
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 115.h,
            child: PageView.builder(
              controller: _pageController,
              itemCount: cycles.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return _buildCycleCard(context, cycles[index], index, isDark);
              },
            ),
          ),
          if (cycles.length > 1)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: _buildPageIndicator(cycles.length, colorScheme),
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
    final cycleCtrl = Get.isRegistered<CycleController>()
        ? Get.find<CycleController>()
        : Get.put(CycleController());

    return Obx(() {
      final updatedCycle = cycleCtrl.cycles.firstWhere(
        (c) => c['cycle_id'] == cycle['cycle_id'],
        orElse: () => cycle,
      );

      final startDateRaw = updatedCycle['startDateRaw'] as String? ??
          updatedCycle['startDate'] as String? ??
          '';
      final ageText = cycleCtrl.ageOf(startDateRaw);
      final age = ageText.isEmpty || ageText == 'لم تبدأ' ? 'لم تبدأ' : '$ageText يوم';

      final start =
          startDateRaw.isNotEmpty ? DateTime.tryParse(startDateRaw) : null;
      final isCycleNotStarted =
          start != null && DateTime.now().isBefore(start);

      int stageIndex = -1;
      String currentStage = 'لم تبدأ';
      if (startDateRaw.isNotEmpty && start != null && !isCycleNotStarted) {
        final ageDays = DateTime.now().difference(start).inDays;
        stageIndex = _getStageIndex(ageDays);
        currentStage = _getCurrentStage(ageDays);
      }

      final mortality =
          int.tryParse(updatedCycle['mortality']?.toString() ?? '0') ?? 0;
      final chickCount = int.tryParse(
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

      final bool isOwner = updatedCycle['is_owner'] == true;
      final String role = updatedCycle['role']?.toString() ?? 'owner';
      final bool isAdmin = role == 'admin';

      return GestureDetector(
        onTap: () {
          Get.toNamed<void>(AppRoute.cycle, arguments: {'index': index});
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                blurRadius: 8.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(8.w, 8.h, 8.w, 0),
                child: Row(
                  children: [
                    if (stageIndex >= 0)
                      CycleCardStageBadge(
                        stage: currentStage,
                        stageIndex: stageIndex,
                        colorScheme: colorScheme,
                      ),
                    if (stageIndex >= 0) SizedBox(width: 8.w)
                    else SizedBox(width: 4.w),
                    Expanded(
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                updatedCycle['name'] as String? ?? 'دورة بدون اسم',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isOwner) ...[
                              SizedBox(width: 6.w),
                              CycleCardRoleBadge(
                                isAdmin: isAdmin,
                                colorScheme: colorScheme,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    CycleCardPopupMenu(
                      cycle: updatedCycle,
                      cycleIndex: index,
                      isDark: isDark,
                      ageText: ageText,
                    ),
                  ],
                ),
              ),
              if (isCycleNotStarted)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_outlined, size: 14.sp, color: colorScheme.primary),
                      SizedBox(width: 4.w),
                      Text(
                        'تبدأ: ${DateFormat('MM-dd').format(start)} (${DateFormat('EEEE', 'ar').format(start)})',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 4.h, 10.w, 8.h),
                  child: CycleCardStatsRow(
                    age: age,
                    liveCount: chickCount - mortality,
                    totalExpenses: totalExpenses,
                    costPerChick: costPerChick,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPageIndicator(int itemCount, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isActive = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: 2.5.w),
          width: isActive ? 20.w : 8.w,
          height: 4.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            color: isActive
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}
