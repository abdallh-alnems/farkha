import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rate_my_app/rate_my_app.dart';

class RateMyAppController extends GetxController {
  final RateMyApp rateMyApp = RateMyApp(
    minDays: 3,
    remindDays: 7,
    minLaunches: 7,
    remindLaunches: 10,
    appStoreIdentifier: '',
    googlePlayIdentifier: 'ni.nims.frkha',
  );

  @override
  void onInit() {
    super.onInit();
    _showRateDialog();
  }

  void _showRateDialog() {
    rateMyApp.init().then((_) {
      if (rateMyApp.shouldOpenDialog) {
        // التأكد من وجود context و navigation stack قبل فتح dialog
        final context = Get.context;
        if (context != null) {
          // استخدام addPostFrameCallback للتأكد من أن navigation stack جاهز
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final currentContext = Get.context;
            if (currentContext != null && Navigator.canPop(currentContext)) {
              rateMyApp.showRateDialog(
                currentContext,
                title: 'قيمنا',
                message:
                    'أهلاً! نرغب في سماع رأيك حول تطبيقنا\n \n هل يمكنك قضاء بعض الوقت لتقييم التطبيق ؟\n \n تعليقاتك مهمة جدًا بالنسبة لنا لتحسين تجربتك وتلبية احتياجاتك',
                rateButton: 'تقيييم',
                noButton: 'لا شكرًا',
                laterButton: 'لاحقا',
                ignoreNativeDialog: true,
                onDismissed:
                    () => rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
              );
            }
          });
        }
      }
    });
  }

  void launchStore() {
    rateMyApp.launchStore();
  }
}
