import 'package:farkha_app/logic/controller/data_controller/data_frakh_controller.dart';
import 'package:farkha_app/utils/theme.dart';
import 'package:farkha_app/view/widget/home/circle_master/card_data/card_data.dart';
import 'package:farkha_app/view/widget/home/drawer/my_drawer.dart';
import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FrakhType extends StatelessWidget {
  const FrakhType({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataFrakhController>();

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              centerTitle: true,
              title: TextUtils(
                text: 'اسعار الفراخ',
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.cyan,
                  size: 40,
                ),
                onPressed: () {
                  Get.back();
                },
              ),
            ),
            body: SingleChildScrollView(
              child: GetBuilder<DataFrakhController>(
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
                          price1: controller.frakhAbid[0].todayPrice,
                          price2: controller.frakhAbid[0].yesterdayPrice,
                          price3: controller.frakhAbid[0].firstYesterdayPrice,
                          price4: controller.frakhAbid[0].fourDaysAgoPrice,
                          price5: controller.frakhAbid[0].five,
                        ),
                        CardViewData(
                          price1: controller.frakhSasso[0].todayPrice,
                          price2: controller.frakhSasso[0].yesterdayPrice,
                          price3: controller.frakhSasso[0].firstYesterdayPrice,
                          price4: controller.frakhSasso[0].fourDaysAgoPrice,
                          price5: controller.frakhSasso[0].five,
                          type: 'ساسو',
                        ),
                        CardViewData(
                          price1: controller.frakhBaladi[0].todayPrice,
                          price2: controller.frakhBaladi[0].yesterdayPrice,
                          price3: controller.frakhBaladi[0].firstYesterdayPrice,
                          price4: controller.frakhBaladi[0].fourDaysAgoPrice,
                          price5: controller.frakhBaladi[0].five,
                          type: 'بلدي',
                        ),
                        CardViewData(
                          price1: controller.frakhAmihatAbid[0].todayPrice,
                          price2: controller.frakhAmihatAbid[0].yesterdayPrice,
                          price3:
                              controller.frakhAmihatAbid[0].firstYesterdayPrice,
                          price4:
                              controller.frakhAmihatAbid[0].fourDaysAgoPrice,
                          price5: controller.frakhAmihatAbid[0].five,
                          type: 'امهات ابيض',
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
