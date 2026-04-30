import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/constant/strings/app_strings.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/services/excel/excel_export_service.dart';
import '../../../core/services/pdf/pdf_export_service.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../cycle/add_member_dialog.dart';
import '../cycle/weekly_report_bottom_sheet.dart';

class CycleCardPopupMenu extends StatelessWidget {
  const CycleCardPopupMenu({
    super.key,
    required this.cycle,
    required this.cycleIndex,
    required this.isDark,
    required this.ageText,
  });

  final Map<String, dynamic> cycle;
  final int cycleIndex;
  final bool isDark;
  final String ageText;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceColor : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.grey[300]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.menu,
          color: isDark ? Colors.white : AppColors.primaryColor,
          size: 20.sp,
        ),
      ),
      color: isDark ? AppColors.darkSurfaceColor : AppColors.lightSurfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onSelected: _onMenuSelected,
      itemBuilder: (context) => _buildMenuItems(context),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return [
      PopupMenuItem<String>(
        value: 'add_cycle',
        child: Text(
          'اضف دورة',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.primaryColor,
          ),
        ),
      ),
      PopupMenuItem<String>(
        value: 'history',
        child: Text(
          'السجل',
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      PopupMenuItem<String>(
        value: 'weeklyReport',
        child: Text(
          'تقرير أسبوعي',
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'cycleData',
        child: Text(
          'بيانات الدورة',
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      PopupMenuItem<String>(
        value: 'edit',
        child: Text(
          'تعديل',
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      PopupMenuItem<String>(
        value: 'share',
        child: Text(
          'مشاركة',
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      PopupMenuItem<String>(
        value: 'permissions',
        child: Text(
          'صلاحيات',
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      PopupMenuItem<String>(
        value: 'delete',
        child: Text(
          cycle['role'] == 'owner' ? AppStrings.delete : 'مغادرة الدورة',
          style: TextStyle(
            fontSize: 14.sp,
            color: colorScheme.error,
          ),
        ),
      ),
    ];
  }

  Future<void> _onMenuSelected(String value) async {
    if (value == 'add_cycle') {
      unawaited(Get.toNamed<void>(AppRoute.addCycle));
    } else if (value == 'cycleData') {
      showCycleDataDialog(cycle, isDark);
    } else if (value == 'edit') {
      final cycleCtrl = Get.isRegistered<CycleController>()
          ? Get.find<CycleController>()
          : Get.put(CycleController());
      final idx = cycleCtrl.cycles.indexWhere(
        (c) => c['name'] == cycle['name'],
      );
      if (idx != -1) {
        cycleCtrl.prepareForEdit(cycle, idx);
        unawaited(Get.toNamed<void>(AppRoute.addCycle));
      }
    } else if (value == 'share') {
      final choice = await showCycleShareDialog(isDark);
      if (choice != null) {
        await handleCycleShare(choice, cycle, ageText);
      }
    } else if (value == 'weeklyReport') {
      final cycleCtrl = Get.isRegistered<CycleController>()
          ? Get.find<CycleController>()
          : Get.put(CycleController());
      cycleCtrl.currentCycle.assignAll(cycle);
      unawaited(WeeklyReportBottomSheet.show(Get.context!, cycle));
    } else if (value == 'history') {
      await Get.toNamed<void>(AppRoute.history);
    } else if (value == 'permissions') {
      final cycleId =
          int.tryParse(cycle['cycle_id']?.toString() ?? '0') ?? 0;
      if (cycleId > 0) {
        showMemberManagementDialog(cycleId, isDark);
      }
    } else if (value == 'delete') {
      if (cycle['role'] == 'owner') {
        await showDeleteDialog(cycle, isDark);
      } else {
        await showLeaveDialog(cycle, isDark);
      }
    }
  }
}

Future<String?> showCycleShareDialog(bool isDark) async {
  final bgColor =
      isDark ? AppColors.darkSurfaceColor : AppColors.lightSurfaceColor;
  final textColor = isDark ? Colors.white : Colors.black87;
  return Get.dialog<String>(
    AlertDialog(
      backgroundColor: bgColor,
      title: Text(
        'مشاركة الدورة',
        style: TextStyle(color: textColor),
        textAlign: TextAlign.right,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.text_snippet_outlined, color: textColor),
            title:
                Text('مشاركة كبيانات نصية', style: TextStyle(color: textColor)),
            onTap: () => Get.back(result: 'text'),
          ),
          ListTile(
            leading: Icon(Icons.picture_as_pdf_outlined, color: textColor),
            title: Text('مشاركة كملف PDF', style: TextStyle(color: textColor)),
            onTap: () => Get.back(result: 'pdf'),
          ),
          ListTile(
            leading: Icon(Icons.table_chart_outlined, color: textColor),
            title: Text('مشاركة كملف Excel', style: TextStyle(color: textColor)),
            onTap: () => Get.back(result: 'excel'),
          ),
        ],
      ),
    ),
  );
}

String buildCycleShareText(Map<String, dynamic> cycle, String ageText) {
  final name = cycle['name']?.toString() ?? 'دورة';
  final startDate = cycle['startDate']?.toString() ?? '-';
  final breed = cycle['breed']?.toString() ?? '-';
  final systemType = cycle['systemType']?.toString() ?? 'أرضي';
  final space = cycle['space']?.toString() ?? '-';
  final chickCount = int.tryParse(
        cycle['chickCount']?.toString() ??
            cycle['chick_count']?.toString() ??
            '0',
      ) ??
      0;
  final mortality =
      int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
  final mortalityRate = cycle['mortality_rate']?.toString() ?? '0.0';
  final liveCount = chickCount - mortality;
  final totalFeed =
      double.tryParse(cycle['total_feed']?.toString() ?? '0') ?? 0.0;
  final averageWeight =
      double.tryParse(cycle['average_weight']?.toString() ?? '0') ?? 0.0;
  final fcr = cycle['fcr']?.toString() ?? '0.0';
  final costPerBird = cycle['cost_per_bird']?.toString() ?? '0.00';
  final totalExpenses =
      double.tryParse(cycle['total_expenses']?.toString() ?? '0') ?? 0.0;
  final totalSales =
      double.tryParse(cycle['total_sales']?.toString() ?? '0') ?? 0.0;
  final netProfit =
      double.tryParse(cycle['net_profit']?.toString() ?? '0') ?? 0.0;
  final cycleAge = cycle['cycle_age']?.toString() ?? ageText;
  return '''
🐔 ملخص دورة: $name
━━━━━━━━━━━━━━━━━━━━
📋 معلومات الدورة
📅 تاريخ البدء: $startDate
⏳ عمر الدورة: $cycleAge يوم
🌾 السلالة: $breed
🏠 نظام التربية: $systemType
📐 المساحة: $space م²

━━━━━━━━━━━━━━━━━━━━
🐣 الطيور
   العدد الأولي: $chickCount طير
   المتبقي:      $liveCount طير
   النافق:       $mortality ($mortalityRate%)

━━━━━━━━━━━━━━━━━━━━
📊 الأداء الإنتاجي
   متوسط الوزن:    ${averageWeight.toStringAsFixed(2)} كجم
   معامل التحويل:  $fcr
   تكلفة الفرخ:   $costPerBird ج
   إجمالي العلف:  ${totalFeed.toStringAsFixed(0)} كجم

━━━━━━━━━━━━━━━━━━━━
💰 المالية
   المصروفات: ${totalExpenses.toStringAsFixed(0)} ج
   المبيعات:  ${totalSales.toStringAsFixed(0)} ج
   الصافي:    ${netProfit >= 0 ? '+' : ''}${netProfit.toStringAsFixed(0)} ج
''';
}

Future<void> handleCycleShare(
  String choice,
  Map<String, dynamic> cycle,
  String ageText,
) async {
  if (choice == 'text') {
    final name = cycle['name']?.toString() ?? 'دورة';
    final text = buildCycleShareText(cycle, ageText);
    unawaited(
      SharePlus.instance
          .share(ShareParams(text: text, subject: 'ملخص دورة: $name')),
    );
  } else if (choice == 'pdf') {
    try {
      await PdfExportService.exportCycleReport(cycle);
    } catch (e) {
      Get.snackbar(
        AppStrings.exportError,
        AppStrings.exportPdfErrorMsg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  } else if (choice == 'excel') {
    try {
      await ExcelExportService.exportCycleReport(cycle);
    } catch (e) {
      Get.snackbar(
        AppStrings.exportError,
        AppStrings.exportExcelError,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

void showCycleDataDialog(Map<String, dynamic> cycle, bool isDark) {
  Get.dialog<void>(
    AlertDialog(
      backgroundColor:
          isDark ? AppColors.darkSurfaceColor : AppColors.lightSurfaceColor,
      title: Text(
        'بيانات الدورة',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDialogRow('الاسم', (cycle['name'] ?? '-').toString(), isDark),
          SizedBox(height: 9.h),
          _buildDialogRow('نوع الدورة', 'تسمين', isDark),
          SizedBox(height: 9.h),
          _buildDialogRow(
            'عدد الفراخ',
            (cycle['chickCount'] ?? cycle['chick_count'] ?? '-')
                .toString(),
            isDark,
          ),
          SizedBox(height: 9.h),
          _buildDialogRow(
            'المساحة',
            cycle['space'] != null &&
                    cycle['space'] != '0' &&
                    cycle['space'] != '-'
                ? '${cycle['space']} م²'
                : '-',
            isDark,
          ),
          SizedBox(height: 9.h),
          _buildDialogRow('نظام التربية', 'ارضي', isDark),
          SizedBox(height: 9.h),
          _buildDialogRow(
            'تاريخ البدء',
            (cycle['startDate'] ?? '-').toString(),
            isDark,
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

Widget _buildDialogRow(String label, String value, bool isDark) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$label : ',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white : Colors.black87,
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
          color: isDark ? Colors.white : Colors.black87,
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
              color: isDark ? Colors.white70 : Colors.black54,
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
          color: isDark ? Colors.white : Colors.black87,
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
              color: isDark ? Colors.white70 : Colors.black54,
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
