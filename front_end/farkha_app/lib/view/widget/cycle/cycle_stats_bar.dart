import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_expenses_controller.dart';

class CycleStatsBar extends StatelessWidget {
  final String startDateRaw;

  CycleStatsBar({super.key, required this.startDateRaw});

  final controller = Get.find<CycleController>();

  static const List<String> _stageLabels = ['تحضين', 'تسمين', 'بيع'];

  int _getStageIndex(int days) {
    if (days <= 14) return 0;
    if (days <= 30) return 1;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cycle = controller.currentCycle;
      final startRaw = cycle['startDateRaw'] ?? '';

      final startDateParsed = DateTime.tryParse(startDateRaw);
      final ageDays =
          startDateParsed == null
              ? 0
              : DateTime.now().difference(startDateParsed).inDays;
      final currentStage = _getStageIndex(ageDays < 0 ? 0 : ageDays);
      final ageText = controller.ageOf(startRaw);

      bool isStageCompleted(int idx) => idx < currentStage;
      bool isCurrentStage(int idx) => idx == currentStage;

      Color circleColor(int idx, bool isDark) {
        if (isCurrentStage(idx)) {
          return isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
        } else if (isStageCompleted(idx)) {
          return isDark
              ? AppColors.darkPrimaryColor.withOpacity(0.6)
              : AppColors.primaryColor.withOpacity(0.7);
        } else {
          return isDark
              ? AppColors.darkSurfaceColor.withOpacity(0.5)
              : Colors.grey[300]!;
        }
      }

      Color textColor(int idx, bool isDark) {
        if (isCurrentStage(idx)) {
          return isDark ? AppColors.darkBackGroundColor : Colors.white;
        } else if (isStageCompleted(idx)) {
          return isDark ? AppColors.darkBackGroundColor : Colors.white;
        } else {
          return isDark ? Colors.grey[500]! : Colors.grey[700]!;
        }
      }

      Color lineColor(int idx, bool isDark) {
        if (idx < currentStage) {
          return isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
        } else {
          return isDark
              ? AppColors.darkOutlineColor.withOpacity(0.5)
              : Colors.grey[400]!;
        }
      }

      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color:
              isDark
                  ? AppColors.darkSurfaceElevatedColor
                  : AppColors.lightCardBackgroundColor,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stage Indicator
            Row(
              children: List.generate(_stageLabels.length * 2 - 1, (idx) {
                if (idx.isEven) {
                  final s = idx ~/ 2;
                  return Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Container(
                        width: 80.w,
                        padding: EdgeInsets.symmetric(
                          vertical: 4.h,
                          horizontal: 4.w,
                        ),
                        decoration: BoxDecoration(
                          color: circleColor(s, isDark),
                          borderRadius: BorderRadius.circular(20.r),
                          border:
                              isCurrentStage(s)
                                  ? Border.all(
                                    color:
                                        isDark
                                            ? AppColors.darkPrimaryColor
                                            : AppColors.primaryColor,
                                    width: 2.5,
                                  )
                                  : isStageCompleted(s)
                                  ? Border.all(
                                    color:
                                        isDark
                                            ? AppColors.darkPrimaryColor
                                                .withOpacity(0.6)
                                            : AppColors.primaryColor
                                                .withOpacity(0.5),
                                    width: 1.5,
                                  )
                                  : Border.all(
                                    color:
                                        isDark
                                            ? AppColors.darkOutlineColor
                                                .withOpacity(0.4)
                                            : Colors.grey[400]!,
                                    width: 1,
                                  ),
                          boxShadow:
                              isCurrentStage(s)
                                  ? [
                                    BoxShadow(
                                      color: (isDark
                                              ? AppColors.darkPrimaryColor
                                              : AppColors.primaryColor)
                                          .withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Center(
                          child: Text(
                            _stageLabels[s],
                            style: TextStyle(
                              color: textColor(s, isDark),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                final li = (idx - 1) ~/ 2;
                return Expanded(
                  flex: 1,
                  child: Container(height: 2.h, color: lineColor(li, isDark)),
                );
              }),
            ),
            SizedBox(height: 8.h),
            // Stats Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('العمر', ageText),
                _buildChickCountColumn(cycle),
                _buildMortalityColumn(cycle),
                _buildTotalExpensesColumn(),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatColumn(String label, String value) {
    final theme = Theme.of(Get.context!);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChickCountColumn(Map<String, dynamic> cycle) {
    final mortality = int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
    final chickCount =
        int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0;
    final liveChickCount = chickCount - mortality;
    return _buildStatColumn('عدد الفراخ', liveChickCount.toString());
  }

  Widget _buildMortalityColumn(Map<String, dynamic> cycle) {
    final theme = Theme.of(Get.context!);
    final isDark = theme.brightness == Brightness.dark;
    final mortality = int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
    final chickCount =
        int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0;
    final mortalityPercentage =
        chickCount > 0 ? (mortality / chickCount * 100) : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'النافق',
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: 2.h),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$mortality',
                style: TextStyle(
                  color:
                      isDark
                          ? AppColors.darkPrimaryColor
                          : AppColors.primaryColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (mortalityPercentage > 0)
                TextSpan(
                  text: ' (${mortalityPercentage.round()}%)',
                  style: TextStyle(
                    color:
                        mortalityPercentage > 5
                            ? Colors.red[400]
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalExpensesColumn() {
    try {
      final expensesCtrl = Get.put(CycleExpensesController());
      return Obx(() {
        final total = expensesCtrl.totalExpenses.value.round();
        return _buildStatColumn('المصروفات', '$total');
      });
    } catch (e) {
      return _buildStatColumn('المصروفات', '0');
    }
  }
}
