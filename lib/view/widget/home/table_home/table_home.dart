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
import 'package:farkha_app/utils/theme.dart';
import 'package:farkha_app/view/widget/home/table_home/table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TableHome extends StatelessWidget {
  const TableHome({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final frakhAbid = Get.find<FrakhAbidController>();
    final frakhAmihatAbid = Get.find<FrakhAmihatAbidController>();
    final frakhBaladi = Get.find<FrakhBaladiController>();
    final frakhSasso = Get.find<FrakhSassoController>();
    final bydAbid = Get.find<BydAbidController>();
    final bydAihmar = Get.find<BydAihmarController>();
    final bydBaladi = Get.find<BydBaladiController>();
    final katkitBaladi = Get.find<KatKitBaladiController>();
    final katkitAbid = Get.find<KatKitAbidController>();
    final katkitSasso = Get.find<KatKitSassoController>();
    final batMaskufi = Get.find<BatMaskufiController>();
    final batMolar = Get.find<BatMolarController>();
    final batFiransawi = Get.find<BatFiransawiController>();

    return GetBuilder<BatFiransawiController>(
              builder: (_) {
                if (frakhAbid.upmyData != null &&
                    frakhAbid.downmyData != null &&
                    frakhAmihatAbid.upmyData != null &&
                    frakhAmihatAbid.downmyData != null &&
                    frakhBaladi.upmyData != null &&
                    frakhBaladi.downmyData != null &&
                    frakhSasso.upmyData != null &&
                    frakhSasso.downmyData != null &&
                    bydAbid.upmyData != null &&
                    bydAbid.downmyData != null &&
                    bydAihmar.upmyData != null &&
                    bydAihmar.downmyData != null &&
                    bydBaladi.upmyData != null &&
                    bydBaladi.downmyData != null &&
                    katkitBaladi.upmyData != null &&
                    katkitBaladi.downmyData != null &&
                    katkitAbid.upmyData != null &&
                    katkitAbid.downmyData != null &&
                    katkitSasso.upmyData != null &&
                    katkitSasso.downmyData != null &&
                    batMaskufi.upmyData != null &&
                    batMaskufi.downmyData != null &&
                    batMolar.upmyData != null &&
                    batMolar.downmyData != null &&
                    batFiransawi.upmyData != null &&
                    batFiransawi.downmyData != null 
                    
) {
                  return TableDataHome(
      //frakh
      yUpFrakhAbid: frakhAbid.upmyData!.two,
      upFrakhAbid: frakhAbid.upmyData!.one,
      downFrakhAbid: frakhAbid.downmyData!.one,
      yUpFrakhBaladi: frakhBaladi.upmyData!.two,
      upFrakhBaladi: frakhBaladi.upmyData!.one,
      downFrakhBaladi: frakhBaladi.downmyData!.one,
      yUpFrakhSasso: frakhSasso.upmyData!.two,
      upFrakhSasso: frakhSasso.upmyData!.one,
      downFrakhSasso: frakhSasso.downmyData!.one,
      yUpFrakhAmihatAbid: frakhAmihatAbid.upmyData!.two,
      upFrakhAmihatAbid: frakhAmihatAbid.upmyData!.one,
      downFrakhAmihatAbid: frakhAmihatAbid.downmyData!.one,

      //bat
      yUpBatFiransawi: batFiransawi.upmyData!.two,
      upBatFiransawi: batFiransawi.upmyData!.one,
      downBatFiransawi: batFiransawi.downmyData!.one,
      yUpBatMolar: batMolar.upmyData!.two,
      upBatMolar: batMolar.upmyData!.one,
      downBatMolar: batMolar.downmyData!.one,
      yUpBatMaskufi: batMaskufi.upmyData!.two,
      upBatMaskufi: batMaskufi.upmyData!.one,
      downBatMaskufi: batMaskufi.downmyData!.one,

     //byd
     yUpBydAbid: bydAbid.upmyData!.two,
      upBydAbid: bydAbid.upmyData!.one,
      downBydAbid: bydAbid.downmyData!.one,
      yUpBydAihmar: bydAihmar.upmyData!.two,
      upBydAihmar: bydAihmar.upmyData!.one,
      downBydAihmar: bydAihmar.downmyData!.one,
      yUpBydBaladi: bydBaladi.upmyData!.two,
      upBydBaladi: bydBaladi.upmyData!.one,
      downBydBaladi: bydBaladi.downmyData!.one,


     //katkit
     yUpKatkitAbid: katkitAbid.upmyData!.two,
      upKatkitAbid: katkitAbid.upmyData!.one,
      downKatkitAbid: katkitAbid.downmyData!.one,
      yUpKatkitBaladi: katkitBaladi.upmyData!.two,
      upKatkitBaladi: katkitBaladi.upmyData!.one,
      downKatkitBaladi: katkitBaladi.downmyData!.one,
      yUpKatkitSasso: katkitSasso.upmyData!.two,
      upKatkitSasso: katkitSasso.upmyData!.one,
      downKatkitSasso: katkitSasso.downmyData!.one,
    );
    }else {
                  return const Center(
                    child: CircularProgressIndicator(color: mainColor),
                  ); 
  }
              }
    );
  }
}
