import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/constant/strings/app_strings.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../core/services/excel/excel_export_service.dart';
import '../../../core/services/pdf/pdf_export_service.dart';

Widget _infoRow(String label, String value, Color onBackground) {
  return Padding(
    padding: EdgeInsets.only(bottom: 10.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(value, style: TextStyle(color: onBackground, fontWeight: FontWeight.w600, fontSize: 14.sp)),
        Text('$label :', style: TextStyle(color: onBackground, fontSize: 14.sp)),
      ],
    ),
  );
}

Future<void> showEndCycleDialog({
  required CycleController controller,
  required Color background,
  required Color onBackground,
  required bool isDark,
  required Color accentColor,
}) async {
  if (controller.isCycleEnded(controller.currentCycle)) {
    Get.snackbar(
      'تنبيه',
      'هذه الدورة منتهية بالفعل',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
    return;
  }

  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      backgroundColor: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      contentPadding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      actionsPadding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 12.h),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'تأكيد إنهاء الدورة',
            style: TextStyle(
              color: onBackground,
              fontWeight: FontWeight.w800,
              fontSize: 17.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColors.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.task_alt_rounded,
              color: AppColors.successColor,
              size: 18.sp,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'هل تريد إنهاء دورة "${controller.currentCycle['name']}"؟',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: onBackground,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.add_shopping_cart_rounded,
                  color: accentColor,
                  size: 28.sp,
                ),
                SizedBox(height: 8.h),
                Text(
                  'تأكد من إدخال جميع المبيعات قبل إنهاء الدورة لضمان دقة التقرير المالي',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: onBackground,
                    fontSize: 13.sp,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () {
                    Get.back(result: false);
                    unawaited(
                      Get.toNamed<void>(AppRoute.cycleSales),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          color: isDark
                              ? AppColors.darkBackGroundColor
                              : Colors.white,
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'الذهاب لصفحة المبيعات',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkBackGroundColor
                                : Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(
            AppStrings.cancel,
            style: TextStyle(
              color: onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.successColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 8.h,
            ),
            elevation: 0,
          ),
          icon: Icon(Icons.check_circle_outline, size: 16.sp),
          label: Text(
            'إنهاء الدورة',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
            ),
          ),
          onPressed: () => Get.back(result: true),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    final cycleData = Map<String, dynamic>.from(controller.currentCycle);
    unawaited(
      Get.toNamed<void>(
        AppRoute.cycleCloseoutReport,
        arguments: {'cycleData': cycleData},
      ),
    );
  }
}

void showCycleDataDialog({
  required CycleController controller,
  required Color background,
  required Color onBackground,
}) {
  final cycle = controller.currentCycle;
  unawaited(
    Get.dialog<void>(
      AlertDialog(
        backgroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 20.sp, color: onBackground),
            SizedBox(width: 8.w),
            Text('بيانات الدورة', style: TextStyle(color: onBackground, fontWeight: FontWeight.w800, fontSize: 16.sp)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('الاسم', (cycle['name'] ?? '-').toString(), onBackground),
            _infoRow('نوع الدورة', 'تسمين', onBackground),
            _infoRow('عدد الفراخ', '${cycle['chickCount']}', onBackground),
            _infoRow('المساحة', '${cycle['space']} م²', onBackground),
            _infoRow('نظام التربية', 'أرضي', onBackground),
            _infoRow('تاريخ البدء', '${cycle['startDate']}', onBackground),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text('حسناً', style: TextStyle(color: onBackground)),
          ),
          TextButton(
            onPressed: () {
              final data = controller.currentCycle;
              final idx = controller.cycles.indexWhere(
                (c) => c['name'] == data['name'],
              );
              controller.prepareForEdit(data, idx);
              Get.back<void>();
              unawaited(Get.toNamed<void>(AppRoute.addCycle));
            },
            child: Text('تعديل', style: TextStyle(color: onBackground)),
          ),
        ],
      ),
    ),
  );
}

Future<void> showDeleteConfirmDialog({
  required CycleController controller,
  required Color background,
  required Color onBackground,
  required Color errorColor,
}) async {
  final isOwner = controller.currentCycle['role'] == 'owner';
  await Get.dialog<bool>(
    AlertDialog(
      backgroundColor: background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      content: Text(
        isOwner
            ? 'هل تريد حذف دورة ${controller.currentCycle['name']}؟'
            : 'هل تريد مغادرة دورة ${controller.currentCycle['name']}؟',
        textAlign: TextAlign.right,
        style: TextStyle(color: onBackground),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text('لا', style: TextStyle(color: onBackground)),
        ),
        TextButton(
          onPressed: () {
            Get.back(result: true);
            if (isOwner) {
              controller.deleteCurrentCycle();
            } else {
              controller.leaveCycle();
            }
          },
          child: Text('نعم', style: TextStyle(color: errorColor)),
        ),
      ],
    ),
  );
}

Future<void> showShareDialog({
  required CycleController controller,
  required Color background,
  required Color onBackground,
}) async {
  final cycle = controller.currentCycle;
  final choice = await Get.dialog<String>(
    AlertDialog(
      backgroundColor: background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(
        'مشاركة الدورة',
        style: TextStyle(color: onBackground, fontWeight: FontWeight.w800),
        textAlign: TextAlign.right,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.text_snippet_outlined),
            title: Text('مشاركة كبيانات نصية', style: TextStyle(color: onBackground)),
            onTap: () => Get.back(result: 'text'),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text('مشاركة كملف PDF', style: TextStyle(color: onBackground)),
            onTap: () => Get.back(result: 'pdf'),
          ),
          ListTile(
            leading: const Icon(Icons.table_chart_outlined),
            title: Text('مشاركة كملف Excel', style: TextStyle(color: onBackground)),
            onTap: () => Get.back(result: 'excel'),
          ),
        ],
      ),
    ),
  );

  if (choice == 'text') {
    final name = cycle['name']?.toString() ?? 'دورة';
    final startDate = cycle['startDate']?.toString() ?? '-';
    final breed = cycle['breed']?.toString() ?? '-';
    final systemType = cycle['systemType']?.toString() ?? 'أرضي';
    final space = cycle['space']?.toString() ?? '-';
    final chickCount = int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0;
    final mortality = int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
    final mortalityRate = cycle['mortality_rate']?.toString() ?? '0.0';
    final liveCount = chickCount - mortality;
    final totalFeed = double.tryParse(cycle['total_feed']?.toString() ?? '0') ?? 0.0;
    final averageWeight = double.tryParse(cycle['average_weight']?.toString() ?? '0') ?? 0.0;
    final fcr = cycle['fcr']?.toString() ?? '0.0';
    final costPerBird = cycle['cost_per_bird']?.toString() ?? '0.00';
    final totalExpenses = double.tryParse(cycle['total_expenses']?.toString() ?? '0') ?? 0.0;
    final totalSales = double.tryParse(cycle['total_sales']?.toString() ?? '0') ?? 0.0;
    final netProfit = double.tryParse(cycle['net_profit']?.toString() ?? '0') ?? 0.0;
    final cycleAge = cycle['cycle_age']?.toString() ?? '0';
    final text = '''
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
    unawaited(SharePlus.instance.share(ShareParams(text: text, subject: 'ملخص دورة: $name')));
  } else if (choice == 'pdf') {
    try {
      await PdfExportService.exportCycleReport(cycle);
    } catch (e) {
      Get.snackbar(AppStrings.exportError, AppStrings.exportPdfErrorMsg, backgroundColor: Colors.red, colorText: Colors.white);
    }
  } else if (choice == 'excel') {
    try {
      await ExcelExportService.exportCycleReport(cycle);
    } catch (e) {
      Get.snackbar(AppStrings.exportError, AppStrings.exportExcelError, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
