import 'package:farkha_app/logic/controller/frakh_controller/frakh_baladi_controller.dart';
import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:get/get.dart';

class FrakhBaladiBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      FrakhBaladiController(),
    );
    
    Get.put(
      GetDateTime(),
    );
  }
}