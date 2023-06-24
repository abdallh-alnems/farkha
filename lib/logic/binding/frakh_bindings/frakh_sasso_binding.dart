import 'package:farkha_app/logic/controller/frakh_controller/frakh_sasso_controller.dart';
import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:get/get.dart';

class FrakhSassoBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      FrakhSassoController(),
    );
    
    Get.put(
      GetDateTime(),
    );
  }
}