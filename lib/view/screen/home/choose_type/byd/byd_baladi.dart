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

class BydBaladi extends StatelessWidget {
  const BydBaladi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final upController = Get.find<DataUpBydController>();
    final downController = Get.find<DataDownBydController>();
    


    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: MyAppBar(
              text: 'بيض بلدي ',
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
                    upPrice1: upController.upBydBaladi[0].one,
                    downPrice1: downController.downBydBaladi[0].one,
                    upPrice2: upController.upBydBaladi[0].two,
                    downPrice2: downController.downBydBaladi[0].two,
                    upPrice3: upController.upBydBaladi[0].three,
                    downPrice3: downController.downBydBaladi[0].three,
                    upPrice4: upController.upBydBaladi[0].four,
                    downPrice4: downController.downBydBaladi[0].four,
                    upPrice5: upController.upBydBaladi[0].five, 
                    downPrice5: downController.downBydBaladi[0].five, 
                     upPrice6:upController.upBydBaladi[0].six ,
                    downPrice6: downController.downBydBaladi[0].six, 
                    upPrice7:upController.upBydBaladi[0].seven ,
                    downPrice7: downController.downBydBaladi[0].seven, 
                    upPrice8: upController.upBydBaladi[0].eight ,
                    downPrice8:  downController.downBydBaladi[0].eight,
                    upPrice9:  upController.upBydBaladi[0].nine,
                    downPrice9:downController.downBydBaladi[0].nine ,
                    upPrice10: upController.upBydBaladi[0].ten ,
                    downPrice10: downController.downBydBaladi[0].ten ,
                    upPrice11:  upController.upBydBaladi[0].eleven,
                    downPrice11: downController.downBydBaladi[0].eleven ,
                    upPrice12: upController.upBydBaladi[0].twelve,
                    downPrice12: downController.downBydBaladi[0].twelve ,
                    upPrice13: upController.upBydBaladi[0].thirteen ,
                    downPrice13: downController.downBydBaladi[0].thirteen ,
                    upPrice14: upController.upBydBaladi[0].fourteen ,
                    downPrice14: downController.downBydBaladi[0].fourteen,
                    upPrice15: upController.upBydBaladi[0].fifteen ,
                    downPrice15: downController.downBydBaladi[0].fifteen,
                    upPrice16:  upController.upBydBaladi[0].sixteen,
                    downPrice16: downController.downBydBaladi[0].sixteen ,
                    upPrice17: upController.upBydBaladi[0].seventeen,
                    downPrice17:  downController.downBydBaladi[0].seventeen,
                    upPrice18: upController.upBydBaladi[0].eightTeen,
                    downPrice18: downController.downBydBaladi[0].eightTeen,
                    upPrice19: upController.upBydBaladi[0].nineteen ,
                    downPrice19:downController.downBydBaladi[0].nine ,
                    upPrice20: upController.upBydBaladi[0].twenty ,
                    downPrice20: downController.downBydBaladi[0].twenty,
                    upPrice21:  upController.upBydBaladi[0].twentyOne,
                    downPrice21: downController.downBydBaladi[0].twentyOne  ,
                    upPrice22: upController.upBydBaladi[0].twentyTwo  ,
                    downPrice22:  downController.downBydBaladi[0].twentyTwo,
                    upPrice23: upController.upBydBaladi[0].twentyThree ,
                    downPrice23: downController.downBydBaladi[0].twentyThree ,
                    upPrice24: upController.upBydBaladi[0].twentyFour,
                    downPrice24: downController.downBydBaladi[0].twentyFour,
                    upPrice25: upController.upBydBaladi[0].twentyFive,
                    downPrice25:  downController.downBydBaladi[0].twentyFive,
                    upPrice26: upController.upBydBaladi[0].twentySix ,
                    downPrice26: downController.downBydBaladi[0].twentySix,
                    upPrice27: upController.upBydBaladi[0].twentySeven,
                    downPrice27: downController.downBydBaladi[0].twentySeven,
                    upPrice28: upController.upBydBaladi[0].twentyEight,
                    downPrice28: downController.downBydBaladi[0].twentyEight,
                    upPrice29: upController.upBydBaladi[0].twentyNine,
                     downPrice29:downController.downBydBaladi[0].twentyNine ,
                     upPrice30: upController.upBydBaladi[0].thirteen ,
                     downPrice30: downController.downBydBaladi[0].thirteen ,
                  );
                }
              },
            )));
  }
}
