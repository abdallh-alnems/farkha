import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constant/strings/app_strings.dart';
import '../../../core/constant/theme/theme.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_notes_controller.dart';

class NoteCard extends StatelessWidget {
  final NoteItem note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final isViewer =
        Get.find<CycleController>().currentCycle['role']?.toString() ==
        'viewer';

    return GestureDetector(
      onTap: isViewer ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AppDimens.borderLg,
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.6),
          ),
          boxShadow: isDark
              ? null
              : [
                  AppElevation.shadow(
                    opacity: 0.06,
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 0),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: AppDimens.borderSm,
                    ),
                    child: Icon(
                      Icons.sticky_note_2_outlined,
                      size: 15.sp,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      DateFormat('dd MMM yyyy · hh:mm a', 'ar')
                          .format(note.date),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (!isViewer)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onDelete,
                        borderRadius: AppDimens.borderSm,
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: AppColors.errorColor.withValues(alpha: 0.08),
                            borderRadius: AppDimens.borderSm,
                          ),
                          child: Icon(
                            Icons.close,
                            color: AppColors.errorColor,
                            size: 16.sp,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 14.h),
              child: Text(
                note.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  height: 1.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotesEmptyState extends StatelessWidget {
  final ColorScheme colorScheme;

  const NotesEmptyState({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.note_alt_outlined,
                size: 48.sp,
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'لا توجد ملاحظات بعد',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'اضغط على + لإضافة ملاحظتك الأولى',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class NotesErrorState extends StatelessWidget {
  final bool isOffline;
  final VoidCallback onRetry;

  const NotesErrorState({super.key, required this.isOffline, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOffline
                    ? Icons.wifi_off_rounded
                    : Icons.cloud_off_rounded,
                size: 44.sp,
                color: colorScheme.error.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              isOffline
                  ? 'لا يوجد اتصال بالإنترنت'
                  : 'حدث خطأ في تحميل الملاحظات',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: AppElevation.none,
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimens.borderMd,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 12.h,
                  horizontal: 24.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoteDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final TextEditingController textController;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final String actionLabel;
  final VoidCallback onAction;

  const NoteDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.textController,
    required this.colorScheme,
    required this.theme,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: AppDimens.borderXl),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: AppDimens.borderMd,
                  ),
                  child: Icon(icon, color: colorScheme.primary, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: AppDimens.borderMd,
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
              child: TextField(
                controller: textController,
                maxLines: 5,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  height: 1.7,
                ),
                decoration: InputDecoration(
                  hintText: 'اكتب ملاحظتك هنا...',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 14.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14.w),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back<void>(),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          colorScheme.onSurface.withValues(alpha: 0.5),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      AppStrings.cancel,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: AppElevation.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimens.borderMd,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      actionLabel,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
