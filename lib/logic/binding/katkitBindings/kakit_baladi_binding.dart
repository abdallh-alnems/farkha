import 'package:farkha_app/logic/controller/katkit_controller/katkit_baladi_controller.dart';
import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:get/get.dart';

class KatakitBaladiBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      KatKitBaladiController(),
    );
    
    Get.put(
      GetDateTime(),
    );
  }
}