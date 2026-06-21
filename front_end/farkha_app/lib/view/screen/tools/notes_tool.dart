import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/theme.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../data/model/note_model.dart';
import '../../../logic/controller/tools_controller/notes_tool_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';

/// أداة الملاحظات — قائمة الملاحظات المحلية (تخزين على الجهاز فقط).
class NotesToolScreen extends StatelessWidget {
  NotesToolScreen({super.key}) {
    if (!Get.isRegistered<NotesToolController>()) {
      Get.put(NotesToolController());
    }
  }

  static const int toolId = 25;

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: NotesToolScreen, toolId: toolId);
    final controller = Get.find<NotesToolController>();

    return Scaffold(
      appBar: const CustomAppBar(
        text: 'الملاحظات',
        favoriteToolName: 'الملاحظات',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.notes.isEmpty) {
                  return const _NotesEmptyState();
                }
                final list = controller.filteredNotes;
                return Column(
                  children: [
                    _SearchField(controller: controller),
                    Expanded(
                      child: list.isEmpty
                          ? const _NoSearchResults()
                          : _NotesList(notes: list),
                    ),
                  ],
                );
              }),
            ),
            const AdBannerWidget(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed<void>(AppRoute.noteEditor),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: AppElevation.md,
        child: Icon(Icons.add_rounded, size: 30.sp),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final NotesToolController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        12.h,
        AppSpacing.screenH,
        8.h,
      ),
      child: Obx(() {
        final hasText = controller.searchQuery.value.isNotEmpty;
        return TextField(
          onChanged: controller.updateSearch,
          textInputAction: TextInputAction.search,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'ابحث في الملاحظات...',
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.45),
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              size: 22.sp,
            ),
            suffixIcon: hasText
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 20.sp,
                    ),
                    onPressed: () {
                      controller.clearSearch();
                    },
                  )
                : null,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: AppDimens.borderMd,
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppDimens.borderMd,
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppDimens.borderMd,
              borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
            ),
          ),
        );
      }),
    );
  }
}

class _NotesList extends StatelessWidget {
  const _NotesList({required this.notes});

  final List<NoteModel> notes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        4.h,
        AppSpacing.screenH,
        96.h,
      ),
      itemCount: notes.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: const AdNativeWidget(),
          );
        }
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _NoteListCard(note: notes[index - 1]),
        );
      },
    );
  }
}

class _NoteListCard extends StatelessWidget {
  const _NoteListCard({required this.note});

  final NoteModel note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final hasTitle = note.title.trim().isNotEmpty;
    final hasContent = note.content.trim().isNotEmpty;
    final preview = hasContent ? note.content.trim() : 'بدون نص';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppDimens.borderLg,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: AppDimens.borderLg,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              Get.toNamed<void>(AppRoute.noteDetail, arguments: note.id),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: AppDimens.borderSm,
                  ),
                  child: Icon(
                    Icons.sticky_note_2_outlined,
                    size: 18.sp,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasTitle)
                        Text(
                          note.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: hasTitle ? 4.h : 0),
                      Text(
                        preview,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.65),
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 13.sp,
                            color: colorScheme.onSurface
                                .withValues(alpha: 0.45),
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              _formatDate(note.updatedAt, note.isEdited),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.chevron_left_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 22.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date, bool edited) {
    final base = DateFormat('dd MMM yyyy · hh:mm a', 'ar').format(date);
    return edited ? 'آخر تعديل: $base' : base;
  }
}

class _NotesEmptyState extends StatelessWidget {
  const _NotesEmptyState();

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
              padding: EdgeInsets.all(22.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.note_alt_outlined,
                size: 52.sp,
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 22.h),
            Text(
              'لا توجد ملاحظات بعد',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'اضغط على زر + لإضافة ملاحظتك الأولى\nملاحظاتك محفوظة على جهازك فقط',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults();

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
              Icons.search_off_rounded,
              size: 48.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد نتائج',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'جرّب كلمة بحث أخرى',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
