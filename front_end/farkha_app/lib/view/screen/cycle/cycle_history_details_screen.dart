import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/theme.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../widget/cycle/history/history_details_bottom_sheets.dart';
import '../../widget/cycle/history/history_details_header.dart';
import '../../widget/cycle/history/history_details_summary.dart';
import '../../widget/home/cycle_card_actions.dart';

class CycleHistoryDetailsScreen extends StatelessWidget {
  const CycleHistoryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cycleCtrl = Get.find<CycleController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final cycle = cycleCtrl.historicCycleDetails;
          if (cycle.isEmpty) return;
          final choice = await showCycleShareDialog(isDark);
          if (choice == null) return;
          await handleCycleShare(
            choice,
            cycle,
            cycle['cycle_age']?.toString() ?? '0',
          );
        },
        backgroundColor: AppColors.accentColor,
        icon: Icon(Icons.ios_share_rounded, color: Colors.white, size: 22.sp),
        label: Text(
          'مشاركة',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
      ),
      body: Obx(() {
        final status = cycleCtrl.historicCycleStatus.value;
        final cycle = cycleCtrl.historicCycleDetails;

        if (cycle.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.25),
                ),
                SizedBox(height: 12.h),
                Text(
                  'لا توجد بيانات متاحة',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                HistoryDetailsHeader(
                  name: cycle['name']?.toString() ?? 'دورة بدون اسم',
                  breed: cycle['breed']?.toString() ?? 'تسمين',
                  systemType: cycle['systemType']?.toString() ?? 'أرضي',
                  isDark: isDark,
                  colorScheme: colorScheme,
                  onBack: () => Get.back<void>(),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    8.h,
                    AppSpacing.screenH,
                    100.h,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSummary(cycle, isDark, context, colorScheme),
                    ]),
                  ),
                ),
              ],
            ),
            if (status == StatusRequest.loading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildSummary(
    Map<String, dynamic> cycle,
    bool isDark,
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final startDate = cycle['startDate']?.toString() ?? '-';
    final endDate = cycle['endDate']?.toString() ?? '-';
    final cycleAge = cycle['cycle_age']?.toString() ?? '0';
    final chickCount = cycle['chickCount']?.toString() ?? '0';
    final space = cycle['space']?.toString() ?? '0';

    final liveCount =
        (int.tryParse(chickCount) ?? 0) -
        (int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0);
    final mortality = cycle['mortality']?.toString() ?? '0';
    final mortalityRate = cycle['mortality_rate']?.toString() ?? '0.0';
    final fcr = cycle['fcr']?.toString() ?? '0.00';
    final costPerBird = cycle['cost_per_bird']?.toString() ?? '0.00';
    final averageWeight =
        double.tryParse(cycle['average_weight']?.toString() ?? '0') ?? 0.0;
    final totalMeat = liveCount * averageWeight;
    final totalExpenses =
        double.tryParse(cycle['total_expenses']?.toString() ?? '0') ?? 0.0;
    final totalSales =
        double.tryParse(cycle['total_sales']?.toString() ?? '0') ?? 0.0;
    final netProfit =
        double.tryParse(cycle['net_profit']?.toString() ?? '0') ?? 0.0;
    final totalFeed =
        double.tryParse(cycle['total_feed']?.toString() ?? '0') ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 28.h),
        HistoryDateBar(
          startDate: startDate,
          endDate: endDate,
          cycleAge: cycleAge,
          space: space,
          isDark: isDark,
          colorScheme: colorScheme,
        ),
        SizedBox(height: AppSpacing.xl),
        HistorySectionHeader(
          title: 'أداء القطيع والمخرجات',
          icon: Icons.bar_chart_rounded,
          colorScheme: colorScheme,
          suffix: InkWell(
            onTap: () => HistoryDetailsBottomSheets.openBottomSheet(
              context,
              'السجلات اليومية',
              HistoryDetailsBottomSheets.buildDailyRecordsList(
                cycle,
                isDark,
                colorScheme,
              ),
            ),
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: AppColors.primaryColor
                    .withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notes_rounded,
                    size: 15.sp,
                    color: AppColors.primaryColor,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    'الملاحظات',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        HistoryMetricsGrid(
          isDark: isDark,
          colorScheme: colorScheme,
          items: [
            MetricItem(
              label: 'العدد الأولي',
              value: chickCount,
              color: AppColors.infoColor,
              icon: Icons.egg_outlined,
            ),
            MetricItem(
              label: 'المتبقي',
              value: liveCount.toString(),
              color: AppColors.successColor,
              icon: Icons.pets_outlined,
            ),
            MetricItem(
              label: 'النافق',
              value: '$mortality ($mortalityRate%)',
              color: AppColors.errorColor,
              icon: Icons.warning_amber_rounded,
            ),
            MetricItem(
              label: 'معامل التحويل',
              value: fcr,
              color: AppColors.primaryColor,
              icon: Icons.speed_rounded,
            ),
            MetricItem(
              label: 'متوسط الوزن',
              value: '${averageWeight.toStringAsFixed(1)} كجم',
              color: AppColors.accentColor,
              icon: Icons.monitor_weight_outlined,
            ),
            MetricItem(
              label: 'إجمالي اللحم',
              value: '${totalMeat.toStringAsFixed(0)} كجم',
              color: AppColors.secondaryColor,
              icon: Icons.inventory_2_outlined,
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xl),
        HistorySectionHeader(
          title: 'المالية والمخزون',
          icon: Icons.account_balance_wallet_outlined,
          colorScheme: colorScheme,
        ),
        SizedBox(height: AppSpacing.md),
        HistoryFinancialCard(
          costPerBird: costPerBird,
          totalFeed: totalFeed,
          totalExpenses: totalExpenses,
          totalSales: totalSales,
          netProfit: netProfit,
          isDark: isDark,
          colorScheme: colorScheme,
          onExpensesTap: () => HistoryDetailsBottomSheets.openBottomSheet(
            context,
            'المصروفات التفصيلية',
            HistoryDetailsBottomSheets.buildExpensesList(
              cycle,
              isDark,
              colorScheme,
            ),
          ),
        ),
      ],
    );
  }
}
