import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../logic/controller/app_review_controller.dart';
import '../../../logic/controller/review_prompt_controller.dart';
import 'rating_description.dart';
import 'star_rating_input.dart';

class AppReviewDialog extends StatefulWidget {
  final bool autoPrompted;

  const AppReviewDialog({super.key, this.autoPrompted = false});

  @override
  State<AppReviewDialog> createState() => _AppReviewDialogState();
}

class _AppReviewDialogState extends State<AppReviewDialog> {
  bool _autoCloseScheduled = false;

  void _scheduleAutoClose() {
    if (_autoCloseScheduled) return;
    _autoCloseScheduled = true;
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxHeight: 560.h, maxWidth: 380.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: GetBuilder<AppReviewController>(
          builder: (c) {
            if (c.isSubmitted) {
              _scheduleAutoClose();
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'شكراً لتقييمك!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'رأيك يهمنا وساعدنا نطوّر التطبيق',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: const Text('تمام'),
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsetsDirectional.fromSTEB(20.w, 20.h, 20.w, 16.h),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28.sp,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'ما تقييمك للتطبيق؟',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'رأيك يهمنا وساعدنا نطوّر التطبيق',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                    ),
                    SizedBox(height: 16.h),
                    StarRatingInput(
                      value: c.rating,
                      onChanged: c.setRating,
                      size: 36,
                    ),
                    SizedBox(height: 4.h),
                    RatingDescription(rating: c.rating),
                    if (c.validationError != null)
                      Padding(
                        padding: EdgeInsetsDirectional.only(top: 6.h),
                        child: Text(
                          c.validationError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    SizedBox(height: 14.h),
                    TextField(
                      controller: c.issueController,
                      maxLength: 500,
                      maxLines: 3,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText: 'عندك مشكلة أو ملاحظة؟',
                        hintStyle: TextStyle(fontSize: 13.sp),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        contentPadding: EdgeInsetsDirectional.fromSTEB(12.w, 10.h, 12.w, 10.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: c.suggestionController,
                      maxLength: 500,
                      maxLines: 3,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText: 'ميزة تتمنى نضيفها؟',
                        hintStyle: TextStyle(fontSize: 13.sp),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        contentPadding: EdgeInsetsDirectional.fromSTEB(12.w, 10.h, 12.w, 10.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              if (widget.autoPrompted && Get.isRegistered<ReviewPromptController>()) {
                                Get.find<ReviewPromptController>().markDismissed();
                              }
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: const Text('لاحقاً'),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: c.isSubmitting ? null : c.submit,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: c.isSubmitting
                                ? SizedBox(
                                    width: 18.w,
                                    height: 18.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('إرسال'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
