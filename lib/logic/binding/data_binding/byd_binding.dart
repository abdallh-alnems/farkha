import 'package:farkha_app/logic/controller/data_controller/data_byd_controller.dart';
import 'package:get/get.dart';

class BydBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DataBydController());
  }
}