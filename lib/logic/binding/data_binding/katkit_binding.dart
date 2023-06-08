import 'package:farkha_app/logic/controller/data_controller/data_katkit_controller.dart';
import 'package:get/get.dart';

class KatakitBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DataKatakitController());
  }
}