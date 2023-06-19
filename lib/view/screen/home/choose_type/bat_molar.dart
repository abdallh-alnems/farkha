import 'package:farkha_app/logic/controller/data_down_controller/data_down_bat_controller.dart';
import 'package:farkha_app/logic/controller/data_up_controller/data_up_bat_controller.dart';
import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:farkha_app/view/widget/app_bar/my_app_bar.dart';
import 'package:farkha_app/view/widget/home/circle_master/table_data/card_data.dart';
import 'package:farkha_app/view/widget/home/circle_master/table_data/table_data.dart';
import 'package:farkha_app/view/widget/home/circle_master/table_data/text_date.dart';
import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BatMolar extends StatelessWidget {
  const BatMolar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final upController = Get.find<DataUpBatController>();
    final downController = Get.find<DataDownBatController>();

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: MyAppBar(
              text: 'بط مولار ',
            ),
            body: GetBuilder<DataUpBatController>(
              builder: (_) {
                if (upController.upIsLoading.value ||
                    downController.downIsLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                } else {
                  return TableData(
                    upPrice1: upController.upBatMolar[0].one,
                    downPrice1: downController.downBatMolar[0].one,
                    upPrice2: upController.upBatMolar[0].two,
                    downPrice2: downController.downBatMolar[0].two,
                    upPrice3: upController.upBatMolar[0].three,
                    downPrice3: downController.downBatMolar[0].three,
                    upPrice4: upController.upBatMolar[0].four,
                    downPrice4: downController.downBatMolar[0].four,
                    upPrice5: upController.upBatMolar[0].five, 
                    downPrice5: downController.downBatMolar[0].five, 
                     upPrice6:upController.upBatMolar[0].six ,
                    downPrice6: downController.downBatMolar[0].six, 
                    upPrice7:upController.upBatMolar[0].seven ,
                    downPrice7: downController.downBatMolar[0].seven, 
                    upPrice8: upController.upBatMolar[0].eight ,
                    downPrice8:  downController.downBatMolar[0].eight,
                    upPrice9:  upController.upBatMolar[0].nine,
                    downPrice9:downController.downBatMolar[0].nine ,
                    upPrice10: upController.upBatMolar[0].ten ,
                    downPrice10: downController.downBatMolar[0].ten ,
                    upPrice11:  upController.upBatMolar[0].eleven,
                    downPrice11: downController.downBatMolar[0].eleven ,
                    upPrice12: upController.upBatMolar[0].twelve,
                    downPrice12: downController.downBatMolar[0].twelve ,
                    upPrice13: upController.upBatMolar[0].thirteen ,
                    downPrice13: downController.downBatMolar[0].thirteen ,
                    upPrice14: upController.upBatMolar[0].fourteen ,
                    downPrice14: downController.downBatMolar[0].fourteen,
                    upPrice15: upController.upBatMolar[0].fifteen ,
                    downPrice15: downController.downBatMolar[0].fifteen,
                    upPrice16:  upController.upBatMolar[0].sixteen,
                    downPrice16: downController.downBatMolar[0].sixteen ,
                    upPrice17: upController.upBatMolar[0].seventeen,
                    downPrice17:  downController.downBatMolar[0].seventeen,
                    upPrice18: upController.upBatMolar[0].eightTeen,
                    downPrice18: downController.downBatMolar[0].eightTeen,
                    upPrice19: upController.upBatMolar[0].nineteen ,
                    downPrice19:downController.downBatMolar[0].nine ,
                    upPrice20: upController.upBatMolar[0].twenty ,
                    downPrice20: downController.downBatMolar[0].twenty,
                    upPrice21:  upController.upBatMolar[0].twentyOne,
                    downPrice21: downController.downBatMolar[0].twentyOne  ,
                    upPrice22: upController.upBatMolar[0].twentyTwo  ,
                    downPrice22:  downController.downBatMolar[0].twentyTwo,
                    upPrice23: upController.upBatMolar[0].twentyThree ,
                    downPrice23: downController.downBatMolar[0].twentyThree ,
                    upPrice24: upController.upBatMolar[0].twentyFour,
                    downPrice24: downController.downBatMolar[0].twentyFour,
                    upPrice25: upController.upBatMolar[0].twentyFive,
                    downPrice25:  downController.downBatMolar[0].twentyFive,
                    upPrice26: upController.upBatMolar[0].twentySix ,
                    downPrice26: downController.downBatMolar[0].twentySix,
                    upPrice27: upController.upBatMolar[0].twentySeven,
                    downPrice27: downController.downBatMolar[0].twentySeven,
                    upPrice28: upController.upBatMolar[0].twentyEight,
                    downPrice28: downController.downBatMolar[0].twentyEight,
                    upPrice29: upController.upBatMolar[0].twentyNine,
                     downPrice29:downController.downBatMolar[0].twentyNine ,
                     upPrice30: upController.upBatMolar[0].thirteen ,
                     downPrice30: downController.downBatMolar[0].thirteen ,
                  );
                }
              },
            )));
  }
}
