import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/class/handling_data.dart';
import '../../core/class/status_request.dart';
import '../../core/services/analytics_service.dart';
import '../../logic/controller/app_review_controller.dart';
import '../widget/app_review/rating_description.dart';
import '../widget/app_review/star_rating_input.dart';

class AppReviewScreen extends StatelessWidget {
  const AppReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      Get.find<AnalyticsService>()
          .logEvent(name: AnalyticsService.appReviewScreenOpened);
    } catch (_) {}

    return Scaffold(
      appBar: AppBar(title: const Text('تقييم التطبيق')),
      body: GetBuilder<AppReviewController>(
        builder: (c) {
          return HandlingDataView(
            statusRequest: c.statusRequest,
            widget: SingleChildScrollView(
              padding: EdgeInsetsDirectional.fromSTEB(20.w, 24.h, 20.w, 24.h),
              child: Column(
                children: [
                  Text(
                    'ما تقييمك للتطبيق؟',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 20.h),
                  StarRatingInput(
                    value: c.rating,
                    onChanged: c.setRating,
                  ),
                  SizedBox(height: 8.h),
                  RatingDescription(rating: c.rating),
                  SizedBox(height: 28.h),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextField(
                      controller: c.issueController,
                      maxLength: 500,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'عندك مشكلة أو ملاحظة؟',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextField(
                      controller: c.suggestionController,
                      maxLength: 500,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'ميزة تتمنى نضيفها؟',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  if (c.validationError != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Text(
                        c.validationError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  if (c.statusRequest == StatusRequest.offlineFailure ||
                      c.statusRequest == StatusRequest.serverFailure)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: TextButton(
                        onPressed: c.submit,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: c.isSubmitting ? null : c.submit,
                      child: c.isSubmitting
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
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
            ),
          );
        },
      ),
    );
  }
}
