import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_expenses_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/cycle/add_expense_dialog.dart';
import '../../widget/cycle/expense_card.dart';

class CycleExpensesScreen extends StatefulWidget {
  const CycleExpensesScreen({super.key});

  @override
  State<CycleExpensesScreen> createState() => _CycleExpensesScreenState();
}

class _CycleExpensesScreenState extends State<CycleExpensesScreen> {
  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    final cycleCtrl = Get.find<CycleController>();
    final cycle = cycleCtrl.currentCycle;
    final isViewer = cycle['role']?.toString() == 'viewer';
    final expensesCtrl = Get.find<CycleExpensesController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackGroundColor : AppColors.appBackGroundColor,
      appBar: AppBar(
        backgroundColor:
            isDark
                ? AppColors.darkSurfaceElevatedColor
                : AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkPrimaryColor : Colors.white,
          ),
          onPressed: () => Get.back<void>(),
        ),
        title: Text(
          'مصروفات ${cycle['name'] ?? 'الدورة'}',
          style: TextStyle(
            color: isDark ? AppColors.darkPrimaryColor : Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (cycle['role']?.toString() != 'viewer')
            IconButton(
              icon: Icon(
                Icons.add,
                color: isDark ? AppColors.darkPrimaryColor : Colors.white,
              ),
              onPressed: () => showAddExpenseDialog(expensesCtrl, isDark),
            ),
        ],
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
                  _buildTotalCard(expensesCtrl, isDark),
                  SizedBox(height: 12.h),
                  _buildExpensesSection(
                    expensesCtrl,
                    isDark,
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

  Widget _buildExpensesSection(
    CycleExpensesController controller,
    bool isDark, {
    bool isViewer = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          if (controller.expenses.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(40.h),
                child: Text(
                  'لا توجد مصروفات',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            );
          }
          return Column(
            children: [
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
                        isDark: isDark,
                        isViewer: isViewer,
                      ),
                    ),
                    if (index == 0) ...[
                      SizedBox(height: 12.h),
                      const AdNativeWidget(),
                      SizedBox(height: 12.h),
                    ],
                  ],
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTotalCard(CycleExpensesController controller, bool isDark) {
    return Obx(() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color:
              isDark
                  ? AppColors.darkSurfaceElevatedColor
                  : AppColors.primaryColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'إجمالي المصروفات',
              style: TextStyle(
                color: isDark ? AppColors.darkPrimaryColor : Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${controller.totalExpenses.value.round()} جنيه',
              style: TextStyle(
                color: isDark ? AppColors.darkPrimaryColor : Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    });
  }
}
