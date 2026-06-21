import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/constant/strings/app_strings.dart';
import '../../../core/constant/theme/theme.dart';
import '../../../data/model/note_model.dart';
import '../../../logic/controller/tools_controller/notes_tool_controller.dart';
import '../../widget/appbar/custom_appbar.dart';

/// شاشة عرض ملاحظة كاملة — قراءة النص مع إمكانية التعديل والحذف.
class NoteDetailScreen extends StatelessWidget {
  NoteDetailScreen({super.key}) {
    if (!Get.isRegistered<NotesToolController>()) {
      Get.put(NotesToolController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotesToolController>();
    final noteId = (Get.arguments as String?) ?? '';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(text: 'ملاحظة'),
      body: SafeArea(
        child: Obx(() {
          final note = controller.getNote(noteId);
          if (note == null) {
            return _NoteGoneState();
          }
          return _NoteBody(note: note);
        }),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            8.h,
            AppSpacing.screenH,
            12.h,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context, controller, noteId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.errorColor,
                    side: BorderSide(
                      color: AppColors.errorColor.withValues(alpha: 0.5),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimens.borderMd,
                    ),
                  ),
                  icon: Icon(Icons.delete_outline_rounded, size: 20.sp),
                  label: Text(
                    AppStrings.delete,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed<void>(
                    AppRoute.noteEditor,
                    arguments: noteId,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: AppElevation.none,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimens.borderMd,
                    ),
                  ),
                  icon: Icon(Icons.edit_rounded, size: 20.sp),
                  label: Text(
                    'تعديل',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    NotesToolController controller,
    String noteId,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Get.dialog<void>(
      Dialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: AppDimens.borderXl),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 32.sp,
                  color: AppColors.errorColor,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                AppStrings.confirmDelete,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              Text(
                'هل أنت متأكد من حذف هذه الملاحظة؟ ${AppStrings.cannotUndo}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back<void>(),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            colorScheme.onSurface.withValues(alpha: 0.6),
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
                      onPressed: () async {
                        final ok = await controller.deleteNote(noteId);
                        if (!ok) {
                          Get.back<void>(); // أغلق الحوار فقط
                          controller.showSnack(
                            message: 'تعذّر الحذف — تحقّق من مساحة التخزين',
                            icon: Icons.cloud_off_rounded,
                            color: AppColors.errorColor,
                          );
                          return;
                        }
                        Get.back<void>(); // أغلق الحوار
                        Get.back<void>(); // ارجع للقائمة
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorColor,
                        foregroundColor: Colors.white,
                        elevation: AppElevation.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimens.borderMd,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        AppStrings.delete,
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
      ),
    );
  }
}

class _NoteBody extends StatelessWidget {
  const _NoteBody({required this.note});

  final NoteModel note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasTitle = note.title.trim().isNotEmpty;
    final hasContent = note.content.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        16.h,
        AppSpacing.screenH,
        24.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                note.isEdited
                    ? Icons.edit_calendar_rounded
                    : Icons.schedule_rounded,
                size: 15.sp,
                color: colorScheme.primary,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  _formatDate(note.updatedAt, note.isEdited),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (hasTitle)
            Text(
              note.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
          if (hasTitle) SizedBox(height: 14.h),
          if (hasContent)
            Text(
              note.content,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.85),
                height: 1.9,
              ),
            ),
          if (!hasTitle && !hasContent)
            Text(
              'ملاحظة فارغة',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, bool edited) {
    final base = DateFormat('dd MMM yyyy · hh:mm a', 'ar').format(date);
    return edited ? 'آخر تعديل: $base' : 'أُنشئت في: $base';
  }
}

class _NoteGoneState extends StatelessWidget {
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
            Icon(
              Icons.visibility_off_rounded,
              size: 48.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            SizedBox(height: 16.h),
            Text(
              'لم يتم العثور على الملاحظة',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () => Get.back<void>(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: AppElevation.none,
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimens.borderMd,
                ),
              ),
              child: const Text('رجوع'),
            ),
          ],
        ),
      ),
    );
  }
}
