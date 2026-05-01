import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/strings/app_strings.dart';
import '../../../logic/controller/cycle_expenses_controller.dart';

void showAddExpenseDialog(CycleExpensesController controller) {
  final colorScheme = Theme.of(Get.context!).colorScheme;
  final nameController = TextEditingController();
  const IconData defaultIcon = Icons.receipt;

  Get.dialog<void>(
    AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      title: Text(
        'إضافة مصروف جديد',
        style: TextStyle(color: colorScheme.primary),
      ),
      content: TextField(
        controller: nameController,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: 'اسم المصروف',
          labelStyle: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          filled: true,
          fillColor: colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2,
            ),
          ),
        ),
        autofocus: true,
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
            if (nameController.text.isNotEmpty) {
              controller.addExpense(nameController.text, defaultIcon);
              Get.back<void>();
            }
          },
          style: TextButton.styleFrom(
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            'إضافة',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
