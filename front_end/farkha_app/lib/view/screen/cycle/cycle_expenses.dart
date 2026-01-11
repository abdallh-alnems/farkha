import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_expenses_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';

class CycleExpensesScreen extends StatelessWidget {
  const CycleExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cycleCtrl = Get.find<CycleController>();
    final cycle = cycleCtrl.currentCycle;
    final expensesCtrl = Get.put(CycleExpensesController());
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
          onPressed: () => Get.back(),
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
          IconButton(
            icon: Icon(
              Icons.add,
              color: isDark ? AppColors.darkPrimaryColor : Colors.white,
            ),
            onPressed: () => _showAddExpenseDialog(expensesCtrl, isDark),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalCard(expensesCtrl, isDark),
              SizedBox(height: 12.h),
              _buildExpensesSection(expensesCtrl, isDark),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildExpensesSection(
    CycleExpensesController controller,
    bool isDark,
  ) {
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
                      child: _buildExpenseItem(
                        controller: controller,
                        index: index,
                        expense: expense,
                        isDark: isDark,
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

  Widget _buildExpenseItem({
    required CycleExpensesController controller,
    required int index,
    required ExpenseItem expense,
    required bool isDark,
  }) {
    final textController = TextEditingController();
    final focusNode = FocusNode();
    final isHistoryExpanded = false.obs;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color:
              isDark
                  ? AppColors.darkOutlineColor.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow:
            isDark
                ? []
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                    spreadRadius: 0,
                  ),
                ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              gradient:
                  isDark
                      ? null
                      : LinearGradient(
                        colors: [
                          AppColors.primaryColor.withOpacity(0.03),
                          Colors.transparent,
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDark
                              ? [
                                AppColors.darkPrimaryColor.withOpacity(0.2),
                                AppColors.darkPrimaryColor.withOpacity(0.15),
                              ]
                              : [
                                AppColors.primaryColor.withOpacity(0.15),
                                AppColors.primaryColor.withOpacity(0.08),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow:
                        isDark
                            ? []
                            : [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                  ),
                  child: Icon(
                    expense.icon,
                    color:
                        isDark
                            ? AppColors.darkPrimaryColor
                            : AppColors.primaryColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.label,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.1,
                          color:
                              isDark
                                  ? AppColors.darkPrimaryColor
                                  : AppColors.primaryColor,
                        ),
                      ),
                      Obx(() {
                        final total = expense.totalAmount;
                        if (total > 0) {
                          return Padding(
                            padding: EdgeInsets.only(top: 3.h),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? AppColors.darkPrimaryColor
                                                .withOpacity(0.2)
                                            : AppColors.primaryColor
                                                .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  child: Text(
                                    'المجموع: ${total.round()} جنيه',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isDark
                                              ? AppColors.darkPrimaryColor
                                              : AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox();
                      }),
                    ],
                  ),
                ),
                Obx(() {
                  final hasMultiplePayments = expense.payments.length > 1;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasMultiplePayments)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              isHistoryExpanded.value =
                                  !isHistoryExpanded.value;
                            },
                            borderRadius: BorderRadius.circular(10.r),
                            child: Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color:
                                    isHistoryExpanded.value
                                        ? AppColors.primaryColor.withOpacity(
                                          0.3,
                                        )
                                        : isDark
                                        ? AppColors.darkPrimaryColor
                                            .withOpacity(0.25)
                                        : AppColors.primaryColor.withOpacity(
                                          0.2,
                                        ),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.4,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                isHistoryExpanded.value
                                    ? Icons.expand_less_rounded
                                    : Icons.history_rounded,
                                size: 14.sp,
                                color:
                                    isDark
                                        ? AppColors.darkPrimaryColor
                                        : AppColors.primaryColor,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (hasMultiplePayments) SizedBox(width: 5.w),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _showDeleteConfirmDialog(
                              controller,
                              index,
                              expense.label,
                            );
                          },
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.red[500],
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color:
                isDark
                    ? AppColors.darkOutlineColor.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.15),
          ),

          // Payment Section (Last Payment when collapsed, All Payments when expanded)
          Obx(() {
            if (expense.payments.isEmpty) {
              return const SizedBox.shrink();
            }

            // ترتيب المدفوعات من الأحدث إلى الأقدم
            final sortedPayments = List.from(expense.payments)
              ..sort((a, b) => b.date.compareTo(a.date));

            // إذا كان السجل مغلقاً، اعرض آخر مبلغ فقط
            if (!isHistoryExpanded.value) {
              final lastPayment = sortedPayments.first;
              final lastPaymentIndex = expense.payments.indexWhere(
                (p) => p.id == lastPayment.id,
              );

              return Container(
                margin: EdgeInsets.all(12.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        isDark
                            ? [
                              AppColors.darkSurfaceElevatedColor,
                              AppColors.darkSurfaceElevatedColor.withOpacity(
                                0.8,
                              ),
                            ]
                            : [
                              AppColors.primaryColor.withOpacity(0.08),
                              AppColors.primaryColor.withOpacity(0.04),
                            ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color:
                        isDark
                            ? AppColors.darkOutlineColor.withOpacity(0.3)
                            : AppColors.primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 2.5.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryColor.withOpacity(0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${lastPayment.amount.round()}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                  color:
                                      isDark
                                          ? AppColors.darkPrimaryColor
                                          : AppColors.primaryColor,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: 1.5.h,
                                  right: 3.w,
                                ),
                                child: Text(
                                  'جنيه',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 9.sp,
                                color:
                                    isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[500],
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                DateFormat(
                                  'yyyy-MM-dd',
                                ).format(lastPayment.date),
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color:
                                      isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (lastPaymentIndex != -1) {
                            _showDeletePaymentConfirmDialog(
                              controller,
                              index,
                              lastPaymentIndex,
                              lastPayment.amount,
                              expense.label,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(6.r),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            size: 14.sp,
                            color: Colors.red[500],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // إذا كان السجل مفتوحاً، اعرض جميع المدفوعات
            return Column(
              children: [
                Divider(
                  height: 1,
                  thickness: 1,
                  color:
                      isDark
                          ? AppColors.darkOutlineColor.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.15),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...sortedPayments.map((payment) {
                        final originalIndex = expense.payments.indexWhere(
                          (p) => p.id == payment.id,
                        );

                        return Container(
                          margin: EdgeInsets.only(bottom: 4.h),
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors:
                                  isDark
                                      ? [
                                        AppColors.darkSurfaceElevatedColor,
                                        AppColors.darkSurfaceElevatedColor
                                            .withOpacity(0.8),
                                      ]
                                      : [
                                        AppColors.primaryColor.withOpacity(
                                          0.08,
                                        ),
                                        AppColors.primaryColor.withOpacity(
                                          0.04,
                                        ),
                                      ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color:
                                  isDark
                                      ? AppColors.darkOutlineColor.withOpacity(
                                        0.3,
                                      )
                                      : AppColors.primaryColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 2.5.w,
                                height: 32.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryColor,
                                      AppColors.primaryColor.withOpacity(0.7),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(2.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryColor.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${payment.amount.round()}',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            height: 1,
                                            color:
                                                isDark
                                                    ? AppColors.darkPrimaryColor
                                                    : AppColors.primaryColor,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 1.5.h,
                                            right: 3.w,
                                          ),
                                          child: Text(
                                            'جنيه',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  isDark
                                                      ? Colors.grey[400]
                                                      : Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 9.sp,
                                          color:
                                              isDark
                                                  ? Colors.grey[500]
                                                  : Colors.grey[500],
                                        ),
                                        SizedBox(width: 3.w),
                                        Text(
                                          DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(payment.date),
                                          style: TextStyle(
                                            fontSize: 9.sp,
                                            color:
                                                isDark
                                                    ? Colors.grey[500]
                                                    : Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (originalIndex != -1) {
                                      _showDeletePaymentConfirmDialog(
                                        controller,
                                        index,
                                        originalIndex,
                                        payment.amount,
                                        expense.label,
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: Container(
                                    padding: EdgeInsets.all(6.w),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Icon(
                                      Icons.delete_outline,
                                      size: 14.sp,
                                      color: Colors.red[500],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color:
                      isDark
                          ? AppColors.darkOutlineColor.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.15),
                ),
              ],
            );
          }),

          // Input Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              gradient:
                  isDark
                      ? null
                      : LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.primaryColor.withOpacity(0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.r),
                bottomRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    focusNode: focusNode,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'أدخل مبلغ جديد',
                      hintStyle: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                      filled: true,
                      fillColor:
                          isDark
                              ? AppColors.darkSurfaceElevatedColor
                              : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                          color:
                              isDark
                                  ? AppColors.darkOutlineColor
                                  : Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                          color:
                              isDark
                                  ? AppColors.darkOutlineColor
                                  : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                          color:
                              isDark
                                  ? AppColors.darkPrimaryColor
                                  : AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      suffixText: 'جنيه',
                      suffixStyle: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color:
                          isDark ? AppColors.darkPrimaryColor : Colors.black87,
                    ),
                    onSubmitted: (value) {
                      final amount = double.tryParse(value) ?? 0.0;
                      if (amount > 0) {
                        controller.addPayment(index, amount);
                        textController.clear();
                        focusNode.unfocus();
                      }
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Material(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10.r),
                  elevation: 2,
                  shadowColor: AppColors.primaryColor.withOpacity(0.3),
                  child: InkWell(
                    onTap: () {
                      final value = textController.text;
                      final amount = double.tryParse(value) ?? 0.0;
                      if (amount > 0) {
                        controller.addPayment(index, amount);
                        textController.clear();
                        focusNode.unfocus();
                      } else {
                        focusNode.requestFocus();
                      }
                    },
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  void _showAddExpenseDialog(CycleExpensesController controller, bool isDark) {
    final nameController = TextEditingController();
    const IconData defaultIcon = Icons.receipt;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurfaceColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'إضافة مصروف جديد',
          style: TextStyle(
            color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
          ),
        ),
        content: TextField(
          controller: nameController,
          style: TextStyle(
            color: isDark ? AppColors.darkPrimaryColor : Colors.black87,
          ),
          decoration: InputDecoration(
            labelText: 'اسم المصروف',
            labelStyle: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            filled: true,
            fillColor:
                isDark ? AppColors.darkSurfaceElevatedColor : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkOutlineColor : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkOutlineColor : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color:
                    isDark
                        ? AppColors.darkPrimaryColor
                        : AppColors.primaryColor,
                width: 2,
              ),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                controller.addExpense(nameController.text, defaultIcon);
                Get.back();
              }
            },
            style: TextButton.styleFrom(
              backgroundColor:
                  isDark
                      ? AppColors.darkPrimaryColor.withOpacity(0.2)
                      : AppColors.primaryColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'إضافة',
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.darkPrimaryColor
                        : AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(
    CycleExpensesController controller,
    int index,
    String label,
  ) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurfaceColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'تأكيد الحذف',
          style: TextStyle(
            color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
          ),
        ),
        content: Text(
          'هل تريد حذف "$label"؟',
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // إغلاق الـ Dialog مباشرة
              controller.removeExpense(index); // تنفيذ الحذف في الخلفية
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showDeletePaymentConfirmDialog(
    CycleExpensesController controller,
    int expenseIndex,
    int paymentIndex,
    double amount,
    String expenseName,
  ) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurfaceColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'تأكيد الحذف',
          style: TextStyle(
            color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
          ),
        ),
        content: Text(
          'هل تريد حذف دفعة بقيمة ${amount.round()} جنيه من "$expenseName"؟',
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // إغلاق الـ Dialog مباشرة
              controller.removePayment(
                expenseIndex,
                paymentIndex,
              ); // تنفيذ الحذف في الخلفية
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
