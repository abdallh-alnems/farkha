import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/functions/number_format.dart';
import '../../../core/shared/formatters/arabic_to_english_digits_formatter.dart';
import '../../../logic/controller/cycle_expenses_controller.dart';
import 'expense/expense_dialogs.dart';
import 'expense/expense_history_list.dart';

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
        boxShadow: isDark
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
        gradient: isDark
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
              boxShadow: isDark
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
                          color: _isHistoryExpanded.value
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
                        showDeleteExpenseDialog(
                          context,
                          expense.label,
                          widget.index,
                        );
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
    return Obx(() {
      if (expense.payments.isEmpty) return const SizedBox.shrink();

      final sortedPayments = List<ExpensePayment>.from(expense.payments)
        ..sort((a, b) => b.date.compareTo(a.date));

      if (!_isHistoryExpanded.value) {
        final lastPayment = sortedPayments.first;
        final lastPaymentIndex = expense.payments.indexWhere(
          (p) => p.id == lastPayment.id,
        );
        return Container(
          margin: EdgeInsets.all(12.w),
          child: ExpensePaymentItem(
            payment: lastPayment,
            isDark: isDark,
            showDelete: !widget.isViewer && lastPaymentIndex != -1,
            onDelete: lastPaymentIndex != -1
                ? () => showDeletePaymentDialog(
                      context,
                      lastPaymentIndex,
                      lastPayment.amount,
                      expense.label,
                      widget.index,
                    )
                : null,
          ),
        );
      }

      return ExpenseHistoryList(
        sortedPayments: sortedPayments,
        originalPayments: expense.payments,
        isDark: isDark,
        isViewer: widget.isViewer,
        onDeletePayment: (originalIndex) => showDeletePaymentDialog(
          context,
          originalIndex,
          expense.payments[originalIndex].amount,
          expense.label,
          widget.index,
        ),
      );
    });
  }

  Widget _buildInputSection(bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.find<CycleExpensesController>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        gradient: isDark
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
              inputFormatters: [ArabicToEnglishDigitsFormatter()],
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
                final amount = tryParseNum(value) ?? 0.0;
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
                final amount = tryParseNum(value) ?? 0.0;
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
}
