import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constant/strings/app_strings.dart';
import '../../../../logic/controller/cycle_custom_data_controller.dart';

void showAddDataDialog() {
  final customDataCtrl = Get.find<CycleCustomDataController>();
  Get.dialog<void>(
    Builder(builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final nameController = TextEditingController();

      return AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.add_rounded,
                color: colorScheme.primary,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'بطاقة بيانات جديدة',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: nameController,
          style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: 'اسم البطاقة',
            labelStyle: TextStyle(
              fontSize: 12.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor:
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          Material(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(8.r),
            child: InkWell(
              onTap: () {
                if (nameController.text.isNotEmpty) {
                  customDataCtrl.addCustomDataItem(
                    nameController.text,
                    Icons.note,
                  );
                  Get.back<void>();
                }
              },
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Text(
                  'إضافة',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }),
  );
}

void showDeleteCustomDataConfirmDialog(
  BuildContext context,
  int index,
  String label,
) {
  final colorScheme = Theme.of(context).colorScheme;
  final customDataCtrl = Get.find<CycleCustomDataController>();

  Get.dialog<void>(
    AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Text(
        AppStrings.confirmDelete,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      content: Text(
        'هل تريد حذف "$label"؟',
        style: TextStyle(
          fontSize: 14.sp,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back<void>(),
          child: Text(
            AppStrings.cancel,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        Material(
          color: colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          child: InkWell(
            onTap: () {
              Get.back<void>();
              customDataCtrl.removeCustomDataItem(index);
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                AppStrings.delete,
                style: TextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

void showDeleteCustomEntryConfirmDialog(
  BuildContext context,
  int itemIndex,
  int entryIndex,
  String entryText,
  String itemLabel,
) {
  final colorScheme = Theme.of(context).colorScheme;
  final customDataCtrl = Get.find<CycleCustomDataController>();

  Get.dialog<void>(
    AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Text(
        AppStrings.confirmDelete,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      content: Text(
        'هل تريد حذف "$entryText" من "$itemLabel"؟',
        style: TextStyle(
          fontSize: 14.sp,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back<void>(),
          child: Text(
            AppStrings.cancel,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        Material(
          color: colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          child: InkWell(
            onTap: () {
              Get.back<void>();
              customDataCtrl.removeEntry(itemIndex, entryIndex);
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                AppStrings.delete,
                style: TextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
