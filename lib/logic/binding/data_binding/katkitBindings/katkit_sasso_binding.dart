import 'package:farkha_app/logic/controller/katkit_controller/katkit_sasso_controller.dart';
import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:get/get.dart';

class KatakitSassoBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      KatKitSassoController(),
    );
    
    Get.put(
      GetDateTime(),
    );
  }
}