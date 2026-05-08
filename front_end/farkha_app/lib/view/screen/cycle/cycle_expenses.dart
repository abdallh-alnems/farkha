import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_expenses_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/cycle_sub_screen_appbar.dart';
import '../../widget/cycle/add_expense_dialog.dart';
import '../../widget/cycle/expense_card.dart';

class CycleExpensesScreen extends StatefulWidget {
  const CycleExpensesScreen({super.key});

  @override
  State<CycleExpensesScreen> createState() => _CycleExpensesScreenState();
}

class _CycleExpensesScreenState extends State<CycleExpensesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heroController;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heroController.forward();

    if (!Get.isRegistered<CycleController>()) {
      Get.put(CycleController());
    }
    if (!Get.isRegistered<CycleExpensesController>()) {
      Get.put(CycleExpensesController());
    }
    final cycleCtrl = Get.find<CycleController>();
    final cycleId = cycleCtrl.currentCycle['cycle_id'];
    if (cycleId != null) {
      final cycleIdInt =
          cycleId is int ? cycleId : int.tryParse(cycleId.toString());
      if (cycleIdInt != null && cycleIdInt > 0) {
        cycleCtrl.fetchCycleDetails(cycleIdInt, silent: true);
      }
    }
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cycleCtrl = Get.find<CycleController>();
    final cycle = cycleCtrl.currentCycle;
    final isViewer = cycle['role']?.toString() == 'viewer';
    final expensesCtrl = Get.find<CycleExpensesController>();
    return Scaffold(
      appBar: CycleSubScreenAppBar(
        titlePrefix: 'مصروفات',
        onAddPressed: () => showAddExpenseDialog(expensesCtrl),
      ),
      body: Obx(() {
        final isLoading =
            cycleCtrl.cycleDetailsStatus.value == StatusRequest.loading;
        if (isLoading) {
          return const SafeArea(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () => cycleCtrl.forceRefreshCurrentCycle(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExpenseHero(expensesCtrl),
                  SizedBox(height: 24.h),
                  _buildExpensesSection(
                    expensesCtrl,
                    isViewer: isViewer,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildExpenseHero(CycleExpensesController controller) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _heroController,
        curve: Curves.easeOutCubic,
      ),
      child: Obx(() {
        final total = controller.totalExpenses.value.round();

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      AppColors.errorColor.withValues(alpha: 0.12),
                      AppColors.darkSurfaceElevatedColor,
                    ]
                  : [
                      AppColors.errorColor.withValues(alpha: 0.06),
                      AppColors.lightSurfaceColor,
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark
                  ? AppColors.errorColor.withValues(alpha: 0.15)
                  : AppColors.errorColor.withValues(alpha: 0.1),
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: AppColors.errorColor.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Padding(
                padding:
                    EdgeInsetsDirectional.fromSTEB(20.w, 20.h, 20.w, 18.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color:
                                AppColors.errorColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.errorColor,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'إجمالي المصروفات',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[800],
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$total',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.errorColor,
                            height: 1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Padding(
                          padding: EdgeInsets.only(bottom: 4.h),
                          child: Text(
                            'جنيه',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  AppColors.errorColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
        );
      }),
    );
  }

  Widget _buildExpensesSection(
    CycleExpensesController controller, {
    bool isViewer = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      if (controller.expenses.isEmpty) {
        return _buildEmptyState(colorScheme);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: Row(
              children: [
                Text(
                  'تفاصيل المصروفات',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '${controller.expenses.length}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...controller.expenses.asMap().entries.map((entry) {
            final index = entry.key;
            final expense = entry.value;
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: ExpenseCard(
                    index: index,
                    expense: expense,
                    isViewer: isViewer,
                  ),
                ),
                if (index == 0) ...[
                  SizedBox(height: 4.h),
                  const AdNativeWidget(),
                  SizedBox(height: 12.h),
                ],
              ],
            );
          }),
        ],
      );
    });
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 40.sp,
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد مصروفات',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'أضف مصروفات لتتبع نفقات الدورة',
              style: TextStyle(
                fontSize: 13.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
