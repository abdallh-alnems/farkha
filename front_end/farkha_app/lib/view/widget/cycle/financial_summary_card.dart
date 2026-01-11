import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_expenses_controller.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';

class FinancialSummaryCard extends StatelessWidget {
  const FinancialSummaryCard({super.key});

  double _calculateCostPerChicken(
    double totalExpenses,
    int chickCount,
    int mortality,
  ) {
    final aliveChickens = chickCount - mortality;
    if (aliveChickens > 0) {
      return totalExpenses / aliveChickens;
    }
    return 0.0;
  }

  double _calculateTotalLiveWeight(CycleController cycleCtrl) {
    final weightEntries = cycleCtrl.getAverageWeightEntries();
    if (weightEntries.isEmpty) return 0.0;

    final lastWeight = weightEntries.last.weight;
    final cycle = cycleCtrl.currentCycle;
    final chickCount =
        int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0;
    final mortality = int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
    final aliveChickens = chickCount - mortality;

    // إذا كان الوزن أكبر من 10 كيلو، نعتبره إجمالي الوزن للقطيع
    if (lastWeight > 10.0) {
      return lastWeight;
    } else {
      // الوزن المدخل هو متوسط الوزن للفرخة الواحدة
      return lastWeight * aliveChickens;
    }
  }

  double _calculatePricePerKilo(double totalExpenses, double totalLiveWeight) {
    if (totalLiveWeight > 0) {
      return totalExpenses / totalLiveWeight;
    }
    return 0.0;
  }

  double _calculateExpectedProfit(
    CycleController cycleCtrl,
    double totalExpenses,
    int ageDays,
    int expectedDays,
    int chickCount,
    int mortality,
  ) {
    // عدد الطيور الحية
    final aliveChickens = chickCount - mortality;
    if (aliveChickens <= 0) return 0.0;

    // حساب الوزن النهائي المتوقع لكل طائر
    final weightEntries = cycleCtrl.getAverageWeightEntries();
    double finalWeightPerChicken = 0.0;

    if (weightEntries.isNotEmpty) {
      // استخدام آخر وزن مدخل كأساس
      final lastWeight = weightEntries.last.weight;
      if (lastWeight > 10.0) {
        // إذا كان الوزن إجمالي، نحوله إلى متوسط
        if (aliveChickens > 0) {
          finalWeightPerChicken = lastWeight / aliveChickens;
        }
      } else {
        finalWeightPerChicken = lastWeight;
      }

      // تقدير الوزن النهائي في نهاية الدورة (نمو إضافي)
      // متوسط نمو يومي تقريبي: 0.05 كيلو/يوم
      final remainingDays = expectedDays - ageDays;
      if (remainingDays > 0) {
        finalWeightPerChicken += remainingDays * 0.05;
      }
    } else {
      // إذا لم يكن هناك وزن مدخل، نستخدم الوزن المتوقع من البيانات القياسية
      // متوسط وزن في نهاية الدورة (45 يوم) حوالي 2.5 كيلو
      finalWeightPerChicken = 2.5;
    }

    // الحصول على سعر البورصة من API broilerChicken
    double stockPrice = 35.0; // قيمة افتراضية
    try {
      final broilerCtrl = Get.find<BroilerController>();
      if (broilerCtrl.broilerPrice.value > 0) {
        stockPrice = broilerCtrl.broilerPrice.value;
      }
    } catch (e) {
      // إذا لم يكن BroilerController موجوداً، نستخدم القيمة الافتراضية
    }

    // حساب الإيرادات المتوقعة
    // الإيرادات = عدد الطيور الحية × الوزن النهائي × سعر البورصة
    final expectedRevenue = aliveChickens * finalWeightPerChicken * stockPrice;

    // الربح المتوقع = الإيرادات المتوقعة - إجمالي المصروفات
    return expectedRevenue - totalExpenses;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cycleCtrl = Get.find<CycleController>();
    final broilerCtrl = Get.find<BroilerController>();

    return Obx(() {
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
      final mortality =
          int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
      final ageDays = broilerCtrl.selectedChickenAge.value ?? 0;
      final expectedDays = 45; // متوسط دورة التسمين

      final totalLiveWeight = _calculateTotalLiveWeight(cycleCtrl);
      final pricePerKilo = _calculatePricePerKilo(
        totalExpenses,
        totalLiveWeight,
      );
      final costPerChicken = _calculateCostPerChicken(
        totalExpenses,
        chickCount,
        mortality,
      );

      // حساب الربح المتوقع فقط إذا وصلت الدورة إلى 30 يوم
      final canCalculateProfit = ageDays >= 30;
      final expectedProfit =
          canCalculateProfit
              ? _calculateExpectedProfit(
                cycleCtrl,
                totalExpenses,
                ageDays,
                expectedDays,
                chickCount,
                mortality,
              )
              : 0.0;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color:
              isDark
                  ? AppColors.darkSurfaceElevatedColor
                  : AppColors.lightCardBackgroundColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'الملخص المالي',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? AppColors.darkPrimaryColor : Colors.black87,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withOpacity(0.25),
                        AppColors.primaryColor.withOpacity(0.18),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Get.toNamed(AppRoute.cycleExpenses);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'المصروفات',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark
                                ? AppColors.darkPrimaryColor
                                : const Color(0xFF1A3A52),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            // إجمالي المصروفات
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.25),
                    AppColors.primaryColor.withOpacity(0.18),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'إجمالي المصروفات',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? Colors.grey[200] : const Color(0xFF1A3A52),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '${totalExpenses.toStringAsFixed(0)} جنيه',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark
                              ? AppColors.darkPrimaryColor
                              : const Color(0xFF0D2A3F),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // المؤشرات الأخرى
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildFinancialInfo(
                      icon: Icons.attach_money,
                      label: 'تكلفة الطائر',
                      value: costPerChicken.round().toString(),
                      unit: 'جنيه',
                      color: AppColors.primaryColor,
                      isDark: isDark,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildFinancialInfo(
                      icon: Icons.scale,
                      label: 'سعر الكيلو',
                      value:
                          pricePerKilo == pricePerKilo.truncateToDouble()
                              ? pricePerKilo.round().toString()
                              : pricePerKilo.toStringAsFixed(1),
                      unit: 'جنيه',
                      color: AppColors.primaryColor,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildFinancialInfo(
                      icon: Icons.monitor_weight,
                      label: 'إجمالي الوزن',
                      value:
                          totalLiveWeight > 0
                              ? (totalLiveWeight % 1 == 0
                                  ? totalLiveWeight.round().toString()
                                  : totalLiveWeight.toStringAsFixed(1))
                              : '0',
                      unit: 'كيلو',
                      color: AppColors.primaryColor,
                      isDark: isDark,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child:
                        canCalculateProfit
                            ? _buildFinancialInfo(
                              icon: Icons.trending_up,
                              label: 'الربح المتوقع',
                              value: expectedProfit.toStringAsFixed(0),
                              unit: 'جنيه',
                              color: AppColors.primaryColor,
                              isDark: isDark,
                            )
                            : _buildFinancialInfo(
                              icon: Icons.trending_up,
                              label: 'الربح المتوقع',
                              value: 'سيتم التحديد عند عمر 30 يوم',
                              unit: '',
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

  Widget _buildFinancialInfo({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      height: 85.h,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [
                    color.withOpacity(0.18),
                    color.withOpacity(0.12),
                    color.withOpacity(0.06),
                  ]
                  : [
                    color.withOpacity(0.25),
                    color.withOpacity(0.15),
                    color.withOpacity(0.08),
                  ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.3 : 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.1 : 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isDark ? color : AppColors.primaryColor,
                size: 16.sp,
              ),
              SizedBox(width: 5.w),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: value.length > 15 ? 11.sp : 17.sp,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark
                            ? AppColors.darkPrimaryColor
                            : AppColors.primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
