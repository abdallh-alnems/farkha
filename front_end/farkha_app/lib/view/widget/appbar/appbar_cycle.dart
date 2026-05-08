import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/constant/strings/app_strings.dart';
import '../../../core/constant/theme/colors.dart';
import '../cycle/add_member_dialog.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../cycle/weekly_report_bottom_sheet.dart';
import 'appbar_menu_items.dart';
import 'cycle_dialogs.dart';
import 'cycle_picker_sheet.dart';

class AppBarCycle extends StatelessWidget implements PreferredSizeWidget {
  final void Function(int index)? onCycleSwitch;
  const AppBarCycle({super.key, this.onCycleSwitch});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CycleController>();
    return Obx(() {
      final name = (controller.currentCycle['name'] ?? 'خطا').toString();
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final Color background = colorScheme.surface;
      final Color onBackground = colorScheme.onSurface;
      final bool isDark = theme.brightness == Brightness.dark;
      final accentColor =
          isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

      return Stack(
        children: [
          AppBar(
            backgroundColor: background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 2,
            leading: IconButton(
              onPressed: () => Get.back<void>(),
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: onBackground, size: 20.sp),
            ),
            title: Center(
              child: GestureDetector(
                onTap: () => showCyclePickerSheet(context, controller, isDark, onCycleSwitch),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceElevatedColor
                        : AppColors.lightSurfaceColor,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkOutlineColor
                          : AppColors.lightOutlineColor,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: onBackground,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20.sp,
                        color: accentColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceElevatedColor
                        : AppColors.lightSurfaceColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.more_horiz_rounded,
                      size: 20.sp, color: onBackground),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                position: PopupMenuPosition.under,
                color: background,
                onSelected: (value) =>
                    _handleMenuAction(value, context, controller, background, onBackground, isDark, colorScheme),
                itemBuilder: (_) => [
                  buildMenuHeader('إدارة الدورة'),
                  buildMenuItem(context, 'add_cycle', Icons.add_circle_outline, 'اضف دورة'),
                  buildMenuItem(context, 'history', Icons.history_rounded, 'السجل'),
                  const PopupMenuDivider(height: 8),
                  buildMenuHeader('التقارير'),
                  buildMenuItem(context, 'weeklyReport', Icons.date_range_rounded, 'تقرير أسبوعي'),
                  buildMenuItem(context, 'cycleData', Icons.info_outline_rounded, 'بيانات الدورة'),
                  const PopupMenuDivider(height: 8),
                  buildMenuHeader('إجراءات'),
                  if (!controller.isCycleEnded(controller.currentCycle) &&
                      controller.currentCycle['role'] != 'viewer')
                    buildMenuItem(context, 'endCycle', Icons.task_alt_rounded, 'إنهاء الدورة', color: AppColors.successColor),
                  if (controller.currentCycle['role'] != 'viewer')
                    buildMenuItem(context, 'edit', Icons.edit_outlined, 'تعديل'),
                  buildMenuItem(context, 'share', Icons.share_outlined, 'مشاركة'),
                  if (controller.currentCycle['role'] != 'viewer')
                    buildMenuItem(context, 'permissions', Icons.group_outlined, 'صلاحيات'),
                  buildMenuItem(
                    context,
                    'delete',
                    controller.currentCycle['role'] == 'owner'
                        ? Icons.delete_outline_rounded
                        : Icons.exit_to_app_rounded,
                    controller.currentCycle['role'] == 'owner'
                        ? AppStrings.delete
                        : 'مغادرة الدورة',
                    color: colorScheme.error,
                  ),
                ],
              ),
              SizedBox(width: 8.w),
            ],
          ),
          Obx(() {
            final deleteStatus = controller.cycleDeleteStatus.value;
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
            if (deleteStatus == StatusRequest.success) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (Get.isDialogOpen != true) {
                  if (controller.cycles.isEmpty) {
                    Get.back<void>();
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

  void _handleMenuAction(
    String value,
    BuildContext context,
    CycleController controller,
    Color background,
    Color onBackground,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    if (value == 'add_cycle') {
      unawaited(Get.toNamed<void>(AppRoute.addCycle));
    } else if (value == 'endCycle') {
      showEndCycleDialog(
        controller: controller,
        background: background,
        onBackground: onBackground,
        isDark: isDark,
        accentColor: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
      );
    } else if (value == 'cycleData') {
      showCycleDataDialog(
        controller: controller,
        background: background,
        onBackground: onBackground,
      );
    } else if (value == 'edit') {
      final data = controller.currentCycle;
      final idx = controller.cycles.indexWhere(
        (c) => c['name'] == data['name'],
      );
      controller.prepareForEdit(data, idx);
      unawaited(Get.toNamed<void>(AppRoute.addCycle));
    } else if (value == 'delete') {
      showDeleteConfirmDialog(
        controller: controller,
        background: background,
        onBackground: onBackground,
        errorColor: colorScheme.error,
      );
    } else if (value == 'share') {
      showShareDialog(
        controller: controller,
        background: background,
        onBackground: onBackground,
      );
    } else if (value == 'weeklyReport') {
      unawaited(
        WeeklyReportBottomSheet.show(context, controller.currentCycle),
      );
    } else if (value == 'history') {
      unawaited(Get.toNamed<void>(AppRoute.history));
    } else if (value == 'permissions') {
      final rawId = controller.currentCycle['cycle_id'];
      final cycleId =
          rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0;
      Get.dialog<void>(
        AddMemberDialog(cycleId: cycleId, isDark: isDark),
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
