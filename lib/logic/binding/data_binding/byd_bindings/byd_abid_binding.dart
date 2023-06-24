import 'package:farkha_app/logic/controller/byd_controller/byd_abid_controller.dart';
import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:get/get.dart';

class BydAbidBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      BydAbidController(),
    );
    
    Get.put(
      GetDateTime(),
    );
  }
}