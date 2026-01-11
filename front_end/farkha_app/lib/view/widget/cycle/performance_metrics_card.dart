import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../data/data_source/static/chicken_data.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_expenses_controller.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';

class PerformanceMetricsCard extends StatelessWidget {
  const PerformanceMetricsCard({super.key});

  double _calculateFCR(
    CycleController cycleCtrl,
    BroilerController broilerCtrl,
  ) {
    // إجمالي العلف المستهلك (من المدخلات الفعلية فقط)
    final feedEntries = cycleCtrl.getFeedConsumptionEntries();
    double totalFeedConsumed = 0.0;
    for (var entry in feedEntries) {
      totalFeedConsumed += entry.amount;
    }

    // إذا لم تكن هناك مدخلات فعلية، لا نحسب FCR
    if (totalFeedConsumed == 0.0) {
      return 0.0;
    }

    // إجمالي الوزن الحي (من المدخلات الفعلية)
    final weightEntries = cycleCtrl.getAverageWeightEntries();
    final lastWeight =
        weightEntries.isNotEmpty ? weightEntries.last.weight : 0.0;

    // إذا لم يكن هناك وزن مدخل، لا نحسب FCR
    if (lastWeight == 0.0) {
      return 0.0;
    }

    // تحديد ما إذا كان الوزن المدخل إجمالي للقطيع أم متوسط للفرخة الواحدة
    // إذا كان الوزن أكبر من 10 كيلو، نعتبره إجمالي الوزن للقطيع
    // وإلا نعتبره متوسط الوزن للفرخة الواحدة
    double totalLiveWeight;
    if (lastWeight > 10.0) {
      // الوزن المدخل هو إجمالي الوزن للقطيع
      totalLiveWeight = lastWeight;
    } else {
      // الوزن المدخل هو متوسط الوزن للفرخة الواحدة
      final cycle = cycleCtrl.currentCycle;
      final chickCount =
          int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0;
      final mortality =
          int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
      final aliveChickens = chickCount - mortality;
      totalLiveWeight = lastWeight * aliveChickens;
    }

    // حساب FCR من البيانات المدخلة فقط
    if (totalLiveWeight > 0 && totalFeedConsumed > 0) {
      return totalFeedConsumed / totalLiveWeight;
    }
    return 0.0;
  }

  double _getCurrentAverageWeight(CycleController cycleCtrl) {
    final weightEntries = cycleCtrl.getAverageWeightEntries();
    if (weightEntries.isEmpty) {
      return 0.0;
    }

    final lastWeight = weightEntries.last.weight;

    // إذا كان الوزن المدخل كبير (أكثر من 10 كيلو)، نعتبره إجمالي الوزن للقطيع
    // ونحتاج لحساب متوسط الوزن للفرخة الواحدة
    if (lastWeight > 10.0) {
      final cycle = cycleCtrl.currentCycle;
      final chickCount =
          int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0;
      final mortality =
          int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
      final aliveChickens = chickCount - mortality;

      if (aliveChickens > 0) {
        // إرجاع متوسط الوزن للفرخة الواحدة
        return lastWeight / aliveChickens;
      }
      return 0.0;
    } else {
      // الوزن المدخل هو متوسط الوزن للفرخة الواحدة
      return lastWeight;
    }
  }

  double _getExpectedWeight(BroilerController broilerCtrl) {
    final ageDays = broilerCtrl.selectedChickenAge.value ?? 0;
    if (ageDays <= 0 || ageDays > weightsList.length) return 0.0;
    // تحويل من جرام إلى كيلو
    return weightsList[ageDays - 1] / 1000.0;
  }

  double _calculateProductionEfficiency(
    CycleController cycleCtrl,
    BroilerController broilerCtrl,
  ) {
    // الحصول على العمر باليوم
    final ageDays = broilerCtrl.selectedChickenAge.value ?? 0;
    if (ageDays <= 0) return 0.0;

    // الحصول على FCR
    final fcr = _calculateFCR(cycleCtrl, broilerCtrl);
    if (fcr <= 0) return 0.0;

    // الحصول على متوسط الوزن (للفرخة الواحدة)
    final weightEntries = cycleCtrl.getAverageWeightEntries();
    if (weightEntries.isEmpty) return 0.0;

    final averageWeight = weightEntries.last.weight;

    // إذا كان الوزن المدخل كبير (أكثر من 10 كيلو)، نعتبره إجمالي الوزن للقطيع
    // ونحتاج لحساب متوسط الوزن للفرخة الواحدة
    double avgWeightPerChicken;
    final cycle = cycleCtrl.currentCycle;
    final chickCount =
        int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0;
    final mortality = int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
    final aliveChickens = chickCount - mortality;

    if (averageWeight > 10.0) {
      // الوزن المدخل هو إجمالي الوزن للقطيع
      if (aliveChickens > 0) {
        avgWeightPerChicken = averageWeight / aliveChickens;
      } else {
        return 0.0;
      }
    } else {
      // الوزن المدخل هو متوسط الوزن للفرخة الواحدة
      avgWeightPerChicken = averageWeight;
    }

    if (avgWeightPerChicken <= 0) return 0.0;

    // حساب نسبة البقاء (Survival Rate)
    double survivalRate = 0.0;
    if (chickCount > 0 && aliveChickens > 0) {
      survivalRate = (aliveChickens / chickCount) * 100.0;
    } else {
      return 0.0;
    }

    // حساب EPEF = (متوسط الوزن × نسبة البقاء) / (العمر × FCR) × 100
    final numerator = avgWeightPerChicken * survivalRate;
    final denominator = ageDays * fcr;
    if (denominator <= 0) return 0.0;

    final epef = (numerator / denominator) * 100.0;
    return epef;
  }

  double _calculateCostPerChicken(CycleController cycleCtrl) {
    // محاولة الحصول على CycleExpensesController
    CycleExpensesController expensesCtrl;
    try {
      expensesCtrl = Get.find<CycleExpensesController>();
    } catch (e) {
      // إذا لم يكن موجوداً، أنشئه
      expensesCtrl = Get.put(CycleExpensesController());
    }

    final totalExpenses = expensesCtrl.totalExpenses.value;
    final cycle = cycleCtrl.currentCycle;
    final chickCount =
        int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0;
    final mortality = int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
    final aliveChickens = chickCount - mortality;

    if (aliveChickens > 0 && totalExpenses > 0) {
      return totalExpenses / aliveChickens;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cycleCtrl = Get.find<CycleController>();
    final broilerCtrl = Get.find<BroilerController>();

    return Obx(() {
      final ageDays = broilerCtrl.selectedChickenAge.value ?? 0;
      final canCalculateFCR = ageDays >= 15;
      final showEarlyEvaluation = ageDays >= 15 && ageDays < 21;

      final fcr = canCalculateFCR ? _calculateFCR(cycleCtrl, broilerCtrl) : 0.0;
      final currentWeight = _getCurrentAverageWeight(cycleCtrl);
      final expectedWeight = _getExpectedWeight(broilerCtrl);
      final productionEfficiency = _calculateProductionEfficiency(
        cycleCtrl,
        broilerCtrl,
      );
      final costPerChicken = _calculateCostPerChicken(cycleCtrl);

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color:
              isDark
                  ? AppColors.darkSurfaceElevatedColor
                  : AppColors.lightCardBackgroundColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'مؤشرات الأداء',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkPrimaryColor : Colors.black87,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 16.h),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child:
                        canCalculateFCR
                            ? _buildMetricItemWithBadge(
                              label: 'معدل التحويل الغذائي',
                              value:
                                  fcr > 0
                                      ? (fcr % 1 == 0
                                          ? fcr.round().toString()
                                          : fcr.toStringAsFixed(1))
                                      : '0',
                              unit: '',
                              color: AppColors.primaryColor,
                              isDark: isDark,
                              showEarlyEvaluation: showEarlyEvaluation,
                            )
                            : _buildMetricItem(
                              label: 'معدل التحويل الغذائي',
                              value: 'سيتم التحديد عند عمر 15 يوم',
                              unit: '',
                              color: AppColors.primaryColor,
                              isDark: isDark,
                            ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildWeightMetricItem(
                      currentWeight: currentWeight,
                      expectedWeight: expectedWeight,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            // Production Efficiency and Cost in one row
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      label: 'الكفاءة الإنتاجية',
                      value: productionEfficiency.round().toString(),
                      unit: '%',
                      color: AppColors.primaryColor,
                      isDark: isDark,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildMetricItem(
                      label: 'تكلفة الطائر الواحد',
                      value: costPerChicken.round().toString(),
                      unit: 'جنيه',
                      color: AppColors.primaryColor,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      height: 110.h,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.08),
                    color.withValues(alpha: 0.04),
                  ]
                  : [
                    color.withValues(alpha: 0.12),
                    color.withValues(alpha: 0.08),
                    color.withValues(alpha: 0.04),
                  ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 2.h),
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              fontWeight: FontWeight.w700,
              height: 1.3,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6.h),
          // Value with enhanced styling
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: value.length > 10 ? 13.sp : 22.sp,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark
                            ? AppColors.darkPrimaryColor
                            : AppColors.primaryColor,
                    letterSpacing: 0.8,
                    height: 1.2,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatWeight(double weightInKg) {
    if (weightInKg < 1.0) {
      // إذا كان أقل من كيلو، اعرض بالجرام
      final grams = (weightInKg * 1000).round();
      return '$grams جرام';
    } else {
      // إذا كان كيلو أو أكثر، اعرض بالكيلو
      // إذا كان هناك كسر، اعرض منزلة عشرية واحدة فقط
      if (weightInKg % 1 == 0) {
        return '${weightInKg.round()} كيلو';
      } else {
        return '${weightInKg.toStringAsFixed(1)} كيلو';
      }
    }
  }

  String _formatWeightValue(double weightInKg) {
    if (weightInKg < 1.0) {
      // إذا كان أقل من كيلو، اعرض بالجرام
      final grams = (weightInKg * 1000).round();
      return grams.toString();
    } else {
      // إذا كان كيلو أو أكثر، اعرض بالكيلو
      // إذا كان هناك كسر، اعرض منزلة عشرية واحدة فقط
      if (weightInKg % 1 == 0) {
        return weightInKg.round().toString();
      } else {
        return weightInKg.toStringAsFixed(1);
      }
    }
  }

  String _formatWeightUnit(double weightInKg) {
    return weightInKg < 1.0 ? 'جرام' : 'كيلو';
  }

  Widget _buildWeightMetricItem({
    required double currentWeight,
    required double expectedWeight,
    required bool isDark,
  }) {
    final color = AppColors.primaryColor;
    final difference = currentWeight - expectedWeight;
    final isAboveExpected = difference >= 0;

    return Container(
      height: 110.h,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.08),
                    color.withValues(alpha: 0.04),
                  ]
                  : [
                    color.withValues(alpha: 0.12),
                    color.withValues(alpha: 0.08),
                    color.withValues(alpha: 0.04),
                  ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 2.h),
          Text(
            'متوسط الوزن',
            style: TextStyle(
              fontSize: 11.5.sp,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 5.h),
          // الوزن الحالي
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: _formatWeightValue(currentWeight),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark
                            ? AppColors.darkPrimaryColor
                            : AppColors.primaryColor,
                    letterSpacing: 0.6,
                    height: 1.1,
                  ),
                ),
                TextSpan(
                  text: ' ${_formatWeightUnit(currentWeight)}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          // الوزن المتوقع
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.grey[800]!.withValues(alpha: 0.5)
                      : Colors.grey[100]!.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'متوقع: ',
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Flexible(
                  child: Text(
                    _formatWeight(expectedWeight),
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // الفرق (إذا كان هناك فرق)
          if (expectedWeight > 0 && difference.abs() > 0.01) ...[
            SizedBox(height: 3.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              decoration: BoxDecoration(
                color:
                    isAboveExpected
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                        : const Color(0xFFFF9800).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                _formatWeight(difference.abs()),
                style: TextStyle(
                  fontSize: 9.sp,
                  color:
                      isAboveExpected
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF9800),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildMetricItemWithBadge({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required bool isDark,
    required bool showEarlyEvaluation,
  }) {
    return Container(
      height: 110.h,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.08),
                    color.withValues(alpha: 0.04),
                  ]
                  : [
                    color.withValues(alpha: 0.12),
                    color.withValues(alpha: 0.08),
                    color.withValues(alpha: 0.04),
                  ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              fontWeight: FontWeight.w700,
              height: 1.3,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        fontSize: value.length > 10 ? 13.sp : 22.sp,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark
                                ? AppColors.darkPrimaryColor
                                : AppColors.primaryColor,
                        letterSpacing: 0.8,
                        height: 1.2,
                      ),
                    ),
                    if (unit.isNotEmpty)
                      TextSpan(
                        text: ' $unit',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              if (showEarlyEvaluation) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF9800).withValues(alpha: 0.2),
                        const Color(0xFFFF9800).withValues(alpha: 0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'تقييم مبكر',
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      color: const Color(0xFFFF9800),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
