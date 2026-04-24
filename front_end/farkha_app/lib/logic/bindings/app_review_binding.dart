import 'package:get/get.dart';

import '../../../core/class/crud.dart';
import '../../../data/data_source/remote/app_review_data.dart';
import '../../../logic/controller/app_review_controller.dart';

class AppReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.delete<AppReviewController>(force: true);
    Get.put(AppReviewData(Get.find<Crud>()));
    Get.put(AppReviewController(Get.find<AppReviewData>()));
  }
}
