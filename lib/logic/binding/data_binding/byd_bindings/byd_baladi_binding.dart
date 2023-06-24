import 'package:farkha_app/logic/controller/byd_controller/byd_baladi_controller.dart';
import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:get/get.dart';

class BydBaladiBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      BydBaladiController(),
    );
    
    Get.put(
      GetDateTime(),
    );
  }
}