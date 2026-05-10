import 'package:get/get.dart';
import 'remote_config_controller.dart';

class RemoteConfigBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RemoteConfigController>(() => RemoteConfigController());
  }
}
