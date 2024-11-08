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
        rateMyApp.showRateDialog(
          Get.context!,
          title: 'قيمنا',
          message:
              '.أهلاً! نرغب في سماع رأيك حول تطبيقنا\n \n هل يمكنك قضاء بعض الوقت لتقييم التطبيق ؟\n \n تعليقاتك مهمة جدًا بالنسبة لنا لتحسين تجربتك وتلبية احتياجاتك',
          rateButton: 'تقيييم',
          noButton: 'لا شكرًا',
          laterButton: 'لاحقا',
          
          ignoreNativeDialog: true,
          dialogStyle: DialogStyle(
            titleAlign: TextAlign.end,
            messageAlign: TextAlign.end,
          ),
          onDismissed: () =>
              rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
        );
      }
    });
  }
}
