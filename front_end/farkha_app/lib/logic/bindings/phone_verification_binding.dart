import 'package:get/get.dart';

import '../controller/auth/phone_verification_controller.dart';

class PhoneVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhoneVerificationController>(
      () => PhoneVerificationController(),
    );
  }
}
