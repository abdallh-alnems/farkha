import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/color.dart';
import '../../../logic/controller/cycle_controller.dart';

class AppBarCycle extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCycle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CycleController>();
    return Obx(() {
      final name = controller.currentCycle['name'] ?? 'خطا';
      return AppBar(
        backgroundColor: AppColor.appBackGroundColor,
        leading: _icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black,
          onPressed: () => Get.back(),
        ),
        title: Center(
          child: Text(
            name,
            style: TextStyle(fontSize: 21.sp, color: Colors.black),
          ),
        ),
        actions: [
          _icon(Icons.notifications_active, color: Colors.yellow[600]),
          // Exclamation icon to show current cycle data
          _icon(
            Icons.error,
            color: Colors.black,
            onPressed: () {
              // Show dialog with cycle data
              final cycle = controller.currentCycle;
              Get.dialog(
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: AlertDialog(
                    title: Text(
                      'بيانات الدورة',
                      textDirection: TextDirection.rtl,
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الاسم : ${cycle['name'] ?? '-'}'),
                        SizedBox(height: 9), // مسافة 8 logical pixels
                        Text('نوع الدورة : تسمين'),
                        SizedBox(height: 9),
                        Text('عدد الفراخ : ${cycle['chickCount']}'),
                        SizedBox(height: 9),
                        Text('المساحة : ${cycle['space']}'),
                        SizedBox(height: 9),
                        Text('نظام التربية : ارضي'),
                        SizedBox(height: 9),
                        Text('تاريخ البدء : ${cycle['startDate']}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('حسناً'),
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
                        child: Text('تعديل'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 23.sp, color: Colors.black),
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
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: Text('نعم', style: TextStyle(color: Colors.red)),
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
                  _menuItem('edit', 'تعديل', Icons.edit_calendar_outlined),
                  _menuItem('delete', 'حذف', Icons.delete, color: Colors.red),
                  _menuItem('share', 'مشاركة', Icons.share),
                  const PopupMenuDivider(), // divider between share and add
                  _menuItem('add', 'اضافة', Icons.add),
                  _menuItem('history', 'السجل', Icons.history),
                  _menuItem('permissions', 'صلاحيات', Icons.manage_accounts),
                  _menuItem('explains', 'شرح', Icons.help_outline),
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

Widget _icon(IconData icon, {Color? color, VoidCallback? onPressed}) {
  return IconButton(
    onPressed: onPressed,
    icon: Icon(icon, color: color ?? Colors.white, size: 23.sp),
  );
}

PopupMenuItem<String> _menuItem(
  String value,
  String text,
  IconData icon, {
  Color? color,
}) {
  return PopupMenuItem(
    value: value,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Icon(icon, color: color ?? AppColor.primaryColor), Text(text)],
    ),
  );
}
