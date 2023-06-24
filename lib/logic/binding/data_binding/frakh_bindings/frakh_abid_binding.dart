import 'package:farkha_app/logic/controller/frakh_controller/frakh_abid_controller.dart';
import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:get/get.dart';

class FrakhAbidBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      FrakhAbidController(),
    );
    
    Get.put(
      GetDateTime(),
    );
  }
}