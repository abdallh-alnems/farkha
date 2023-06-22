
import 'package:farkha_app/logic/controller/data_down_controller/data_down_katkit.dart';
import 'package:farkha_app/logic/controller/data_up_controller/data_up_katkit_controller.dart';
import 'package:farkha_app/view/widget/app_bar/my_app_bar.dart';
import 'package:farkha_app/view/widget/home/circle_master/table_data/table_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KatKitAbid extends StatelessWidget {
  const KatKitAbid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final upController = Get.find<DataUpKatakitController>();
    final downController = Get.find<DataDownKatakitController>();
  

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: MyAppBar(
              text: 'كتاكيت ابيض ',
            ),
            body: GetBuilder<DataUpKatakitController>(
              builder: (_) {
                if (upController.upIsLoading.value ||
                    downController.downIsLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                } else {
                  return TableData(
                    upPrice1: upController.upKatakitAbid[0].one,
                    downPrice1: downController.downKatakitAbid[0].one,
                    upPrice2: upController.upKatakitAbid[0].two,
                    downPrice2: downController.downKatakitAbid[0].two,
                    upPrice3: upController.upKatakitAbid[0].three,
                    downPrice3: downController.downKatakitAbid[0].three,
                    upPrice4: upController.upKatakitAbid[0].four,
                    downPrice4: downController.downKatakitAbid[0].four,
                    upPrice5: upController.upKatakitAbid[0].five,
                    downPrice5: downController.downKatakitAbid[0].five,
                    upPrice6: upController.upKatakitAbid[0].six,
                    downPrice6: downController.downKatakitAbid[0].six,
                    upPrice7: upController.upKatakitAbid[0].seven,
                    downPrice7: downController.downKatakitAbid[0].seven,
                    upPrice8: upController.upKatakitAbid[0].eight,
                    downPrice8: downController.downKatakitAbid[0].eight,
                    upPrice9: upController.upKatakitAbid[0].nine,
                    downPrice9: downController.downKatakitAbid[0].nine,
                    upPrice10: upController.upKatakitAbid[0].ten,
                    downPrice10: downController.downKatakitAbid[0].ten,
                    upPrice11: upController.upKatakitAbid[0].eleven,
                    downPrice11: downController.downKatakitAbid[0].eleven,
                    upPrice12: upController.upKatakitAbid[0].twelve,
                    downPrice12: downController.downKatakitAbid[0].twelve,
                    upPrice13: upController.upKatakitAbid[0].thirteen,
                    downPrice13: downController.downKatakitAbid[0].thirteen,
                    upPrice14: upController.upKatakitAbid[0].fourteen,
                    downPrice14: downController.downKatakitAbid[0].fourteen,
                    upPrice15: upController.upKatakitAbid[0].fifteen,
                    downPrice15: downController.downKatakitAbid[0].fifteen,
                    upPrice16: upController.upKatakitAbid[0].sixteen,
                    downPrice16: downController.downKatakitAbid[0].sixteen,
                    upPrice17: upController.upKatakitAbid[0].seventeen,
                    downPrice17: downController.downKatakitAbid[0].seventeen,
                    upPrice18: upController.upKatakitAbid[0].eightTeen,
                    downPrice18: downController.downKatakitAbid[0].eightTeen,
                    upPrice19: upController.upKatakitAbid[0].nineteen,
                    downPrice19: downController.downKatakitAbid[0].nine,
                    upPrice20: upController.upKatakitAbid[0].twenty,
                    downPrice20: downController.downKatakitAbid[0].twenty,
                    upPrice21: upController.upKatakitAbid[0].twentyOne,
                    downPrice21: downController.downKatakitAbid[0].twentyOne,
                    upPrice22: upController.upKatakitAbid[0].twentyTwo,
                    downPrice22: downController.downKatakitAbid[0].twentyTwo,
                    upPrice23: upController.upKatakitAbid[0].twentyThree,
                    downPrice23: downController.downKatakitAbid[0].twentyThree,
                    upPrice24: upController.upKatakitAbid[0].twentyFour,
                    downPrice24: downController.downKatakitAbid[0].twentyFour,
                    upPrice25: upController.upKatakitAbid[0].twentyFive,
                    downPrice25: downController.downKatakitAbid[0].twentyFive,
                    upPrice26: upController.upKatakitAbid[0].twentySix,
                    downPrice26: downController.downKatakitAbid[0].twentySix,
                    upPrice27: upController.upKatakitAbid[0].twentySeven,
                    downPrice27: downController.downKatakitAbid[0].twentySeven,
                    upPrice28: upController.upKatakitAbid[0].twentyEight,
                    downPrice28: downController.downKatakitAbid[0].twentyEight,
                    upPrice29: upController.upKatakitAbid[0].twentyNine,
                    downPrice29: downController.downKatakitAbid[0].twentyNine,
                    upPrice30: upController.upKatakitAbid[0].thirteen,
                    downPrice30: downController.downKatakitAbid[0].thirteen,
                  );
                }
              },
            )));
  }
}
