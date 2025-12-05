import 'package:get/get.dart';

import '../../core/package/rating_app.dart';
import '../../core/services/permission.dart';
import '../controller/internet_controller.dart';
import '../controller/tools_controller/auto_scroll_controller.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    // =========================== auto scroll tools ===========================
    Get.put(AutoScrollController());

    // =============================== permission ==============================
    Get.put(PermissionController(), permanent: true);

    // ================================ Internet Controller ====================
    Get.put(InternetController(), permanent: true);

    // =============================== Rating Controller =======================
    Get.put(RateMyAppController(), permanent: true);
  }
}
