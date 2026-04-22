import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/services/analytics_service.dart';
import '../../../logic/controller/review_prompt_controller.dart';

class ReviewPromptDialog extends StatelessWidget {
  const ReviewPromptDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = Get.find<AnalyticsService>();

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: const Text('هل تحب تقييم التطبيق؟'),
      content: const Text(
        'رأيك يهمنا! ساعدنا نطوّر التطبيق من خلال تقييمك.',
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () {
            final promptController = Get.find<ReviewPromptController>();
            promptController.markDismissed();
            analytics.logEvent(name: AnalyticsService.reviewPromptDismissed);
            Get.back<void>();
          },
          child: const Text('لاحقاً'),
        ),
        ElevatedButton(
          onPressed: () {
            analytics.logEvent(name: AnalyticsService.reviewPromptAccepted);
            final promptController = Get.find<ReviewPromptController>();
            promptController.acceptPrompt();
            Get.back<void>();
            Get.toNamed<void>(AppRoute.appReview);
          },
          child: const Text('قيّم الآن'),
        ),
      ],
    );
  }
}
