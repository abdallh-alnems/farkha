import 'package:farkha_app/logic/controller/a3alf/a3laf_controller.dart';
import 'package:get/get.dart';

class A3lafBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      A3lafController(),
    );
    
    
  }
}