import 'package:farkha_app/logic/controller/katkit_controller/katkit_abid_controller.dart';
import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:get/get.dart';

class KatakitAbidBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      KatKitAbidController(),
    );
    
    Get.put(
      GetDateTime(),
    );
  }
}
