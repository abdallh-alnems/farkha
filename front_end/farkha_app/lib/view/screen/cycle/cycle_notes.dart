import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_notes_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';

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
    final cycleCtrl = Get.find<CycleController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackGroundColor : AppColors.appBackGroundColor,
      appBar: AppBar(
        backgroundColor:
            isDark
                ? AppColors.darkSurfaceElevatedColor
                : AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkPrimaryColor : Colors.white,
          ),
          onPressed: () => Get.back<void>(),
        ),
        title: Obx(() {
          final cycle = cycleCtrl.currentCycle;
          return Text(
            'ملاحظات ${cycle['name'] ?? 'الدورة'}',
            style: TextStyle(
              color: isDark ? AppColors.darkPrimaryColor : Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
        centerTitle: true,
        actions: [
          if (cycleCtrl.currentCycle['role']?.toString() != 'viewer')
            IconButton(
              icon: Icon(
                Icons.add,
                color: isDark ? AppColors.darkPrimaryColor : Colors.white,
              ),
              onPressed: () => _showAddNoteDialog(context, noteCtrl, isDark),
            ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final status = noteCtrl.notesStatus.value;

                // حالة التحميل
                if (status == StatusRequest.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // حالة الخطأ
                if (status == StatusRequest.serverFailure ||
                    status == StatusRequest.offlineFailure ||
                    status == StatusRequest.failure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          status == StatusRequest.offlineFailure
                              ? Icons.wifi_off_rounded
                              : Icons.error_outline_rounded,
                          size: 48.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          status == StatusRequest.offlineFailure
                              ? 'لا يوجد اتصال بالإنترنت'
                              : 'حدث خطأ في تحميل الملاحظات',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton.icon(
                          onPressed: () => noteCtrl.refreshNotes(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (noteCtrl.notes.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد ملاحظات',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  itemCount: noteCtrl.notes.length,
                  itemBuilder: (context, index) {
                    final note = noteCtrl.notes[index];
                    return Column(
                      children: [
                        if (index == 0) ...[
                          const AdNativeWidget(),
                          SizedBox(height: 12.h),
                        ],
                        _buildNoteItem(context, note, noteCtrl, isDark),
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

  Widget _buildNoteItem(
    BuildContext context,
    NoteItem note,
    CycleNotesController ctrl,
    bool isDark,
  ) {
    final isViewer =
        Get.find<CycleController>().currentCycle['role']?.toString() ==
        'viewer';
    return GestureDetector(
      onTap:
          isViewer ? null : () => _showEditNoteDialog(context, ctrl, note, isDark),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceColor : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color:
                isDark
                    ? AppColors.darkOutlineColor.withOpacity(0.1)
                    : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('yyyy-MM-dd | hh:mm a', 'ar').format(note.date),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontFamily: 'Cairo',
                  ),
                ),
                if (!isViewer)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red[300],
                      size: 20.sp,
                    ),
                    onPressed:
                        () => _showDeleteConfirmDialog(context, ctrl, note.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              note.content,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNoteDialog(
    BuildContext context,
    CycleNotesController ctrl,
    NoteItem note,
    bool isDark,
  ) {
    final textController = TextEditingController(text: note.content);

    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        backgroundColor: isDark ? AppColors.darkSurfaceColor : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تعديل الملاحظة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: textController,
                maxLines: 5,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'اكتب ملاحظتك هنا...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  filled: true,
                  fillColor:
                      isDark ? AppColors.darkBackGroundColor : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(12.w),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back<void>(),
                      style: TextButton.styleFrom(foregroundColor: Colors.grey),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (textController.text.trim().isNotEmpty) {
                          ctrl.updateNote(note.id, textController.text);
                          Get.back<void>();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: const Text(
                        'حفظ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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

  void _showAddNoteDialog(
    BuildContext context,
    CycleNotesController ctrl,
    bool isDark,
  ) {
    _showNoteDialog(context, ctrl, isDark);
  }

  void _showNoteDialog(
    BuildContext context,
    CycleNotesController ctrl,
    bool isDark,
  ) {
    final textController = TextEditingController();

    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        backgroundColor: isDark ? AppColors.darkSurfaceColor : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'إضافة ملاحظة جديدة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: textController,
                maxLines: 5,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'اكتب ملاحظتك هنا...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  filled: true,
                  fillColor:
                      isDark ? AppColors.darkBackGroundColor : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(12.w),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back<void>(),
                      style: TextButton.styleFrom(foregroundColor: Colors.grey),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(() {
                      final isLoading =
                          ctrl.addNoteStatus.value == StatusRequest.loading;
                      return ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : () {
                                  if (textController.text.trim().isNotEmpty) {
                                    ctrl.addNote(textController.text);
                                    Get.back<void>();
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child:
                            isLoading
                                ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text(
                                  'حفظ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    CycleNotesController ctrl,
    String id,
  ) {
    Get.dialog<void>(
      AlertDialog(
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurfaceColor
                : Colors.white,
        title: Text(
          'تأكيد الحذف',
          style: TextStyle(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذه الملاحظة؟',
          style: TextStyle(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ctrl.deleteNote(id);
              Get.back<void>();
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
