import 'package:get/get.dart';

import '../../core/class/crud.dart';
import '../../core/functions/check_internet.dart';
import '../../core/package/rating_app.dart';
import '../../core/package/upgrade/get_min_version.dart';
import '../../core/services/permission.dart';
import '../../core/services/sse_service.dart';
import '../controller/tools_controller/auto_scroll_controller.dart';
import '../controller/price_controller/prices_stream/customize_prices_controller.dart';
import '../controller/price_controller/feed_prices_controller.dart';
import '../controller/price_controller/prices_stream/prices_stream_controller.dart';

class MyBindings extends Bindings {
  @override
  void dependencies() {
    // ================================ curd ===================================
    Get.put(Crud());

    // ================================ SSE Service =============================
    Get.put(SseService(), permanent: true);

    // ================================ price ==================================
    Get.put(PricesStreamController(), permanent: true);
    Get.put(CustomizePricesController(), permanent: true);
    Get.put(FeedPricesController(), permanent: true);

    // ================================ package ================================
    Get.put(InternetController());
    Get.lazyPut(() => RateMyAppController());
    Get.put(GetMinVersionController());

    // =============================== permission =============================
    Get.put(PermissionController());

    // =============================== auto scroll =============================
    Get.put(AutoScrollController());
  }
}
