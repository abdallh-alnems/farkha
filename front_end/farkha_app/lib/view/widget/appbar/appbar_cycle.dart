import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/routes/route.dart';
import '../../../logic/controller/cycle_controller.dart';

class AppBarCycle extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCycle({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CycleController>();
    return Obx(() {
      final name = controller.currentCycle['name'] ?? 'خطا';
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
              onPressed: () => Get.back(),
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
              // زر إنهاء الدورة - يظهر فقط إذا لم تكن الدورة منتهية
              if (!controller.isCycleEnded(controller.currentCycle))
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
                      // تنفيذ إنهاء الدورة (سيتم التعامل مع التحميل في cycle.dart)
                      controller.endCurrentCycle();
                    }
                  },
                  icon: Icon(
                    Icons.task_alt,
                    size: 23.sp,
                    color: Colors.green[700],
                  ),
                  tooltip: 'إنهاء الدورة',
                ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 23.sp, color: onBackground),
                onSelected: (value) async {
                  if (value == 'cycleData') {
                    // Show dialog with cycle data
                    final cycle = controller.currentCycle;
                    Get.dialog(
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
                            onPressed: () => Get.back(),
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
                              Get.back(); // Close dialog first
                              Get.toNamed(AppRoute.addCycle);
                            },
                            child: Text(
                              'تعديل',
                              style: TextStyle(color: onBackground),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (value == 'edit') {
                    final data = controller.currentCycle;
                    final idx = controller.cycles.indexWhere(
                      (c) => c['name'] == data['name'],
                    );
                    controller.prepareForEdit(data, idx);
                    Get.toNamed(AppRoute.addCycle);
                  } else if (value == 'delete') {
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
                              Get.back(result: true); // إغلاق الـ Dialog مباشرة
                              controller.deleteCurrentCycle(); // تنفيذ الحذف في الخلفية
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
                  } else if (value == 'share') {
                    // share logic here
                  }
                },
                itemBuilder:
                    (_) => [
                      _menuItem(
                        context,
                        'cycleData',
                        'بيانات الدورة',
                        Icons.info_outline,
                      ),
                      _menuItem(
                        context,
                        'edit',
                        'تعديل',
                        Icons.edit_calendar_outlined,
                      ),
                      _menuItem(
                        context,
                        'delete',
                        'حذف',
                        Icons.delete,
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
                    color: background.withOpacity(0.8),
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
                    Get.back(); // إغلاق صفحة cycle.dart إذا لم تكن هناك دورات
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

PopupMenuItem<String> _menuItem(
  BuildContext context,
  String value,
  String text,
  IconData icon, {
  Color? color,
}) {
  return PopupMenuItem(value: value, child: Text(text));
}
