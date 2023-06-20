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

class BatMaskufi extends StatelessWidget {
  const BatMaskufi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final upController = Get.find<DataUpBatController>();
    final downController = Get.find<DataDownBatController>();

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: MyAppBar(
              text: 'بط مسكوفي ',
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
                    upPrice1: upController.upBatMaskufi[0].one,
                    downPrice1: downController.downBatMaskufi[0].one,
                    upPrice2: upController.upBatMaskufi[0].two,
                    downPrice2: downController.downBatMaskufi[0].two,
                    upPrice3: upController.upBatMaskufi[0].three,
                    downPrice3: downController.downBatMaskufi[0].three,
                    upPrice4: upController.upBatMaskufi[0].four,
                    downPrice4: downController.downBatMaskufi[0].four,
                    upPrice5: upController.upBatMaskufi[0].five, 
                    downPrice5: downController.downBatMaskufi[0].five, 
                     upPrice6:upController.upBatMaskufi[0].six ,
                    downPrice6: downController.downBatMaskufi[0].six, 
                    upPrice7:upController.upBatMaskufi[0].seven ,
                    downPrice7: downController.downBatMaskufi[0].seven, 
                    upPrice8: upController.upBatMaskufi[0].eight ,
                    downPrice8:  downController.downBatMaskufi[0].eight,
                    upPrice9:  upController.upBatMaskufi[0].nine,
                    downPrice9:downController.downBatMaskufi[0].nine ,
                    upPrice10: upController.upBatMaskufi[0].ten ,
                    downPrice10: downController.downBatMaskufi[0].ten ,
                    upPrice11:  upController.upBatMaskufi[0].eleven,
                    downPrice11: downController.downBatMaskufi[0].eleven ,
                    upPrice12: upController.upBatMaskufi[0].twelve,
                    downPrice12: downController.downBatMaskufi[0].twelve ,
                    upPrice13: upController.upBatMaskufi[0].thirteen ,
                    downPrice13: downController.downBatMaskufi[0].thirteen ,
                    upPrice14: upController.upBatMaskufi[0].fourteen ,
                    downPrice14: downController.downBatMaskufi[0].fourteen,
                    upPrice15: upController.upBatMaskufi[0].fifteen ,
                    downPrice15: downController.downBatMaskufi[0].fifteen,
                    upPrice16:  upController.upBatMaskufi[0].sixteen,
                    downPrice16: downController.downBatMaskufi[0].sixteen ,
                    upPrice17: upController.upBatMaskufi[0].seventeen,
                    downPrice17:  downController.downBatMaskufi[0].seventeen,
                    upPrice18: upController.upBatMaskufi[0].eightTeen,
                    downPrice18: downController.downBatMaskufi[0].eightTeen,
                    upPrice19: upController.upBatMaskufi[0].nineteen ,
                    downPrice19:downController.downBatMaskufi[0].nine ,
                    upPrice20: upController.upBatMaskufi[0].twenty ,
                    downPrice20: downController.downBatMaskufi[0].twenty,
                    upPrice21:  upController.upBatMaskufi[0].twentyOne,
                    downPrice21: downController.downBatMaskufi[0].twentyOne  ,
                    upPrice22: upController.upBatMaskufi[0].twentyTwo  ,
                    downPrice22:  downController.downBatMaskufi[0].twentyTwo,
                    upPrice23: upController.upBatMaskufi[0].twentyThree ,
                    downPrice23: downController.downBatMaskufi[0].twentyThree ,
                    upPrice24: upController.upBatMaskufi[0].twentyFour,
                    downPrice24: downController.downBatMaskufi[0].twentyFour,
                    upPrice25: upController.upBatMaskufi[0].twentyFive,
                    downPrice25:  downController.downBatMaskufi[0].twentyFive,
                    upPrice26: upController.upBatMaskufi[0].twentySix ,
                    downPrice26: downController.downBatMaskufi[0].twentySix,
                    upPrice27: upController.upBatMaskufi[0].twentySeven,
                    downPrice27: downController.downBatMaskufi[0].twentySeven,
                    upPrice28: upController.upBatMaskufi[0].twentyEight,
                    downPrice28: downController.downBatMaskufi[0].twentyEight,
                    upPrice29: upController.upBatMaskufi[0].twentyNine,
                     downPrice29:downController.downBatMaskufi[0].twentyNine ,
                     upPrice30: upController.upBatMaskufi[0].thirteen ,
                     downPrice30: downController.downBatMaskufi[0].thirteen ,
                  );
                }
              },
            )));
  }
}
