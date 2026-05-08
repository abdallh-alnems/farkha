import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../cycle/add_member_dialog.dart';

void showCycleDataDialog(Map<String, dynamic> cycle, bool isDark) {
  final colorScheme = Get.theme.colorScheme;
  Get.dialog<void>(
    AlertDialog(
      backgroundColor:
          isDark ? AppColors.darkSurfaceColor : AppColors.lightSurfaceColor,
      title: Text(
        'بيانات الدورة',
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDialogRow('الاسم', (cycle['name'] ?? '-').toString(), colorScheme),
          SizedBox(height: 9.h),
          _buildDialogRow('نوع الدورة', 'تسمين', colorScheme),
          SizedBox(height: 9.h),
          _buildDialogRow(
            'عدد الفراخ',
            (cycle['chickCount'] ?? cycle['chick_count'] ?? '-')
                .toString(),
            colorScheme,
          ),
          SizedBox(height: 9.h),
          _buildDialogRow(
            'المساحة',
            cycle['space'] != null &&
                    cycle['space'] != '0' &&
                    cycle['space'] != '-'
                ? '${cycle['space']} م²'
                : '-',
            colorScheme,
          ),
          SizedBox(height: 9.h),
          _buildDialogRow('نظام التربية', 'ارضي', colorScheme),
          SizedBox(height: 9.h),
          _buildDialogRow(
            'تاريخ البدء',
            (cycle['startDate'] ?? '-').toString(),
            colorScheme,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back<void>(),
          child: Text(
            'حسناً',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkPrimaryColor
                  : AppColors.primaryColor,
              fontSize: 14.sp,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            final cycleCtrl = Get.isRegistered<CycleController>()
                ? Get.find<CycleController>()
                : Get.put(CycleController());
            final idx = cycleCtrl.cycles.indexWhere(
              (c) => c['name'] == cycle['name'],
            );
            if (idx != -1) {
              cycleCtrl.prepareForEdit(cycle, idx);
              Get.back<void>();
              Get.toNamed<void>(AppRoute.addCycle);
            }
          },
          child: Text(
            'تعديل',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkPrimaryColor
                  : AppColors.primaryColor,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDialogRow(String label, String value, ColorScheme colorScheme) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$label : ',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withValues(alpha: 0.55),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    ],
  );
}

Future<void> showDeleteDialog(
  Map<String, dynamic> cycle,
  bool isDark,
) async {
  final theme = Get.theme;
  final colorScheme = theme.colorScheme;

  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      backgroundColor:
          isDark ? AppColors.darkSurfaceColor : AppColors.lightSurfaceColor,
      content: Text(
        'هل تريد حذف دورة ${cycle['name']}؟',
        textAlign: TextAlign.right,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16.sp,
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(
            'لا',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.55),
              fontSize: 14.sp,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text(
            'نعم',
            style: TextStyle(color: colorScheme.error, fontSize: 14.sp),
          ),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    final cycleCtrl = Get.isRegistered<CycleController>()
        ? Get.find<CycleController>()
        : Get.put(CycleController());
    cycleCtrl.currentCycle.assignAll(cycle);
    await cycleCtrl.deleteCurrentCycle();
  }
}

Future<void> showLeaveDialog(
  Map<String, dynamic> cycle,
  bool isDark,
) async {
  final theme = Get.theme;
  final colorScheme = theme.colorScheme;

  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      backgroundColor:
          isDark ? AppColors.darkSurfaceColor : AppColors.lightSurfaceColor,
      content: Text(
        'هل تريد مغادرة دورة ${cycle['name']}؟',
        textAlign: TextAlign.right,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16.sp,
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(
            'لا',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.55),
              fontSize: 14.sp,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text(
            'نعم',
            style: TextStyle(color: colorScheme.error, fontSize: 14.sp),
          ),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    final cycleCtrl = Get.isRegistered<CycleController>()
        ? Get.find<CycleController>()
        : Get.put(CycleController());
    cycleCtrl.currentCycle.assignAll(cycle);
    await cycleCtrl.leaveCycle();
  }
}

void showMemberManagementDialog(int cycleId, bool isDark) {
  Get.dialog<void>(
    AddMemberDialog(cycleId: cycleId, isDark: isDark),
  );
}
