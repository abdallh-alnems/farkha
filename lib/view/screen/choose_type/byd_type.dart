import 'package:farkha_app/logic/controller/data_controller/data_byd_controller.dart';
import 'package:farkha_app/view/widget/home/circle_master/card_data/card_data.dart';
import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BydType extends StatelessWidget {
  const BydType({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DataBydController>();

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              centerTitle: true,
              title: TextUtils(
                text: 'اسعار البيض',
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 40,
                ),
                onPressed: () {
                  Get.back();
                },
              ),
            ),
            body: SingleChildScrollView(
              child: GetBuilder<DataBydController>(
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
                          price1: controller.bydAbid[0].todayPrice,
                          price2: controller.bydAbid[0].yesterdayPrice,
                          price3: controller.bydAbid[0].firstYesterdayPrice,
                          price4: controller.bydAbid[0].fourDaysAgoPrice,
                           price5: controller.bydAbid[0].five,

                        ),
                        CardViewData(
                          price1: controller.bydAihmar[0].todayPrice,
                          price2: controller.bydAihmar[0].yesterdayPrice,
                          price3: controller.bydAihmar[0].firstYesterdayPrice,
                          price4: controller.bydAihmar[0].fourDaysAgoPrice,
                          price5: controller.bydAihmar[0].five,
                          type: 'احمر',
                        ),
                        CardViewData(
                          price1: controller.bydBaladi[0].todayPrice,
                          price2: controller.bydBaladi[0].yesterdayPrice,
                          price3: controller.bydBaladi[0].firstYesterdayPrice,
                          price4: controller.bydBaladi[0].fourDaysAgoPrice,
                          price5: controller.bydBaladi[0].five,
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
