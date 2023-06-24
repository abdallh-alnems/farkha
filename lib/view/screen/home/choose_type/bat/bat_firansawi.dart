import 'package:farkha_app/logic/controller/data_down_controller/data_down_bat_controller.dart';
import 'package:farkha_app/logic/controller/data_up_controller/data_up_bat_controller.dart';
import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:farkha_app/view/widget/app_bar/my_app_bar.dart';
import 'package:farkha_app/view/widget/home/circle_master/table_data/table_data.dart';
import 'package:farkha_app/view/widget/home/circle_master/table_data/text_date.dart';
import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BatFiransawi extends StatelessWidget {
  const BatFiransawi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final upController = Get.find<DataUpBatController>();
    final downController = Get.find<DataDownBatController>();

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: MyAppBar(
              text: 'بط فرنساوي ',
            ),
            body:  GetBuilder<DataUpBatController>(
              init: upController,
              builder: (_) {
                if (upController.upIsLoading.value &&
                    downController.downIsLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                } else {
                  return TableData(
                    upPrice1: upController.upBatFiransawi[0].one,
                    downPrice1: downController.downBatFiransawi[0].one,
                    upPrice2: upController.upBatFiransawi[0].two,
                    downPrice2: downController.downBatFiransawi[0].two,
                    upPrice3: upController.upBatFiransawi[0].three,
                    downPrice3: downController.downBatFiransawi[0].three,
                    upPrice4: upController.upBatFiransawi[0].four,
                    downPrice4: downController.downBatFiransawi[0].four,
                    upPrice5: upController.upBatFiransawi[0].five,
                    downPrice5: downController.downBatFiransawi[0].five,
                    upPrice6: upController.upBatFiransawi[0].six,
                    downPrice6: downController.downBatFiransawi[0].six,
                    upPrice7: upController.upBatFiransawi[0].seven,
                    downPrice7: downController.downBatFiransawi[0].seven,
                    upPrice8: upController.upBatFiransawi[0].eight,
                    downPrice8: downController.downBatFiransawi[0].eight,
                    upPrice9: upController.upBatFiransawi[0].nine,
                    downPrice9: downController.downBatFiransawi[0].nine,
                    upPrice10: upController.upBatFiransawi[0].ten,
                    downPrice10: downController.downBatFiransawi[0].ten,
                    upPrice11: upController.upBatFiransawi[0].eleven,
                    downPrice11: downController.downBatFiransawi[0].eleven,
                    upPrice12: upController.upBatFiransawi[0].twelve,
                    downPrice12: downController.downBatFiransawi[0].twelve,
                    upPrice13: upController.upBatFiransawi[0].thirteen,
                    downPrice13: downController.downBatFiransawi[0].thirteen,
                    upPrice14: upController.upBatFiransawi[0].fourteen,
                    downPrice14: downController.downBatFiransawi[0].fourteen,
                    upPrice15: upController.upBatFiransawi[0].fifteen,
                    downPrice15: downController.downBatFiransawi[0].fifteen,
                    upPrice16: upController.upBatFiransawi[0].sixteen,
                    downPrice16: downController.downBatFiransawi[0].sixteen,
                    upPrice17: upController.upBatFiransawi[0].seventeen,
                    downPrice17: downController.downBatFiransawi[0].seventeen,
                    upPrice18: upController.upBatFiransawi[0].eightTeen,
                    downPrice18: downController.downBatFiransawi[0].eightTeen,
                    upPrice19: upController.upBatFiransawi[0].nineteen,
                    downPrice19: downController.downBatFiransawi[0].nine,
                    upPrice20: upController.upBatFiransawi[0].twenty,
                    downPrice20: downController.downBatFiransawi[0].twenty,
                    upPrice21: upController.upBatFiransawi[0].twentyOne,
                    downPrice21: downController.downBatFiransawi[0].twentyOne,
                    upPrice22: upController.upBatFiransawi[0].twentyTwo,
                    downPrice22: downController.downBatFiransawi[0].twentyTwo,
                    upPrice23: upController.upBatFiransawi[0].twentyThree,
                    downPrice23: downController.downBatFiransawi[0].twentyThree,
                    upPrice24: upController.upBatFiransawi[0].twentyFour,
                    downPrice24: downController.downBatFiransawi[0].twentyFour,
                    upPrice25: upController.upBatFiransawi[0].twentyFive,
                    downPrice25: downController.downBatFiransawi[0].twentyFive,
                    upPrice26: upController.upBatFiransawi[0].twentySix,
                    downPrice26: downController.downBatFiransawi[0].twentySix,
                    upPrice27: upController.upBatFiransawi[0].twentySeven,
                    downPrice27: downController.downBatFiransawi[0].twentySeven,
                    upPrice28: upController.upBatFiransawi[0].twentyEight,
                    downPrice28: downController.downBatFiransawi[0].twentyEight,
                    upPrice29: upController.upBatFiransawi[0].twentyNine,
                    downPrice29: downController.downBatFiransawi[0].twentyNine,
                    upPrice30: upController.upBatFiransawi[0].thirteen,
                    downPrice30: downController.downBatFiransawi[0].thirteen,
                  );
                }
              },
            )));
  }
}
