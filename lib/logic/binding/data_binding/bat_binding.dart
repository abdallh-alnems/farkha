import 'package:farkha_app/logic/controller/data_down_controller/data_down_bat_controller.dart';
import 'package:farkha_app/logic/controller/data_up_controller/data_up_bat_controller.dart';
import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:get/get.dart';

class BatBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DataUpBatController());
    Get.put(DataDownBatController());
    Get.put(GetDateTime());
  }
}
