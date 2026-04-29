import 'package:get/get.dart';

import '../../../core/class/crud.dart';
import '../../../data/data_source/remote/cycle_feedback_data.dart';
import '../../../logic/controller/cycle_feedback_controller.dart';

class CycleFeedbackBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CycleFeedbackData(Get.find<Crud>()));
    Get.put(CycleFeedbackController(Get.find<CycleFeedbackData>()));
  }
}
