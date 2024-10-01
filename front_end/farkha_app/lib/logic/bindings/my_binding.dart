import 'package:get/get.dart';

import '../controller/ad_controller.dart';

class MyBindings extends Bindings {
  @override
  void dependencies() {

     Get.put(
      AdController(),
    );
  }
}
