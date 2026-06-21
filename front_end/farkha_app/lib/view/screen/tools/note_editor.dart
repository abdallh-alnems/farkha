import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/strings/app_strings.dart';
import '../../../core/constant/theme/theme.dart';
import '../../../logic/controller/tools_controller/notes_tool_controller.dart';
import '../../widget/appbar/custom_appbar.dart';

/// شاشة إنشاء/تعديل ملاحظة. وضع التعديل يُحدَّد بتمرير معرّف الملاحظة
/// عبر [Get.arguments].
class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final NotesToolController _controller;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// معرّف الملاحظة عند التعديل، أو null عند الإنشاء.
  String? _editingId;

  bool get _isEditing => _editingId != null;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<NotesToolController>()) {
      Get.put(NotesToolController());
    }
    _controller = Get.find<NotesToolController>();

    final args = Get.arguments;
    if (args is String) {
      _editingId = args;
      final note = _controller.getNote(args);
      _titleCtrl = TextEditingController(text: note?.title ?? '');
      _contentCtrl = TextEditingController(text: note?.content ?? '');
    } else {
      _titleCtrl = TextEditingController();
      _contentCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    if (title.isEmpty && content.isEmpty) {
      _controller.showSnack(
        message: 'لا يمكن حفظ ملاحظة فارغة — اكتب عنواناً أو نصاً',
        icon: Icons.info_outline_rounded,
        color: Colors.orange.shade700,
      );
      return;
    }

    final success = _isEditing
        ? await _controller.updateNote(
            id: _editingId!,
            title: title,
            content: content,
          )
        : await _controller.addNote(title: title, content: content);

    if (success) {
      _controller.showSnack(
        message: _isEditing ? 'تم حفظ التعديلات' : 'تم حفظ الملاحظة',
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.primaryColor,
      );
      Get.back<void>();
    } else {
      _controller.showSnack(
        message: 'تعذّر حفظ الملاحظة — تحقّق من مساحة التخزين وحاول مجدداً',
        icon: Icons.cloud_off_rounded,
        color: AppColors.errorColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        text: _isEditing ? 'تعديل الملاحظة' : 'ملاحظة جديدة',
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              16.h,
              AppSpacing.screenH,
              24.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FieldContainer(
                  child: TextFormField(
                    controller: _titleCtrl,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: 'العنوان',
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                      ),
                      border: InputBorder.none,
                    ),
                    minLines: 1,
                    maxLines: 2,
                  ),
                ),
                SizedBox(height: 12.h),
                _FieldContainer(
                  child: TextFormField(
                    controller: _contentCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.8,
                    ),
                    decoration: InputDecoration(
                      hintText: 'اكتب ملاحظتك هنا...',
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 15.sp,
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: 14,
                    minLines: 8,
                  ),
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: AppElevation.none,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimens.borderMd,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_rounded, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        _isEditing ? 'حفظ التعديلات' : AppStrings.save,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                TextButton(
                  onPressed: () => Get.back<void>(),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  child: const Text(AppStrings.cancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldContainer extends StatelessWidget {
  const _FieldContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppDimens.borderLg,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }
}
