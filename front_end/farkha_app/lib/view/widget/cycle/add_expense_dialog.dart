import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/strings/app_strings.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_expenses_controller.dart';

void showAddExpenseDialog(CycleExpensesController controller, bool isDark) {
  final nameController = TextEditingController();
  const IconData defaultIcon = Icons.receipt;

  Get.dialog<void>(
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
          onPressed: () => Get.back<void>(),
          child: Text(
            AppStrings.cancel,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
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
            backgroundColor:
                isDark
                    ? AppColors.darkPrimaryColor.withValues(alpha: 0.2)
                    : AppColors.primaryColor.withValues(alpha: 0.1),
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
