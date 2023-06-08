import 'package:farkha_app/logic/controller/data_controller/data_bat_controller.dart';
import 'package:get/get.dart';

class BatBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DataBatController());
  }
}