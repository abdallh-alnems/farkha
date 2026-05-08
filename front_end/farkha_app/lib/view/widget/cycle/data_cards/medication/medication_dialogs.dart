import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/constant/strings/app_strings.dart';
import '../../../../../data/model/cycle/medication_entry.dart';

void showDeleteMedicationDialog(
  BuildContext context,
  MedicationEntry entry,
  VoidCallback onConfirm,
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
        'هل تريد حذف ${entry.text} من قسم التحصينات؟',
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
            onConfirm();
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
