import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/colors.dart';
import '../cycle/add_member_dialog.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../core/services/excel/excel_export_service.dart';
import '../../../core/services/pdf/pdf_export_service.dart';
import '../cycle/weekly_report_bottom_sheet.dart';

class AppBarCycle extends StatelessWidget implements PreferredSizeWidget {
 const AppBarCycle({super.key});

 @override
 Widget build(BuildContext context) {
   final controller = Get.find<CycleController>();
   return Obx(() {
     final name = (controller.currentCycle['name'] ?? 'خطا').toString();
     final theme = Theme.of(context);
     final colorScheme = theme.colorScheme;
     final Color background = colorScheme.surface;
     final Color onBackground = colorScheme.onSurface;
     return Stack(
       children: [
         AppBar(
           backgroundColor: background,
           surfaceTintColor: background,
           leading: _icon(
             context,
             Icons.arrow_back_ios_new_rounded,
             color: onBackground,
             onPressed: () => Get.back<void>(),
           ),
           title: Center(
             child: Text(
               name,
               style: theme.textTheme.headlineLarge?.copyWith(
                 fontSize: 21.sp,
                 color: onBackground,
               ),
             ),
           ),
           actions: [
             // زر إنهاء الدورة - يظهر فقط إذا لم تكن الدورة منتهية ولا يكون المستخدم مراقباً
             if (!controller.isCycleEnded(controller.currentCycle) &&
                 controller.currentCycle['role'] != 'viewer') ...[
               Center(
                 child: Container(
                   margin: EdgeInsets.symmetric(horizontal: 4.w),
                   padding: EdgeInsets.symmetric(
                     horizontal: 8.w,
                     vertical: 4.h,
                   ),
                   decoration: BoxDecoration(
                     color: AppColors.sunsetGradientStart.withValues(
                       alpha: 0.1,
                     ),
                     border: Border.all(
                       color: AppColors.sunsetGradientStart.withValues(
                         alpha: 0.5,
                       ),
                     ),
                     borderRadius: BorderRadius.circular(12.r),
                   ),
                   child: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Icon(
                         Icons.science_outlined,
                         size: 14.sp,
                       ),
                       SizedBox(width: 4.w),
                       Text(
                         'ميزة تجريبية',
                         style: TextStyle(
                           fontSize: 10.sp,
                           color: AppColors.sunsetGradientStart,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
               IconButton(
                 onPressed: () async {
                   // التحقق من أن الدورة لم تنتهِ بعد
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
                       title: Text(
                         'إنهاء الدورة',
                         style: TextStyle(color: onBackground),
                       ),
                       content: Text(
                         'هل تريد إنهاء دورة "${controller.currentCycle['name']}"؟',
                         textAlign: TextAlign.right,
                         style: TextStyle(color: onBackground),
                       ),
                       actionsAlignment: MainAxisAlignment.end,
                       actions: [
                         TextButton(
                           onPressed: () => Get.back(result: false),
                           child: Text(
                             'إلغاء',
                             style: TextStyle(color: onBackground),
                           ),
                         ),
                         TextButton(
                           onPressed: () => Get.back(result: true),
                           child: Text(
                             'إنهاء',
                             style: TextStyle(color: Colors.green[700]),
                           ),
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
                 },
                 icon: Icon(
                   Icons.task_alt,
                   size: 23.sp,
                   color: Colors.green[700],
                 ),
                 tooltip: 'إنهاء الدورة',
               ),
             ],
             PopupMenuButton<String>(
               icon: Icon(Icons.more_vert, size: 23.sp, color: onBackground),
               onSelected: (value) async {
                 if (value == 'add_cycle') {
                   unawaited(Get.toNamed<void>(AppRoute.addCycle));
                 } else if (value == 'cycleData') {
                   // Show dialog with cycle data
                   final cycle = controller.currentCycle;
                   unawaited(
                     Get.dialog<void>(
                       AlertDialog(
                         backgroundColor: background,
                         title: Text(
                           'بيانات الدورة',
                           style: TextStyle(color: onBackground),
                         ),
                         content: Column(
                           mainAxisSize: MainAxisSize.min,
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               'الاسم : ${cycle['name'] ?? '-'}',
                               style: TextStyle(color: onBackground),
                             ),
                             const SizedBox(height: 9),
                             Text(
                               'نوع الدورة : تسمين',
                               style: TextStyle(color: onBackground),
                             ),
                             const SizedBox(height: 9),
                             Text(
                               'عدد الفراخ : ${cycle['chickCount']}',
                               style: TextStyle(color: onBackground),
                             ),
                             const SizedBox(height: 9),
                             Text(
                               'المساحة : ${cycle['space']}',
                               style: TextStyle(color: onBackground),
                             ),
                             const SizedBox(height: 9),
                             Text(
                               'نظام التربية : ارضي',
                               style: TextStyle(color: onBackground),
                             ),
                             const SizedBox(height: 9),
                             Text(
                               'تاريخ البدء : ${cycle['startDate']}',
                               style: TextStyle(color: onBackground),
                             ),
                           ],
                         ),
                         actions: [
                           TextButton(
                             onPressed: () => Get.back<void>(),
                             child: Text(
                               'حسناً',
                               style: TextStyle(color: onBackground),
                             ),
                           ),
                           TextButton(
                             onPressed: () {
                               final data = controller.currentCycle;
                               final idx = controller.cycles.indexWhere(
                                 (c) => c['name'] == data['name'],
                               );
                               controller.prepareForEdit(data, idx);
                               Get.back<void>(); // Close dialog first
                               unawaited(Get.toNamed<void>(AppRoute.addCycle));
                             },
                             child: Text(
                               'تعديل',
                               style: TextStyle(color: onBackground),
                             ),
                           ),
                         ],
                       ),
                     ),
                   );
                 } else if (value == 'edit') {
                   final data = controller.currentCycle;
                   final idx = controller.cycles.indexWhere(
                     (c) => c['name'] == data['name'],
                   );
                   controller.prepareForEdit(data, idx);
                   unawaited(Get.toNamed<void>(AppRoute.addCycle));
                 } else if (value == 'delete') {
                   if (controller.currentCycle['role'] == 'owner') {
                     final confirmed = await Get.dialog<bool>(
                       AlertDialog(
                         backgroundColor: background,
                         content: Text(
                           'هل تريد حذف دورة ${controller.currentCycle['name']}؟',
                           textAlign: TextAlign.right,
                           style: TextStyle(color: onBackground),
                         ),
                         actionsAlignment: MainAxisAlignment.end,
                         actions: [
                           TextButton(
                             onPressed: () => Get.back(result: false),
                             child: Text(
                               'لا',
                               style: TextStyle(color: onBackground),
                             ),
                           ),
                           TextButton(
                             onPressed: () {
                               Get.back(
                                 result: true,
                               ); // إغلاق الـ Dialog مباشرة
                               controller
                                   .deleteCurrentCycle(); // تنفيذ الحذف في الخلفية
                             },
                             child: Text(
                               'نعم',
                               style: TextStyle(color: colorScheme.error),
                             ),
                           ),
                         ],
                       ),
                     );
                     // بعد الحذف، التحقق من أن القائمة أصبحت فارغة
                     if (confirmed == true) {
                       // التحقق من أن الحذف اكتمل (سيتم التعامل معه في Obx)
                     }
                   } else {
                     await Get.dialog<bool>(
                       AlertDialog(
                         backgroundColor: background,
                         content: Text(
                           'هل تريد مغادرة دورة ${controller.currentCycle['name']}؟',
                           textAlign: TextAlign.right,
                           style: TextStyle(color: onBackground),
                         ),
                         actionsAlignment: MainAxisAlignment.end,
                         actions: [
                           TextButton(
                             onPressed: () => Get.back(result: false),
                             child: Text(
                               'لا',
                               style: TextStyle(color: onBackground),
                             ),
                           ),
                           TextButton(
                             onPressed: () {
                               Get.back(result: true);
                               controller.leaveCycle();
                             },
                             child: Text(
                               'نعم',
                               style: TextStyle(color: colorScheme.error),
                             ),
                           ),
                         ],
                       ),
                     );
                   }
                 } else if (value == 'share') {
                   final cycle = controller.currentCycle;
                   final choice = await Get.dialog<String>(
                     AlertDialog(
                       backgroundColor: background,
                       title: Text(
                         'مشاركة الدورة',
                         style: TextStyle(color: onBackground),
                         textAlign: TextAlign.right,
                       ),
                       content: Column(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           ListTile(
                             leading: const Icon(Icons.text_snippet_outlined),
                             title: Text('مشاركة كبيانات نصية',
                                 style: TextStyle(color: onBackground)),
                             onTap: () => Get.back(result: 'text'),
                           ),
                            ListTile(
                              leading: const Icon(Icons.picture_as_pdf_outlined),
                              title: Text('مشاركة كملف PDF',
                                  style: TextStyle(color: onBackground)),
                              onTap: () => Get.back(result: 'pdf'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.table_chart_outlined),
                              title: Text('مشاركة كملف Excel',
                                  style: TextStyle(color: onBackground)),
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
                        Get.snackbar(
                          'خطأ في التصدير',
                          'حدث خطأ غير متوقع، ربما تحتاج لإعادة فتح التطبيق ليتم تفعيل ميزة الطباعة.',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    } else if (choice == 'excel') {
                      try {
                        await ExcelExportService.exportCycleReport(cycle);
                      } catch (e) {
                        Get.snackbar(
                          'خطأ في التصدير',
                          'حدث خطأ أثناء تصدير ملف Excel.',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    }
                  } else if (value == 'weeklyReport') {
                    unawaited(
                      WeeklyReportBottomSheet.show(context, controller.currentCycle),
                    );
                  } else if (value == 'history') {
                    unawaited(Get.toNamed<void>(AppRoute.history));
                  } else if (value == 'permissions') {
                   final rawId = controller.currentCycle['cycle_id'];
                   final cycleId =
                       rawId is int
                           ? rawId
                           : int.tryParse(rawId?.toString() ?? '0') ?? 0;
                   _showMemberManagementDialog(
                     context,
                     cycleId,
                     theme.brightness == Brightness.dark,
                   );
                 }
               },
               itemBuilder: (_) => [
                 PopupMenuItem<String>(
                   value: 'add_cycle',
                   child: Text(
                     'اضف دورة',
                     style: TextStyle(
                       fontSize: 14.sp,
                       fontWeight: FontWeight.w600,
                       color: theme.brightness == Brightness.dark
                           ? Colors.white
                           : AppColors.primaryColor,
                     ),
                   ),
                 ),
                   _menuItem(context, 'history', 'السجل'),
                   const PopupMenuDivider(),
                  _menuItem(context, 'weeklyReport', 'تقرير أسبوعي'),
                  _menuItem(context, 'cycleData', 'بيانات الدورة'),
                 if (controller.currentCycle['role'] != 'viewer')
                   _menuItem(context, 'edit', 'تعديل'),
                 _menuItem(context, 'share', 'مشاركة'),
                 _menuItem(context, 'permissions', 'صلاحيات'),
                 if (controller.currentCycle['role'] == 'owner')
                   _menuItem(
                     context,
                     'delete',
                     'حذف',
                     color: colorScheme.error,
                   )
                 else
                   _menuItem(
                     context,
                     'delete',
                     'مغادرة الدورة',
                     color: colorScheme.error,
                   ),
               ],
             ),
             SizedBox(width: 11.w),
           ],
         ),
         Obx(() {
           final deleteStatus = controller.cycleDeleteStatus.value;

           // إظهار حالة التحميل للحذف فقط
           if (deleteStatus == StatusRequest.loading ||
               deleteStatus == StatusRequest.serverFailure ||
               deleteStatus == StatusRequest.offlineFailure ||
               deleteStatus == StatusRequest.failure) {
             return Positioned.fill(
               child: IgnorePointer(
                 ignoring: deleteStatus != StatusRequest.loading,
                 child: Container(
                   color: background.withValues(alpha: 0.8),
                   child: HandlingDataView(
                     statusRequest: deleteStatus,
                     widget: const SizedBox.shrink(),
                   ),
                 ),
               ),
             );
           }

           // التحقق من أن الحذف اكتمل بنجاح
           if (deleteStatus == StatusRequest.success) {
             // إغلاق الصفحة بعد قليل من نجاح الحذف
             Future.delayed(const Duration(milliseconds: 500), () {
               if (Get.isDialogOpen != true) {
                 final isEmpty = controller.cycles.isEmpty;
                 if (isEmpty) {
                   Get.back<
                     void
                   >(); // إغلاق صفحة cycle.dart إذا لم تكن هناك دورات
                 }
               }
               controller.cycleDeleteStatus.value = StatusRequest.none;
             });
           }

           return const SizedBox.shrink();
         }),
       ],
     );
   });
 }

 @override
 Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

Widget _icon(
 BuildContext context,
 IconData icon, {
 Color? color,
 VoidCallback? onPressed,
}) {
 final Color resolvedColor = color ?? Theme.of(context).colorScheme.onSurface;
 return IconButton(
   onPressed: onPressed,
   icon: Icon(icon, color: resolvedColor, size: 23.sp),
 );
}

void _showMemberManagementDialog(
 BuildContext context,
 int cycleId,
 bool isDark,
) {
 Get.dialog<void>(
   AddMemberDialog(cycleId: cycleId, isDark: isDark),
 );
}

PopupMenuItem<String> _menuItem(
  BuildContext context,
  String value,
  String text, {
  Color? color,
}) {
 return PopupMenuItem(
   value: value,
   child: Text(
     text,
     style: TextStyle(
       color: color ?? Theme.of(context).colorScheme.onSurface,
       fontSize: 14.sp,
     ),
   ),
 );
}
