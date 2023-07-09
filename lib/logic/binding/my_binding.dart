import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:farkha_app/logic/controller/master_circle_controllers/a3alf/a3laf_controller.dart';
import 'package:farkha_app/logic/controller/master_circle_controllers/bat_controller/bat_firansawi_controller.dart';
import 'package:farkha_app/logic/controller/master_circle_controllers/bat_controller/bat_maskufi_controller.dart';
import 'package:farkha_app/logic/controller/master_circle_controllers/bat_controller/bat_molar_controller.dart';
import 'package:farkha_app/logic/controller/master_circle_controllers/byd_controller/byd_abid_controller.dart';
import 'package:farkha_app/logic/controller/master_circle_controllers/byd_controller/byd_aihmar_controller.dart';
import 'package:farkha_app/logic/controller/master_circle_controllers/byd_controller/byd_baladi_controller.dart';
import 'package:farkha_app/logic/controller/master_circle_controllers/frakh_controller/frakh_abid_controller.dart';
import 'package:farkha_app/logic/controller/master_circle_controllers/frakh_controller/frakh_amihat_abid_controller.dart';
import 'package:farkha_app/logic/controller/master_circle_controllers/frakh_controller/frakh_baladi_controller.dart';
import 'package:farkha_app/logic/controller/master_circle_controllers/frakh_controller/frakh_sasso_controller.dart';
import 'package:farkha_app/logic/controller/master_circle_controllers/katkit_controller/katkit_abid_controller.dart';
import 'package:farkha_app/logic/controller/master_circle_controllers/katkit_controller/katkit_baladi_controller.dart';
import 'package:farkha_app/logic/controller/master_circle_controllers/katkit_controller/katkit_sasso_controller.dart';
import 'package:get/get.dart';

class MyBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(
      FrakhAbidController(),
    );
        Get.put(
      FrakhAmihatAbidController(),
    );
        Get.put(
      FrakhBaladiController(),
    );
        Get.put(
      FrakhSassoController(),
    );
        Get.put(
      BydAbidController(),
    );
        Get.put(
      BydAihmarController(),
    );
        Get.put(
      BydBaladiController(),
    );
        Get.put(
      BatFiransawiController(),
    );
        Get.put(
      BatMaskufiController(),
    );
        Get.put(
      BatMolarController(),
    );
        Get.put(
      KatKitBaladiController(),
    );
        Get.put(
      KatKitAbidController(),
    );
        Get.put(
      KatKitSassoController(),
    );
     Get.put(
      A3lafController(),
    );
       Get.put(
      GetDateTime(),
    );
    
   
  }
}
