import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/class/crud.dart';
import '../../../data/data_source/remote/app_review_data.dart';
import '../../../logic/controller/app_review_controller.dart';

class AppReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppReviewData(Get.find<Crud>()));
    Get.lazyPut(() => AppReviewController(
          Get.find<AppReviewData>(),
          auth: FirebaseAuth.instance,
        ));
  }
}
