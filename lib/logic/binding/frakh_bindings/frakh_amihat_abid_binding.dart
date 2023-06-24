import 'package:farkha_app/logic/controller/frakh_controller/frakh_amihat_abid_controller.dart';
import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:get/get.dart';

class FrakhAmhitAbidBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      FrakhAmhitAbidController(),
    );
    
    Get.put(
      GetDateTime(),
    );
  }
}