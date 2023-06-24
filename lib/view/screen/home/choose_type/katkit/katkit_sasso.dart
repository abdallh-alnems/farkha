import 'package:farkha_app/logic/controller/data_down_controller/data_down_katkit.dart';
import 'package:farkha_app/logic/controller/data_up_controller/data_up_katkit_controller.dart';
import 'package:farkha_app/view/widget/app_bar/my_app_bar.dart';
import 'package:farkha_app/view/widget/home/circle_master/table_data/table_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KatkitSasso extends StatelessWidget {
  const KatkitSasso({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final upController = Get.find<DataUpKatakitController>();
    final downController = Get.find<DataDownKatakitController>();
  

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: MyAppBar(
              text: 'كتاكيت ساسو ',
            ),
            body: GetBuilder<DataUpKatakitController>(
              builder: (_) {
                if (upController.upIsLoading.value &&
                    downController.downIsLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                } else  {
                  return TableData(
                    upPrice1: upController.upKatakitSasso[0].one,
                    downPrice1: downController.downKatakitSasso[0].one,
                    upPrice2: upController.upKatakitSasso[0].two,
                    downPrice2: downController.downKatakitSasso[0].two,
                    upPrice3: upController.upKatakitSasso[0].three,
                    downPrice3: downController.downKatakitSasso[0].three,
                    upPrice4: upController.upKatakitSasso[0].four,
                    downPrice4: downController.downKatakitSasso[0].four,
                    upPrice5: upController.upKatakitSasso[0].five,
                    downPrice5: downController.downKatakitSasso[0].five,
                    upPrice6: upController.upKatakitSasso[0].six,
                    downPrice6: downController.downKatakitSasso[0].six,
                    upPrice7: upController.upKatakitSasso[0].seven,
                    downPrice7: downController.downKatakitSasso[0].seven,
                    upPrice8: upController.upKatakitSasso[0].eight,
                    downPrice8: downController.downKatakitSasso[0].eight,
                    upPrice9: upController.upKatakitSasso[0].nine,
                    downPrice9: downController.downKatakitSasso[0].nine,
                    upPrice10: upController.upKatakitSasso[0].ten,
                    downPrice10: downController.downKatakitSasso[0].ten,
                    upPrice11: upController.upKatakitSasso[0].eleven,
                    downPrice11: downController.downKatakitSasso[0].eleven,
                    upPrice12: upController.upKatakitSasso[0].twelve,
                    downPrice12: downController.downKatakitSasso[0].twelve,
                    upPrice13: upController.upKatakitSasso[0].thirteen,
                    downPrice13: downController.downKatakitSasso[0].thirteen,
                    upPrice14: upController.upKatakitSasso[0].fourteen,
                    downPrice14: downController.downKatakitSasso[0].fourteen,
                    upPrice15: upController.upKatakitSasso[0].fifteen,
                    downPrice15: downController.downKatakitSasso[0].fifteen,
                    upPrice16: upController.upKatakitSasso[0].sixteen,
                    downPrice16: downController.downKatakitSasso[0].sixteen,
                    upPrice17: upController.upKatakitSasso[0].seventeen,
                    downPrice17: downController.downKatakitSasso[0].seventeen,
                    upPrice18: upController.upKatakitSasso[0].eightTeen,
                    downPrice18: downController.downKatakitSasso[0].eightTeen,
                    upPrice19: upController.upKatakitSasso[0].nineteen,
                    downPrice19: downController.downKatakitSasso[0].nine,
                    upPrice20: upController.upKatakitSasso[0].twenty,
                    downPrice20: downController.downKatakitSasso[0].twenty,
                    upPrice21: upController.upKatakitSasso[0].twentyOne,
                    downPrice21: downController.downKatakitSasso[0].twentyOne,
                    upPrice22: upController.upKatakitSasso[0].twentyTwo,
                    downPrice22: downController.downKatakitSasso[0].twentyTwo,
                    upPrice23: upController.upKatakitSasso[0].twentyThree,
                    downPrice23: downController.downKatakitSasso[0].twentyThree,
                    upPrice24: upController.upKatakitSasso[0].twentyFour,
                    downPrice24: downController.downKatakitSasso[0].twentyFour,
                    upPrice25: upController.upKatakitSasso[0].twentyFive,
                    downPrice25: downController.downKatakitSasso[0].twentyFive,
                    upPrice26: upController.upKatakitSasso[0].twentySix,
                    downPrice26: downController.downKatakitSasso[0].twentySix,
                    upPrice27: upController.upKatakitSasso[0].twentySeven,
                    downPrice27: downController.downKatakitSasso[0].twentySeven,
                    upPrice28: upController.upKatakitSasso[0].twentyEight,
                    downPrice28: downController.downKatakitSasso[0].twentyEight,
                    upPrice29: upController.upKatakitSasso[0].twentyNine,
                    downPrice29: downController.downKatakitSasso[0].twentyNine,
                    upPrice30: upController.upKatakitSasso[0].thirteen,
                    downPrice30: downController.downKatakitSasso[0].thirteen,
                  );
                }
              },
            )));
  }
}
