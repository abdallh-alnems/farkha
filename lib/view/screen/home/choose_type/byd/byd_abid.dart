import 'package:farkha_app/logic/controller/data_down_controller/data_down_byd_controller.dart';
import 'package:farkha_app/logic/controller/data_up_controller/data_up_byd_controller.dart';
import 'package:farkha_app/view/widget/app_bar/my_app_bar.dart';
import 'package:farkha_app/view/widget/home/circle_master/table_data/table_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BydAbid extends StatelessWidget {
  const BydAbid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final upController = Get.find<DataUpBydController>();
    final downController = Get.find<DataDownBydController>();
  

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: MyAppBar(
              text: 'بيض ابيض ',
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
                    upPrice1: upController.upBydAbid[0].one,
                    downPrice1: downController.downBydAbid[0].one,
                    upPrice2: upController.upBydAbid[0].two,
                    downPrice2: downController.downBydAbid[0].two,
                    upPrice3: upController.upBydAbid[0].three,
                    downPrice3: downController.downBydAbid[0].three,
                    upPrice4: upController.upBydAbid[0].four,
                    downPrice4: downController.downBydAbid[0].four,
                    upPrice5: upController.upBydAbid[0].five,
                    downPrice5: downController.downBydAbid[0].five,
                    upPrice6: upController.upBydAbid[0].six,
                    downPrice6: downController.downBydAbid[0].six,
                    upPrice7: upController.upBydAbid[0].seven,
                    downPrice7: downController.downBydAbid[0].seven,
                    upPrice8: upController.upBydAbid[0].eight,
                    downPrice8: downController.downBydAbid[0].eight,
                    upPrice9: upController.upBydAbid[0].nine,
                    downPrice9: downController.downBydAbid[0].nine,
                    upPrice10: upController.upBydAbid[0].ten,
                    downPrice10: downController.downBydAbid[0].ten,
                    upPrice11: upController.upBydAbid[0].eleven,
                    downPrice11: downController.downBydAbid[0].eleven,
                    upPrice12: upController.upBydAbid[0].twelve,
                    downPrice12: downController.downBydAbid[0].twelve,
                    upPrice13: upController.upBydAbid[0].thirteen,
                    downPrice13: downController.downBydAbid[0].thirteen,
                    upPrice14: upController.upBydAbid[0].fourteen,
                    downPrice14: downController.downBydAbid[0].fourteen,
                    upPrice15: upController.upBydAbid[0].fifteen,
                    downPrice15: downController.downBydAbid[0].fifteen,
                    upPrice16: upController.upBydAbid[0].sixteen,
                    downPrice16: downController.downBydAbid[0].sixteen,
                    upPrice17: upController.upBydAbid[0].seventeen,
                    downPrice17: downController.downBydAbid[0].seventeen,
                    upPrice18: upController.upBydAbid[0].eightTeen,
                    downPrice18: downController.downBydAbid[0].eightTeen,
                    upPrice19: upController.upBydAbid[0].nineteen,
                    downPrice19: downController.downBydAbid[0].nine,
                    upPrice20: upController.upBydAbid[0].twenty,
                    downPrice20: downController.downBydAbid[0].twenty,
                    upPrice21: upController.upBydAbid[0].twentyOne,
                    downPrice21: downController.downBydAbid[0].twentyOne,
                    upPrice22: upController.upBydAbid[0].twentyTwo,
                    downPrice22: downController.downBydAbid[0].twentyTwo,
                    upPrice23: upController.upBydAbid[0].twentyThree,
                    downPrice23: downController.downBydAbid[0].twentyThree,
                    upPrice24: upController.upBydAbid[0].twentyFour,
                    downPrice24: downController.downBydAbid[0].twentyFour,
                    upPrice25: upController.upBydAbid[0].twentyFive,
                    downPrice25: downController.downBydAbid[0].twentyFive,
                    upPrice26: upController.upBydAbid[0].twentySix,
                    downPrice26: downController.downBydAbid[0].twentySix,
                    upPrice27: upController.upBydAbid[0].twentySeven,
                    downPrice27: downController.downBydAbid[0].twentySeven,
                    upPrice28: upController.upBydAbid[0].twentyEight,
                    downPrice28: downController.downBydAbid[0].twentyEight,
                    upPrice29: upController.upBydAbid[0].twentyNine,
                    downPrice29: downController.downBydAbid[0].twentyNine,
                    upPrice30: upController.upBydAbid[0].thirteen,
                    downPrice30: downController.downBydAbid[0].thirteen,
                  );
                }
              },
            )));
  }
}
