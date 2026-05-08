import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constant/routes/route.dart';
import '../../../../core/constant/theme/colors.dart';
import '../../../../logic/controller/cycle_controller.dart';
import 'history_cycle_details.dart';

class HistoryCycleItem extends StatelessWidget {
  const HistoryCycleItem({
    super.key,
    required this.cycle,
    required this.isDark,
    required this.cycleCtrl,
  });

  final Map<String, dynamic> cycle;
  final bool isDark;
  final CycleController cycleCtrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = cycle['name']?.toString() ?? 'دورة بدون اسم';
    final startDate = cycle['startDate']?.toString() ?? '-';
    final endDate = cycle['endDate']?.toString() ?? '-';

    final chickCount = cycle['chickCount']?.toString() ?? '0';
    final liveCount =
        (int.tryParse(chickCount) ?? 0) -
        (int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0);
    final mortality = cycle['mortality']?.toString() ?? '0';

    final systemType = cycle['systemType']?.toString() ?? 'أرضي';
    final breed = cycle['breed']?.toString() ?? 'تسمين';
    final fcr = cycle['fcr']?.toString() ?? '0.00';
    final costPerBird = cycle['cost_per_bird']?.toString() ?? '0.00';
    final cycleAge = cycle['cycle_age']?.toString() ?? '0';
    final totalExpenses =
        double.tryParse(cycle['total_expenses']?.toString() ?? '0') ?? 0.0;
    final totalSales =
        double.tryParse(cycle['total_sales']?.toString() ?? '0') ?? 0.0;
    final netProfit =
        double.tryParse(cycle['net_profit']?.toString() ?? '0') ?? 0.0;
    final totalFeed =
        double.tryParse(cycle['total_feed']?.toString() ?? '0') ?? 0.0;
    final averageWeight =
        double.tryParse(cycle['average_weight']?.toString() ?? '0') ?? 0.0;
    final mortalityRate = cycle['mortality_rate']?.toString() ?? '0.0';

    return InkWell(
      onTap: () {
        cycleCtrl.historicCycleDetails.assignAll(cycle);
        final cycleId =
            int.tryParse(cycle['cycle_id']?.toString() ?? '0') ?? 0;
        if (cycleId > 0) {
          cycleCtrl.fetchHistoricCycleDetails(cycleId);
        }
        Get.toNamed<void>(AppRoute.cycleHistoryDetails);
      },
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.05),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              offset: const Offset(0, 8),
              blurRadius: 24,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Column(
            children: [
              _buildHeader(name, breed, systemType, colorScheme),
              _buildDates(startDate, endDate, cycleAge, colorScheme),
              CycleItemMetrics(
                chickCount: chickCount,
                liveCount: liveCount.toString(),
                mortality: mortality,
                mortalityRate: mortalityRate,
                costPerBird: costPerBird,
                fcr: fcr,
                averageWeight: averageWeight,
                colorScheme: colorScheme,
              ),
              CycleItemFooter(
                totalFeed: totalFeed,
                totalExpenses: totalExpenses,
                totalSales: totalSales,
                netProfit: netProfit,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    String name,
    String breed,
    String systemType,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              if (breed.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(left: 6.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.blueAccent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    breed,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.sunsetGradientEnd.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.sunsetGradientEnd.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  systemType,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.sunsetGradientEnd,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20.sp,
                ),
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'share') {
                    _shareCycle();
                  } else if (value == 'delete') {
                    Get.snackbar(
                      'قريباً',
                      'ميزة إزالة السجل نهائياً ستكون متاحة قريباً',
                      backgroundColor: colorScheme.surface,
                      colorText: colorScheme.onSurface,
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(
                          Icons.share_outlined,
                          color: Colors.blueAccent,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text('مشاركة', style: TextStyle(fontSize: 14.sp)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text('حذف من السجل', style: TextStyle(fontSize: 14.sp)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDates(String startDate, String endDate, String cycleAge, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  '$startDate  -  $endDate',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 8.h,
            ),
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$cycleAge يوم',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareCycle() {
    final name = cycle['name']?.toString() ?? 'دورة بدون اسم';
    final startDate = cycle['startDate']?.toString() ?? '-';
    final endDate = cycle['endDate']?.toString() ?? '-';
    final breed = cycle['breed']?.toString() ?? '-';
    final systemType = cycle['systemType']?.toString() ?? 'أرضي';
    final chickCount =
        int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0;
    final mortality =
        int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
    final mortalityRate = cycle['mortality_rate']?.toString() ?? '0.0';
    final cycleAge = cycle['cycle_age']?.toString() ?? '0';
    final fcr = cycle['fcr']?.toString() ?? '0.0';
    final costPerBird = cycle['cost_per_bird']?.toString() ?? '0.00';
    final averageWeight =
        double.tryParse(cycle['average_weight']?.toString() ?? '0') ?? 0.0;
    final totalFeed =
        double.tryParse(cycle['total_feed']?.toString() ?? '0') ?? 0.0;
    final totalExpenses =
        double.tryParse(cycle['total_expenses']?.toString() ?? '0') ?? 0.0;
    final totalSales =
        double.tryParse(cycle['total_sales']?.toString() ?? '0') ?? 0.0;
    final netProfit =
        double.tryParse(cycle['net_profit']?.toString() ?? '0') ?? 0.0;
    final liveCount = chickCount - mortality;

    final text = '''
🐔 ملخص دورة: $name
━━━━━━━━━━━━━━━━━━━━
📋 معلومات الدورة
📅 من: $startDate
📅 إلى: $endDate
⏳ مدة الدورة: $cycleAge يوم
🌾 السلالة: $breed
🏠 نظام التربية: $systemType

━━━━━━━━━━━━━━━━━━━━
🐣 الطيور
   العدد الأولي: $chickCount طير
   المتبقي:      $liveCount طير
   النافق:       $mortality ($mortalityRate%)

━━━━━━━━━━━━━━━━━━━━
📊 الأداء الإنتاجي
   متوسط الوزن:    ${averageWeight.toStringAsFixed(2)} كجم
   معامل التحويل:  $fcr
   تكلفة الفرخ:   $costPerBird ج
   إجمالي العلف:  ${totalFeed.toStringAsFixed(0)} كجم

━━━━━━━━━━━━━━━━━━━━
💰 المالية
   المصروفات: ${totalExpenses.toStringAsFixed(0)} ج
   المبيعات:  ${totalSales.toStringAsFixed(0)} ج
   الصافي:    ${netProfit >= 0 ? '+' : ''}${netProfit.toStringAsFixed(0)} ج
''';

    SharePlus.instance
        .share(ShareParams(text: text, subject: 'ملخص دورة: $name'));
  }
}
