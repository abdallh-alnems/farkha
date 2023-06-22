import 'package:farkha_app/logic/controller/data_down_controller/data_down_byd_controller.dart';
import 'package:farkha_app/logic/controller/data_up_controller/data_up_byd_controller.dart';
import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:get/get.dart';

class BydBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DataUpBydController());
    Get.put(DataDownBydController());
    Get.put(GetDateTime());
  }
}
