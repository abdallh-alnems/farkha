import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/class/crud.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/constant/strings/app_strings.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/services/excel/excel_export_service.dart';
import '../../../core/services/pdf/pdf_export_service.dart';
import '../../../data/data_source/remote/cycle_feedback_data.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_feedback_controller.dart';
import '../cycle/weekly_report_bottom_sheet.dart';
import '../cycle_feedback/cycle_feedback_dialog.dart';
import 'cycle_card_dialogs.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      icon: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
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
    final bool isViewer = cycle['role'] == 'viewer';
    return [
      _menuHeader('إدارة الدورة'),
      _menuItem(context, 'add_cycle', Icons.add_circle_outline, 'اضف دورة'),
      _menuItem(context, 'history', Icons.history_rounded, 'السجل'),
      const PopupMenuDivider(height: 8),
      _menuHeader('التقارير'),
      _menuItem(context, 'weeklyReport', Icons.date_range_rounded, 'تقرير أسبوعي'),
      _menuItem(context, 'cycleData', Icons.info_outline_rounded, 'بيانات الدورة'),
      const PopupMenuDivider(height: 8),
      _menuHeader('إجراءات'),
      if (!isViewer)
        _menuItem(context, 'edit', Icons.edit_outlined, 'تعديل'),
      _menuItem(context, 'share', Icons.share_outlined, 'مشاركة'),
      if (!isViewer)
        _menuItem(context, 'permissions', Icons.group_outlined, 'صلاحيات'),
      _menuItem(context, 'rate', Icons.star_outline_rounded, 'تقييم الدورة'),
      _menuItem(
        context,
        'delete',
        cycle['role'] == 'owner'
            ? Icons.delete_outline_rounded
            : Icons.exit_to_app_rounded,
        cycle['role'] == 'owner' ? AppStrings.delete : 'مغادرة الدورة',
        color: colorScheme.error,
      ),
    ];
  }

  PopupMenuItem<String> _menuHeader(String title) {
    return PopupMenuItem<String>(
      enabled: false,
      height: 32.h,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
    BuildContext context,
    String value,
    IconData icon,
    String text, {
    Color? color,
  }) {
    return PopupMenuItem(
      value: value,
      height: 40.h,
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: color ?? Theme.of(context).colorScheme.onSurface),
          SizedBox(width: 10.w),
          Text(
            text,
            style: TextStyle(
              color: color ?? Theme.of(context).colorScheme.onSurface,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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
    } else if (value == 'rate') {
      _showCycleFeedback();
    } else if (value == 'delete') {
      if (cycle['role'] == 'owner') {
        await showDeleteDialog(cycle, isDark);
      } else {
        await showLeaveDialog(cycle, isDark);
      }
    }
  }

  void _showCycleFeedback() {
    _ensureFeedbackController();
    unawaited(Get.dialog<void>(const CycleFeedbackDialog()));
  }

  static CycleFeedbackController _ensureFeedbackController() {
    if (Get.isRegistered<CycleFeedbackController>()) {
      final ctrl = Get.find<CycleFeedbackController>();
      ctrl.rating = 0;
      ctrl.issueController.clear();
      ctrl.suggestionController.clear();
      ctrl.statusRequest = StatusRequest.none;
      ctrl.validationError = null;
      ctrl.update();
      return ctrl;
    }
    final crud = Get.find<Crud>();
    final data = CycleFeedbackData(crud);
    final ctrl = CycleFeedbackController(data);
    Get.put(ctrl);
    return ctrl;
  }
}

Future<String?> showCycleShareDialog(bool isDark) async {
  final bgColor =
      isDark ? AppColors.darkSurfaceColor : AppColors.lightSurfaceColor;
  final textColor = Get.theme.colorScheme.onSurface;
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
