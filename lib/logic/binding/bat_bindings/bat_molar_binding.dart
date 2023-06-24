import 'package:farkha_app/logic/controller/bat_controller/bat_molar_controller.dart';
import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:get/get.dart';

class BatMolarBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      BatMolarController(),
    );
    
    Get.put(
      GetDateTime(),
    );
  }
}