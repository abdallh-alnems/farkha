import 'package:get/get.dart';
import '../../core/services/sse_service.dart';
import '../controller/price_controller/farkh_abid_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // إضافة خدمة SSE كـ GetxService
    Get.put(SseService(), permanent: true);

    // إضافة الـ Controllers
    Get.put(FarkhAbidController());
    // ... باقي الـ Controllers
  }
}



