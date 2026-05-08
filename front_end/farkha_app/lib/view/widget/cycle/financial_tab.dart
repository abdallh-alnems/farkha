import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_expenses_controller.dart';
import '../../../logic/controller/cycle_sales_controller.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';

class FinancialTab extends StatelessWidget {
  const FinancialTab({super.key});

  double _costPerChicken(double totalExpenses, int chickCount, int mortality) {
    final alive = chickCount - mortality;
    return alive > 0 ? totalExpenses / alive : 0.0;
  }

  double _totalLiveWeight(CycleController cycleCtrl) {
    final entries = cycleCtrl.getAverageWeightEntries();
    if (entries.isEmpty) return 0.0;
    final last = entries.last.weight;
    final cycle = cycleCtrl.currentCycle;
    final alive = (int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0) -
        (int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0);
    return last > 10.0 ? last : last * alive;
  }

  double _pricePerKilo(double expenses, double weight) =>
      weight > 0 ? expenses / weight : 0.0;

  double _expectedProfit(
    CycleController cycleCtrl,
    double totalExpenses,
    int ageDays,
    int chickCount,
    int mortality,
  ) {
    final alive = chickCount - mortality;
    if (alive <= 0) return 0.0;

    final entries = cycleCtrl.getAverageWeightEntries();
    double finalWeight;
    if (entries.isNotEmpty) {
      final last = entries.last.weight;
      if (last > 10.0) {
        finalWeight = alive > 0 ? last / alive : 0.0;
      } else {
        finalWeight = last;
      }
      final remaining = 45 - ageDays;
      if (remaining > 0) finalWeight += remaining * 0.05;
    } else {
      finalWeight = 2.5;
    }

    double stockPrice = 35.0;
    try {
      final broilerCtrl = Get.find<BroilerController>();
      if (broilerCtrl.broilerPrice.value > 0) {
        stockPrice = broilerCtrl.broilerPrice.value;
      }
    } catch (_) {}

    return (alive * finalWeight * stockPrice) - totalExpenses;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cycleCtrl = Get.find<CycleController>();
    final broilerCtrl = Get.find<BroilerController>();

    return Obx(() {
      final expensesCtrl = Get.find<CycleExpensesController>();
      final salesCtrl = Get.isRegistered<CycleSalesController>()
          ? Get.find<CycleSalesController>()
          : Get.put(CycleSalesController());

      final totalExpenses = expensesCtrl.totalExpenses.value;
      final totalSales = salesCtrl.totalSales.value;
      final netProfit = totalSales - totalExpenses;
      final cycle = cycleCtrl.currentCycle;
      final chickCount = int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0;
      final mortality = int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
      final ageDays = (broilerCtrl.selectedChickenAge.value as num?)?.toInt() ?? 0;
      final canProfit = ageDays >= 30;

      final liveWeight = _totalLiveWeight(cycleCtrl);
      final priceKg = _pricePerKilo(totalExpenses, liveWeight);
      final costBird = _costPerChicken(totalExpenses, chickCount, mortality);
      final expected = canProfit
          ? _expectedProfit(cycleCtrl, totalExpenses, ageDays, chickCount, mortality)
          : 0.0;

      final surfaceColor =
          isDark ? AppColors.darkSurfaceElevatedColor : AppColors.lightSurfaceColor;
      final dimColor = isDark ? AppColors.darkOutlineColor : AppColors.lightOutlineColor;

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
        child: Column(
          children: [
            _buildMainComparison(
              expenses: totalExpenses,
              sales: totalSales,
              netProfit: netProfit,
              isDark: isDark,
            ),
            SizedBox(height: 16.h),
            _buildDetailsGrid(
              costBird: costBird,
              priceKg: priceKg,
              liveWeight: liveWeight,
              hasSales: totalSales > 0,
              netProfit: netProfit,
              canProfit: canProfit,
              expected: expected,
              isDark: isDark,
              surfaceColor: surfaceColor,
              dimColor: dimColor,
            ),
            SizedBox(height: 16.h),
            _buildActionButtons(isDark),
          ],
        ),
      );
    });
  }

  Widget _buildMainComparison({
    required double expenses,
    required double sales,
    required double netProfit,
    required bool isDark,
  }) {
    final surfaceColor =
        isDark ? AppColors.darkSurfaceElevatedColor : AppColors.lightSurfaceColor;
    final dimColor = isDark ? AppColors.darkOutlineColor : AppColors.lightOutlineColor;

    final isPositive = netProfit >= 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: dimColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _bigNumber(
                  label: 'المصروفات',
                  value: expenses.toStringAsFixed(0),
                  unit: 'جـ',
                  color: AppColors.errorColor,
                  isDark: isDark,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 18.sp,
                    color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
                  ),
                ),
              ),
              Expanded(
                child: _bigNumber(
                  label: 'المبيعات',
                  value: sales.toStringAsFixed(0),
                  unit: 'جـ',
                  color: AppColors.successColor,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              color: (isPositive ? AppColors.successColor : AppColors.errorColor)
                  .withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Text(
                  sales > 0 ? 'صافي الربح' : 'الوضع الحالي',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${isPositive ? '+' : ''}${netProfit.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w900,
                    color: isPositive
                        ? (isDark ? AppColors.darkPrimaryColor : AppColors.successColor)
                        : AppColors.errorColor,
                    height: 1.1,
                  ),
                ),
                Text(
                  'جنيه',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigNumber({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.1 : 0.06),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGrid({
    required double costBird,
    required double priceKg,
    required double liveWeight,
    required bool hasSales,
    required double netProfit,
    required bool canProfit,
    required double expected,
    required bool isDark,
    required Color surfaceColor,
    required Color dimColor,
  }) {
    final accentColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    Widget detailItem({
      required IconData icon,
      required String label,
      required String value,
      required String unit,
      Color? valueColor,
    }) {
      return Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: dimColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14.sp, color: valueColor ?? accentColor),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: value.length > 10 ? 13.sp : 18.sp,
                        fontWeight: FontWeight.w800,
                        color: valueColor ?? accentColor,
                        height: 1.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    SizedBox(width: 3.w),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(children: [
          detailItem(
            icon: Icons.attach_money,
            label: 'تكلفة الطائر',
            value: costBird.round().toString(),
            unit: 'جنيه',
          ),
          SizedBox(width: 8.w),
          detailItem(
            icon: Icons.scale,
            label: 'سعر الكيلو',
            value: priceKg == priceKg.truncateToDouble()
                ? priceKg.round().toString()
                : priceKg.toStringAsFixed(1),
            unit: 'جنيه',
          ),
        ]),
        SizedBox(height: 8.h),
        Row(children: [
          detailItem(
            icon: Icons.monitor_weight_outlined,
            label: 'إجمالي الوزن',
            value: liveWeight > 0
                ? (liveWeight % 1 == 0 ? liveWeight.round().toString() : liveWeight.toStringAsFixed(1))
                : '0',
            unit: 'كيلو',
          ),
          SizedBox(width: 8.w),
          hasSales
              ? detailItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'صافي الربح',
                  value: netProfit.toStringAsFixed(0),
                  unit: 'جنيه',
                  valueColor: netProfit >= 0 ? AppColors.successColor : AppColors.errorColor,
                )
              : detailItem(
                  icon: Icons.trending_up_outlined,
                  label: 'الربح المتوقع',
                  value: canProfit ? expected.toStringAsFixed(0) : 'عند 30 يوم',
                  unit: canProfit ? 'جنيه' : '',
                  valueColor: canProfit ? accentColor : (isDark ? Colors.grey[500] : Colors.grey[500]),
                ),
        ]),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    final surfaceColor =
        isDark ? AppColors.darkSurfaceElevatedColor : AppColors.lightSurfaceColor;
    final dimColor = isDark ? AppColors.darkOutlineColor : AppColors.lightOutlineColor;
    final accentColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Get.toNamed<void>(AppRoute.cycleSales),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 18.sp, color: isDark ? AppColors.darkBackGroundColor : Colors.white),
                  SizedBox(width: 6.w),
                  Text(
                    'المبيعات',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkBackGroundColor : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: GestureDetector(
            onTap: () => Get.toNamed<void>(AppRoute.cycleExpenses),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: dimColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 18.sp, color: accentColor),
                  SizedBox(width: 6.w),
                  Text(
                    'المصروفات',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
