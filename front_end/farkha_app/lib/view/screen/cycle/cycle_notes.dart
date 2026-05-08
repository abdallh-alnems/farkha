import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/strings/app_strings.dart';
import '../../../core/constant/theme/theme.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_notes_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/cycle_sub_screen_appbar.dart';
import '../../widget/cycle/cycle_notes_widgets.dart';

class CycleNotesScreen extends StatelessWidget {
  const CycleNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CycleController>()) {
      Get.put(CycleController());
    }
    if (!Get.isRegistered<CycleNotesController>()) {
      Get.put(CycleNotesController());
    }

    final noteCtrl = Get.find<CycleNotesController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CycleSubScreenAppBar(
        titlePrefix: 'ملاحظات',
        onAddPressed: () => _showNoteDialog(context, noteCtrl),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final status = noteCtrl.notesStatus.value;

                if (status == StatusRequest.loading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                      strokeWidth: 3,
                    ),
                  );
                }

                if (status == StatusRequest.serverFailure ||
                    status == StatusRequest.offlineFailure ||
                    status == StatusRequest.failure) {
                  return NotesErrorState(
                    isOffline: status == StatusRequest.offlineFailure,
                    onRetry: () => noteCtrl.refreshNotes(),
                  );
                }

                if (noteCtrl.notes.isEmpty) {
                  return NotesEmptyState(colorScheme: colorScheme);
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    20.h,
                    AppSpacing.screenH,
                    24.h,
                  ),
                  itemCount: noteCtrl.notes.length,
                  separatorBuilder: (_, i) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        if (index == 0) ...[
                          const AdNativeWidget(),
                          SizedBox(height: 16.h),
                        ],
                        NoteCard(
                          note: noteCtrl.notes[index],
                          onTap: () => _showEditNoteDialog(
                            context,
                            noteCtrl,
                            noteCtrl.notes[index],
                          ),
                          onDelete: () => _showDeleteConfirmDialog(
                            context,
                            noteCtrl,
                            noteCtrl.notes[index].id,
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
            const AdBannerWidget(),
          ],
        ),
      ),
    );
  }

  void _showEditNoteDialog(
    BuildContext context,
    CycleNotesController ctrl,
    NoteItem note,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textController = TextEditingController(text: note.content);

    Get.dialog<void>(
      NoteDialog(
        title: 'تعديل الملاحظة',
        icon: Icons.edit_note_rounded,
        textController: textController,
        colorScheme: colorScheme,
        theme: theme,
        actionLabel: 'حفظ التعديلات',
        onAction: () {
          if (textController.text.trim().isNotEmpty) {
            ctrl.updateNote(note.id, textController.text);
            Get.back<void>();
          }
        },
      ),
    );
  }

  void _showNoteDialog(
    BuildContext context,
    CycleNotesController ctrl,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textController = TextEditingController();

    Get.dialog<void>(
      NoteDialog(
        title: 'إضافة ملاحظة جديدة',
        icon: Icons.note_add_rounded,
        textController: textController,
        colorScheme: colorScheme,
        theme: theme,
        actionLabel: 'إضافة',
        onAction: () {
          if (textController.text.trim().isNotEmpty) {
            ctrl.addNote(textController.text);
            Get.back<void>();
          }
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    CycleNotesController ctrl,
    String id,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              Text(
                'هل أنت متأكد من حذف هذه الملاحظة؟',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                      child: Text(AppStrings.cancel, style: TextStyle(fontSize: 14.sp)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ctrl.deleteNote(id);
                        Get.back<void>();
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
