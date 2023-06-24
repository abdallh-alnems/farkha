import 'package:farkha_app/logic/controller/bat_controller/bat_firansawi_controller.dart';
import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:get/get.dart';

class BatFiransawiBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      BatFiransawiController(),
    );
    
    Get.put(
      GetDateTime(),
    );
  }
}