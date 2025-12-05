import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
      return AppBar(
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
          _icon(
            context,
            Icons.notifications_active,
            color: colorScheme.secondary,
          ),
          // Exclamation icon to show current cycle data
          _icon(
            context,
            Icons.error,
            color: onBackground,
            onPressed: () {
              // Show dialog with cycle data
              final cycle = controller.currentCycle;
              Get.dialog(
                AlertDialog(
                  title: const Text('بيانات الدورة'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الاسم : ${cycle['name'] ?? '-'}'),
                      const SizedBox(height: 9), // مسافة 8 logical pixels
                      const Text('نوع الدورة : تسمين'),
                      const SizedBox(height: 9),
                      Text('عدد الفراخ : ${cycle['chickCount']}'),
                      const SizedBox(height: 9),
                      Text('المساحة : ${cycle['space']}'),
                      const SizedBox(height: 9),
                      const Text('نظام التربية : ارضي'),
                      const SizedBox(height: 9),
                      Text('تاريخ البدء : ${cycle['startDate']}'),
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
                        Get.toNamed(AppRoute.addCycle);
                      },
                      child: Text(
                        'تعديل',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 23.sp, color: onBackground),
            onSelected: (value) async {
              if (value == 'edit') {
                final data = controller.currentCycle;
                final idx = controller.cycles.indexWhere(
                  (c) => c['name'] == data['name'],
                );
                controller.prepareForEdit(data, idx);
                Get.toNamed(AppRoute.addCycle);
              } else if (value == 'delete') {
                final confirmed = await Get.dialog<bool>(
                  AlertDialog(
                    content: Text(
                      'هل تريد حذف دورة ${controller.currentCycle['name']}؟',
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
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
                        onPressed: () => Get.back(result: true),
                        child: Text(
                          'نعم',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  final isEmpty = await controller.deleteCurrentCycle();
                  if (isEmpty) Get.back();
                }
              } else if (value == 'share') {
                // share logic here
              } else if (value == 'add') {
                controller.isEdit.value = false;
                controller.editIndex.value = -1;
                controller.clearFields();
                Get.toNamed(AppRoute.addCycle);
              } else if (value == 'history') {
                // share logic here
              } else if (value == 'permissions') {
                // share logic here
              } else if (value == 'explains')
                Get.toNamed(AppRoute.cycleStatsBarExplanation);
            },
            itemBuilder:
                (_) => [
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
                  _menuItem(context, 'share', 'مشاركة', Icons.share),
                  const PopupMenuDivider(), // divider between share and add
                  _menuItem(context, 'add', 'اضافة', Icons.add),
                  _menuItem(context, 'history', 'السجل', Icons.history),
                  _menuItem(
                    context,
                    'permissions',
                    'صلاحيات',
                    Icons.manage_accounts,
                  ),
                  _menuItem(context, 'explains', 'شرح', Icons.help_outline),
                ],
          ),
          SizedBox(width: 11.w),
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
  final Color resolvedColor = color ?? Theme.of(context).colorScheme.primary;
  return PopupMenuItem(
    value: value,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Icon(icon, color: resolvedColor), Text(text)],
    ),
  );
}
