import 'package:farkha_app/logic/controller/data_up_controller/data_up_frakh_controller.dart';
import 'package:get/get.dart';

class FrakhBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DataFrakhController());
  }
}