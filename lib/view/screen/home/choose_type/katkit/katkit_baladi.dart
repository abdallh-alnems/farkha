
import 'package:farkha_app/logic/controller/data_down_controller/data_down_katkit.dart';
import 'package:farkha_app/logic/controller/data_up_controller/data_up_katkit_controller.dart';
import 'package:farkha_app/view/widget/app_bar/my_app_bar.dart';
import 'package:farkha_app/view/widget/home/circle_master/table_data/table_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KatkitBaladi extends StatelessWidget {
  const KatkitBaladi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final upController = Get.find<DataUpKatakitController>();
    final downController = Get.find<DataDownKatakitController>();
  

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: MyAppBar(
              text: 'كتاكيت بلدي ',
            ),
            body: GetBuilder<DataUpKatakitController>(
              builder: (_)  {
                if (upController.upIsLoading.value &&
                    downController.downIsLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                } else {
                  return 
                     TableData(
                      upPrice1: upController.upKatakitBaladi[0].one,
                      downPrice1: downController.downKatakitBaladi[0].one,
                      upPrice2: upController.upKatakitBaladi[0].two,
                      downPrice2: downController.downKatakitBaladi[0].two,
                      upPrice3: upController.upKatakitBaladi[0].three,
                      downPrice3: downController.downKatakitBaladi[0].three,
                      upPrice4: upController.upKatakitBaladi[0].four,
                      downPrice4: downController.downKatakitBaladi[0].four,
                      upPrice5: upController.upKatakitBaladi[0].five,
                      downPrice5: downController.downKatakitBaladi[0].five,
                      upPrice6: upController.upKatakitBaladi[0].six,
                      downPrice6: downController.downKatakitBaladi[0].six,
                      upPrice7: upController.upKatakitBaladi[0].seven,
                      downPrice7: downController.downKatakitBaladi[0].seven,
                      upPrice8: upController.upKatakitBaladi[0].eight,
                      downPrice8: downController.downKatakitBaladi[0].eight,
                      upPrice9: upController.upKatakitBaladi[0].nine,
                      downPrice9: downController.downKatakitBaladi[0].nine,
                      upPrice10: upController.upKatakitBaladi[0].ten,
                      downPrice10: downController.downKatakitBaladi[0].ten,
                      upPrice11: upController.upKatakitBaladi[0].eleven,
                      downPrice11: downController.downKatakitBaladi[0].eleven,
                      upPrice12: upController.upKatakitBaladi[0].twelve,
                      downPrice12: downController.downKatakitBaladi[0].twelve,
                      upPrice13: upController.upKatakitBaladi[0].thirteen,
                      downPrice13: downController.downKatakitBaladi[0].thirteen,
                      upPrice14: upController.upKatakitBaladi[0].fourteen,
                      downPrice14: downController.downKatakitBaladi[0].fourteen,
                      upPrice15: upController.upKatakitBaladi[0].fifteen,
                      downPrice15: downController.downKatakitBaladi[0].fifteen,
                      upPrice16: upController.upKatakitBaladi[0].sixteen,
                      downPrice16: downController.downKatakitBaladi[0].sixteen,
                      upPrice17: upController.upKatakitBaladi[0].seventeen,
                      downPrice17: downController.downKatakitBaladi[0].seventeen,
                      upPrice18: upController.upKatakitBaladi[0].eightTeen,
                      downPrice18: downController.downKatakitBaladi[0].eightTeen,
                      upPrice19: upController.upKatakitBaladi[0].nineteen,
                      downPrice19: downController.downKatakitBaladi[0].nine,
                      upPrice20: upController.upKatakitBaladi[0].twenty,
                      downPrice20: downController.downKatakitBaladi[0].twenty,
                      upPrice21: upController.upKatakitBaladi[0].twentyOne,
                      downPrice21: downController.downKatakitBaladi[0].twentyOne,
                      upPrice22: upController.upKatakitBaladi[0].twentyTwo,
                      downPrice22: downController.downKatakitBaladi[0].twentyTwo,
                      upPrice23: upController.upKatakitBaladi[0].twentyThree,
                      downPrice23: downController.downKatakitBaladi[0].twentyThree,
                      upPrice24: upController.upKatakitBaladi[0].twentyFour,
                      downPrice24: downController.downKatakitBaladi[0].twentyFour,
                      upPrice25: upController.upKatakitBaladi[0].twentyFive,
                      downPrice25: downController.downKatakitBaladi[0].twentyFive,
                      upPrice26: upController.upKatakitBaladi[0].twentySix,
                      downPrice26: downController.downKatakitBaladi[0].twentySix,
                      upPrice27: upController.upKatakitBaladi[0].twentySeven,
                      downPrice27: downController.downKatakitBaladi[0].twentySeven,
                      upPrice28: upController.upKatakitBaladi[0].twentyEight,
                      downPrice28: downController.downKatakitBaladi[0].twentyEight,
                      upPrice29: upController.upKatakitBaladi[0].twentyNine,
                      downPrice29: downController.downKatakitBaladi[0].twentyNine,
                      upPrice30: upController.upKatakitBaladi[0].thirteen,
                      downPrice30: downController.downKatakitBaladi[0].thirteen,
                    
                  );
                }
              },
            )));
  }
}
