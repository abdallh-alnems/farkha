import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/tools_controller/darkness_schedule_controller.dart';

class DarknessSettingsSheet extends StatelessWidget {
  const DarknessSettingsSheet({super.key, required this.controller});

  final DarknessScheduleController controller;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primary =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
    final Color surface = isDark ? AppColors.darkSurfaceColor : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.10),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          child: Obx(() {
            // Trigger rebuild when phase reminder times change.
            final int _ = controller.phaseReminderUpdateTrigger.value;
            final bool enabled = controller.notificationsEnabledRx.value;
            final bool permissions = controller.permissionsGranted.value;
            final int phases = controller.numberOfPhasesForToday;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SheetHandle(isDark: isDark),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'مواعيد منبهات الإظلام',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: primary,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Switch(
                        value: enabled && permissions,
                        onChanged: (bool v) async {
                          if (v) {
                            await controller.requirePermissions();
                          } else {
                            controller.notificationsEnabled = false;
                          }
                        },
                        activeThumbColor: primary,
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  _PhaseSection(
                    controller: controller,
                    primary: primary,
                    isDark: isDark,
                    phases: phases,
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  static Future<void> open(
    BuildContext context, {
    required DarknessScheduleController controller,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DarknessSettingsSheet(controller: controller),
    );
  }
}

class _PhaseSection extends StatelessWidget {
  const _PhaseSection({
    required this.controller,
    required this.primary,
    required this.isDark,
    required this.phases,
  });

  final DarknessScheduleController controller;
  final Color primary;
  final bool isDark;
  final int phases;

  @override
  Widget build(BuildContext context) {
    final Color muted = isDark ? Colors.grey[400]! : Colors.grey[700]!;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: primary.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            phases > 0 ? 'اضغط لتعديل وقت كل مرحلة' : 'افتح دورة لظهور المراحل',
            style: TextStyle(fontSize: 12.sp, color: muted),
          ),
          if (phases > 0) ...[
            SizedBox(height: 10.h),
            ...List<Widget>.generate(phases, (int i) {
              final int phase = i + 1;
              final int? hour24 = controller.getPhaseReminderHour(phase);
              final int? minute = controller.getPhaseReminderMinute(phase);

              String timeDisplay;
              String periodDisplay;

              if (hour24 != null && minute != null) {
                final String period = hour24 < 12 ? 'ص' : 'م';
                final int hour12 =
                    hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
                timeDisplay =
                    '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
                periodDisplay = ' $period';
              } else {
                timeDisplay = '--:--';
                periodDisplay = '';
              }

              return Padding(
                padding: EdgeInsets.only(bottom: i == phases - 1 ? 0 : 8.h),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14.r),
                  onTap: () async {
                    final bool granted = await controller.requirePermissions();
                    if (granted && context.mounted) {
                      _openTimePicker(
                        context: context,
                        controller: controller,
                        phase: phase,
                        hour: hour24 ?? 12, // Default to 12 if unset
                        minute: minute ?? 0,
                        primary: primary,
                        isDark: isDark,
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: primary.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34.w,
                          height: 34.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '$phase',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              color: primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text:
                                    hour24 == null ? 'اضبط الوقت' : timeDisplay,
                                style: TextStyle(
                                  fontSize: hour24 == null ? 14.sp : 18.sp,
                                  fontWeight: FontWeight.w900,
                                  color: primary,
                                  letterSpacing: hour24 == null ? 0 : 1.1,
                                  fontFeatures: const <FontFeature>[
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              if (hour24 != null)
                                TextSpan(
                                  text: periodDisplay,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (hour24 != null)
                          IconButton(
                            onPressed:
                                () => controller.clearPhaseReminderTime(phase),
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 20.sp,
                              color: Colors.red.withValues(alpha: 0.7),
                            ),
                            tooltip: 'إيقاف المنبه',
                          ),
                        Icon(
                          Icons.edit_rounded,
                          size: 18.sp,
                          color: primary.withValues(alpha: 0.9),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Future<void> _openTimePicker({
    required BuildContext context,
    required DarknessScheduleController controller,
    required int phase,
    required int hour,
    required int minute,
    required Color primary,
    required bool isDark,
  }) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Localizations.override(
            context: context,
            locale: const Locale('ar'),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: primary,
                    brightness: isDark ? Brightness.dark : Brightness.light,
                  ),
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );

    if (picked == null || !context.mounted) return;
    controller.setPhaseReminderTime(phase, picked.hour, picked.minute);
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: (isDark ? Colors.grey[600] : Colors.grey[400])!.withValues(
            alpha: 0.9,
          ),
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}
