import 'package:farkha_app/logic/controller/byd_controller/byd_aihmar_controller.dart';
import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:get/get.dart';

class BydAihmarBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      BydAihmarController(),
    );
    
    Get.put(
      GetDateTime(),
    );
  }
}