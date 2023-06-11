import 'package:farkha_app/logic/controller/data_controller/data_katkit_controller.dart';
import 'package:farkha_app/view/widget/app_bar/my_app_bar.dart';
import 'package:farkha_app/view/widget/home/circle_master/card_data/card_data.dart';
import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KatkitType extends StatelessWidget {
  const KatkitType({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataKatakitController>();

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: MyAppBar(
              text: 'اسعار الكتاكيت',
            ),
            body: SingleChildScrollView(
              child: GetBuilder<DataKatakitController>(
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
                          type: 'ابيض',
                          price1: controller.katakitAbid[0].todayPrice,
                          price2: controller.katakitAbid[0].yesterdayPrice,
                          price3: controller.katakitAbid[0].firstYesterdayPrice,
                          price4: controller.katakitAbid[0].fourDaysAgoPrice,
                          price5: controller.katakitAbid[0].five,
                        ),
                        CardViewData(
                          price1: controller.katakitSasso[0].todayPrice,
                          price2: controller.katakitSasso[0].yesterdayPrice,
                          price3:
                              controller.katakitSasso[0].firstYesterdayPrice,
                          price4: controller.katakitSasso[0].fourDaysAgoPrice,
                          price5: controller.katakitSasso[0].five,
                          type: 'ساسو',
                        ),
                        CardViewData(
                          price1: controller.katakitBaladi[0].todayPrice,
                          price2: controller.katakitBaladi[0].yesterdayPrice,
                          price3:
                              controller.katakitBaladi[0].firstYesterdayPrice,
                          price4: controller.katakitBaladi[0].fourDaysAgoPrice,
                          price5: controller.katakitBaladi[0].five,
                          type: 'بلدي',
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
