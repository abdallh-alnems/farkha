import 'package:farkha_app/logic/controller/data_down_controller/data_down_bat_controller.dart';
import 'package:farkha_app/logic/controller/data_down_controller/data_down_byd_controller.dart';
import 'package:farkha_app/logic/controller/data_up_controller/data_up_bat_controller.dart';
import 'package:farkha_app/logic/controller/data_up_controller/data_up_byd_controller.dart';
import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:farkha_app/view/widget/app_bar/my_app_bar.dart';
import 'package:farkha_app/view/widget/home/circle_master/table_data/table_data.dart';
import 'package:farkha_app/view/widget/home/circle_master/table_data/text_date.dart';
import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BydAihmar extends StatelessWidget {
  const BydAihmar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final upController = Get.find<DataUpBydController>();
    final downController = Get.find<DataDownBydController>();
    

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: MyAppBar(
              text: 'بيض احمر ',
            ),
            body: GetBuilder<DataUpBydController>(
              builder: (_) {
                if (upController.upIsLoading.value ||
                    downController.downIsLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                } else {
                  return TableData(
                    upPrice1: upController.upBydAihmar[0].one,
                    downPrice1: downController.downBydAihmar[0].one,
                    upPrice2: upController.upBydAihmar[0].two,
                    downPrice2: downController.downBydAihmar[0].two,
                    upPrice3: upController.upBydAihmar[0].three,
                    downPrice3: downController.downBydAihmar[0].three,
                    upPrice4: upController.upBydAihmar[0].four,
                    downPrice4: downController.downBydAihmar[0].four,
                    upPrice5: upController.upBydAihmar[0].five, 
                    downPrice5: downController.downBydAihmar[0].five, 
                     upPrice6:upController.upBydAihmar[0].six ,
                    downPrice6: downController.downBydAihmar[0].six, 
                    upPrice7:upController.upBydAihmar[0].seven ,
                    downPrice7: downController.downBydAihmar[0].seven, 
                    upPrice8: upController.upBydAihmar[0].eight ,
                    downPrice8:  downController.downBydAihmar[0].eight,
                    upPrice9:  upController.upBydAihmar[0].nine,
                    downPrice9:downController.downBydAihmar[0].nine ,
                    upPrice10: upController.upBydAihmar[0].ten ,
                    downPrice10: downController.downBydAihmar[0].ten ,
                    upPrice11:  upController.upBydAihmar[0].eleven,
                    downPrice11: downController.downBydAihmar[0].eleven ,
                    upPrice12: upController.upBydAihmar[0].twelve,
                    downPrice12: downController.downBydAihmar[0].twelve ,
                    upPrice13: upController.upBydAihmar[0].thirteen ,
                    downPrice13: downController.downBydAihmar[0].thirteen ,
                    upPrice14: upController.upBydAihmar[0].fourteen ,
                    downPrice14: downController.downBydAihmar[0].fourteen,
                    upPrice15: upController.upBydAihmar[0].fifteen ,
                    downPrice15: downController.downBydAihmar[0].fifteen,
                    upPrice16:  upController.upBydAihmar[0].sixteen,
                    downPrice16: downController.downBydAihmar[0].sixteen ,
                    upPrice17: upController.upBydAihmar[0].seventeen,
                    downPrice17:  downController.downBydAihmar[0].seventeen,
                    upPrice18: upController.upBydAihmar[0].eightTeen,
                    downPrice18: downController.downBydAihmar[0].eightTeen,
                    upPrice19: upController.upBydAihmar[0].nineteen ,
                    downPrice19:downController.downBydAihmar[0].nine ,
                    upPrice20: upController.upBydAihmar[0].twenty ,
                    downPrice20: downController.downBydAihmar[0].twenty,
                    upPrice21:  upController.upBydAihmar[0].twentyOne,
                    downPrice21: downController.downBydAihmar[0].twentyOne  ,
                    upPrice22: upController.upBydAihmar[0].twentyTwo  ,
                    downPrice22:  downController.downBydAihmar[0].twentyTwo,
                    upPrice23: upController.upBydAihmar[0].twentyThree ,
                    downPrice23: downController.downBydAihmar[0].twentyThree ,
                    upPrice24: upController.upBydAihmar[0].twentyFour,
                    downPrice24: downController.downBydAihmar[0].twentyFour,
                    upPrice25: upController.upBydAihmar[0].twentyFive,
                    downPrice25:  downController.downBydAihmar[0].twentyFive,
                    upPrice26: upController.upBydAihmar[0].twentySix ,
                    downPrice26: downController.downBydAihmar[0].twentySix,
                    upPrice27: upController.upBydAihmar[0].twentySeven,
                    downPrice27: downController.downBydAihmar[0].twentySeven,
                    upPrice28: upController.upBydAihmar[0].twentyEight,
                    downPrice28: downController.downBydAihmar[0].twentyEight,
                    upPrice29: upController.upBydAihmar[0].twentyNine,
                     downPrice29:downController.downBydAihmar[0].twentyNine ,
                     upPrice30: upController.upBydAihmar[0].thirteen ,
                     downPrice30: downController.downBydAihmar[0].thirteen ,
                  );
                }
              },
            )));
  }
}
