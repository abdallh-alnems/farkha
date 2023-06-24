import 'package:farkha_app/logic/controller/bat_controller/bat_maskufi_controller.dart';
import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:get/get.dart';

class BatMaskufiBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      BatMaskufiController(),
    );
    
    Get.put(
      GetDateTime(),
    );
  }
}