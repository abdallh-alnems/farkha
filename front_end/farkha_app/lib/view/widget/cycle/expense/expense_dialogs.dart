import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constant/strings/app_strings.dart';
import '../../../../logic/controller/cycle_expenses_controller.dart';

void showDeleteExpenseDialog(
  BuildContext context,
  String label,
  int expenseIndex,
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
        style: TextStyle(color: colorScheme.primary),
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
            controller.removeExpense(expenseIndex);
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

void showDeletePaymentDialog(
  BuildContext context,
  int paymentIndex,
  double amount,
  String expenseName,
  int expenseIndex,
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
        style: TextStyle(color: colorScheme.primary),
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
            controller.removePayment(expenseIndex, paymentIndex);
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
