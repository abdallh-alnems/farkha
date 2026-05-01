import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constant/strings/app_strings.dart';
import '../../../logic/controller/cycle_expenses_controller.dart';

class ExpenseCard extends StatefulWidget {
  final int index;
  final ExpenseItem expense;
  final bool isViewer;

  const ExpenseCard({
    super.key,
    required this.index,
    required this.expense,
    this.isViewer = false,
  });

  @override
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  final _isHistoryExpanded = false.obs;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final expense = widget.expense;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.15),
        ),
        boxShadow:
            isDark
                ? []
                : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark, expense),
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          _buildPaymentSection(isDark, expense),
          if (!widget.isViewer) _buildInputSection(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, ExpenseItem expense) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient:
            isDark
                ? null
                : LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.03),
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
                colors: [
                  colorScheme.primary.withValues(alpha: 0.15),
                  colorScheme.primary.withValues(alpha: 0.08),
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
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
            ),
            child: Icon(
              expense.icon,
              color: colorScheme.primary,
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
                    color: colorScheme.primary,
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
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Text(
                              'المجموع: ${total.round()} جنيه',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
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
                        _isHistoryExpanded.value =
                            !_isHistoryExpanded.value;
                      },
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color:
                              _isHistoryExpanded.value
                                  ? colorScheme.primary.withValues(alpha: 0.3)
                                  : colorScheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          _isHistoryExpanded.value
                              ? Icons.expand_less_rounded
                              : Icons.history_rounded,
                          size: 14.sp,
                          color: colorScheme.primary,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (hasMultiplePayments) SizedBox(width: 5.w),
                if (!widget.isViewer)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _showDeleteConfirmDialog(expense.label);
                      },
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: colorScheme.error,
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
    );
  }

  Widget _buildPaymentSection(bool isDark, ExpenseItem expense) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      if (expense.payments.isEmpty) {
        return const SizedBox.shrink();
      }

      final sortedPayments = List<ExpensePayment>.from(expense.payments)
        ..sort((a, b) => b.date.compareTo(a.date));

      if (!_isHistoryExpanded.value) {
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
                        colorScheme.surfaceContainerHighest,
                        colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.8,
                        ),
                      ]
                      : [
                        colorScheme.primary.withValues(alpha: 0.08),
                        colorScheme.primary.withValues(alpha: 0.04),
                      ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color:
                  isDark
                      ? colorScheme.outline.withValues(alpha: 0.3)
                      : colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              _buildSideBar(colorScheme),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAmountRow(lastPayment.amount, isDark),
                    SizedBox(height: 2.h),
                    _buildDateRow(lastPayment.date),
                  ],
                ),
              ),
              if (!widget.isViewer)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (lastPaymentIndex != -1) {
                        _showDeletePaymentConfirmDialog(
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
                        color: colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 14.sp,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
                                  colorScheme.surfaceContainerHighest,
                                  colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.8),
                                ]
                                : [
                                  colorScheme.primary.withValues(alpha: 0.08),
                                  colorScheme.primary.withValues(alpha: 0.04),
                                ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color:
                            isDark
                                ? colorScheme.outline.withValues(alpha: 0.3)
                                : colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildSideBar(colorScheme),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAmountRow(payment.amount, isDark),
                              SizedBox(height: 2.h),
                              _buildDateRow(payment.date),
                            ],
                          ),
                        ),
                        if (!widget.isViewer)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (originalIndex != -1) {
                                  _showDeletePaymentConfirmDialog(
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
                                  color: colorScheme.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  size: 14.sp,
                                  color: colorScheme.error,
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
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ],
      );
    });
  }

  Widget _buildInputSection(bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.find<CycleExpensesController>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        gradient:
            isDark
                ? null
                : LinearGradient(
                  colors: [
                    Colors.transparent,
                    colorScheme.primary.withValues(alpha: 0.02),
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
              controller: _textController,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'أدخل مبلغ جديد',
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
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
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
              onSubmitted: (value) {
                final amount = double.tryParse(value) ?? 0.0;
                if (amount > 0) {
                  controller.addPayment(widget.index, amount);
                  _textController.clear();
                  _focusNode.unfocus();
                }
              },
            ),
          ),
          SizedBox(width: 8.w),
          Material(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(10.r),
            elevation: 2,
            shadowColor: colorScheme.primary.withValues(alpha: 0.3),
            child: InkWell(
              onTap: () {
                final value = _textController.text;
                final amount = double.tryParse(value) ?? 0.0;
                if (amount > 0) {
                  controller.addPayment(widget.index, amount);
                  _textController.clear();
                  _focusNode.unfocus();
                } else {
                  _focusNode.requestFocus();
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
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: colorScheme.onPrimary,
                  size: 22.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideBar(ColorScheme colorScheme) {
    return Container(
      width: 2.5.w,
      height: 32.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(2.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(double amount, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${amount.round()}',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            height: 1,
            color: colorScheme.primary,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 1.5.h, right: 3.w),
          child: Text(
            'جنيه',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow(DateTime date) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 9.sp, color: colorScheme.onSurface.withValues(alpha: 0.5)),
        SizedBox(width: 3.w),
        Text(
          DateFormat('yyyy-MM-dd').format(date),
          style: TextStyle(fontSize: 9.sp, color: colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  void _showDeleteConfirmDialog(String label) {
    final colorScheme = Theme.of(context).colorScheme;

    Get.dialog<void>(
      AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          AppStrings.confirmDelete,
          style: TextStyle(
            color: colorScheme.primary,
          ),
        ),
        content: Text(
          'هل تريد حذف "$label"؟',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back<void>();
              final controller = Get.find<CycleExpensesController>();
              controller.removeExpense(widget.index);
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error,
              backgroundColor: colorScheme.error.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _showDeletePaymentConfirmDialog(
    int paymentIndex,
    double amount,
    String expenseName,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    Get.dialog<void>(
      AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          AppStrings.confirmDelete,
          style: TextStyle(
            color: colorScheme.primary,
          ),
        ),
        content: Text(
          'هل تريد حذف دفعة بقيمة ${amount.round()} جنيه من "$expenseName"؟',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back<void>();
              final controller = Get.find<CycleExpensesController>();
              controller.removePayment(widget.index, paymentIndex);
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error,
              backgroundColor: colorScheme.error.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
