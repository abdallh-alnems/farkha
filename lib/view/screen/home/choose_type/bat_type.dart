import 'package:farkha_app/logic/controller/data_controller/data_bat_controller.dart';
import 'package:farkha_app/view/widget/app_bar/my_app_bar.dart';
import 'package:farkha_app/view/widget/home/circle_master/card_data/card_data.dart';
import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BatType extends StatelessWidget {
  const BatType({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final controller = Get.find<DataBatController>();

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: MyAppBar(text: 'اسعار البط',),
            body: SingleChildScrollView(
              child: GetBuilder<DataBatController>(
                builder: (_) {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    );
                  } else {
                    return Column(
                      children: [
                        // frakh

                        CardViewData(
                          type: 'مولار',
                          price1: controller.batMolar[0].todayPrice,
                          price2: controller.batMolar[0].yesterdayPrice,
                          price3: controller.batMolar[0].firstYesterdayPrice,
                          price4: controller.batMolar[0].fourDaysAgoPrice,
                          price5: controller.batMolar[0].five,
                        ),
                        CardViewData(
                          price1: controller.batFiransawi[0].todayPrice,
                          price2: controller.batFiransawi[0].yesterdayPrice,
                          price3: controller.batFiransawi[0].firstYesterdayPrice,
                          price4: controller.batFiransawi[0].fourDaysAgoPrice,
                                                    price5: controller.batFiransawi[0].five,

                          type: 'فرنساوي',
                        ),
                        CardViewData(
                          price1: controller.batMaskufi[0].todayPrice,
                          price2: controller.batMaskufi[0].yesterdayPrice,
                          price3: controller.batMaskufi[0].firstYesterdayPrice,
                          price4: controller.batMaskufi[0].fourDaysAgoPrice,
                                                    price5: controller.batMaskufi[0].five,

                          type: 'مسكوفي',
                        ),
                        

                        Divider(
                          color: Colors.black,
                          height: 60,
                        ),
                      ],
                    );
                  }
                },
              ),
            )));
  }
}
