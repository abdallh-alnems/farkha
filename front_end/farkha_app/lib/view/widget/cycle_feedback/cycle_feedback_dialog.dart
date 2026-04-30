import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/strings/app_strings.dart';
import '../../../core/class/status_request.dart';
import '../../../logic/controller/cycle_feedback_controller.dart';
import '../app_review/rating_description.dart';
import '../app_review/star_rating_input.dart';

class CycleFeedbackDialog extends StatelessWidget {
  const CycleFeedbackDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: GetBuilder<CycleFeedbackController>(
        builder: (controller) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.w, 20.h, 24.w, 20.h),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'كيف كانت تجربتك مع دورتك؟',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.skip(),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                      child: Icon(Icons.close, size: 24.sp),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              StarRatingInput(
                value: controller.rating,
                onChanged: (v) => controller.setRating(v),
                size: 32,
              ),
              SizedBox(height: 8.h),
              RatingDescription(rating: controller.rating),
              SizedBox(height: 16.h),
              if (controller.validationError != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Text(
                    controller.validationError!,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              TextField(
                controller: controller.issueController,
                maxLength: 500,
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'عندك مشكلة أو ملاحظة؟',
                  counterStyle: TextStyle(fontSize: 11.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  contentPadding:
                      EdgeInsetsDirectional.fromSTEB(12.w, 10.h, 12.w, 10.h),
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: controller.suggestionController,
                maxLength: 500,
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'ميزة تتمنى نضيفها؟',
                  counterStyle: TextStyle(fontSize: 11.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  contentPadding:
                      EdgeInsetsDirectional.fromSTEB(12.w, 10.h, 12.w, 10.h),
                ),
              ),
              SizedBox(height: 8.h),
              if (controller.statusRequest == StatusRequest.offlineFailure ||
                  controller.statusRequest == StatusRequest.serverFailure)
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Column(
                    children: [
                      Text(
                        controller.statusRequest == StatusRequest.offlineFailure
                            ? 'تعذّر إرسال التقييم، تحقّق من الاتصال'
                            : 'حدث خطأ، حاول مرة أخرى',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13.sp,
                        ),
                      ),
                      TextButton(
                        onPressed: () => controller.submit(),
                        child: Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => controller.skip(),
                    child: Text(AppStrings.skip),
                  ),
                  ElevatedButton(
                    onPressed: controller.statusRequest == StatusRequest.loading
                        ? null
                        : () => controller.submit(),
                    child: controller.statusRequest == StatusRequest.loading
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('إرسال'),
                  ),
                ],
              ),
             ],
            ),
          ),
        ),
       ),
      );
  }
}
