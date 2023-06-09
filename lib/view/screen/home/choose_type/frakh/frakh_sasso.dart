import 'package:farkha_app/logic/controller/master_circle_controllers/frakh_controller/frakh_sasso_controller.dart';
import 'package:farkha_app/utils/theme.dart';
import 'package:farkha_app/view/widget/app_bar/my_app_bar.dart';
import 'package:farkha_app/view/widget/home/circle_master/table_data/table_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:farkha_app/logic/controller/ad/ad_all_controller.dart';

class FrakhSasso extends StatelessWidget {
  const FrakhSasso({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final upController = Get.find<FrakhSassoController>();
final adController = Get.find<AdAllController>();
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: const MyAppBar(
              text: 'فراخ ساسو ',
            ),
            body: GetBuilder<FrakhSassoController>(
              builder: (_) {
                if (upController.upmyData != null &&
                    upController.downmyData != null) {
                  return TableDataMasterCircle(
                    upPrice1: upController.upmyData!.one,
                    downPrice1: upController.downmyData!.one,
                    upPrice2: upController.upmyData!.two,
                    downPrice2: upController.downmyData!.two,
                    upPrice3: upController.upmyData!.three,
                    downPrice3: upController.downmyData!.three,
                    upPrice4: upController.upmyData!.four,
                    downPrice4: upController.downmyData!.four,
                    upPrice5: upController.upmyData!.five,
                    downPrice5: upController.downmyData!.five,
                    upPrice6: upController.upmyData!.six,
                    downPrice6: upController.downmyData!.six,
                    upPrice7: upController.upmyData!.seven,
                    downPrice7: upController.downmyData!.seven,
                    upPrice8: upController.upmyData!.eight,
                    downPrice8: upController.downmyData!.eight,
                    upPrice9: upController.upmyData!.nine,
                    downPrice9: upController.downmyData!.nine,
                    upPrice10: upController.upmyData!.ten,
                    downPrice10: upController.downmyData!.ten,
                    upPrice11: upController.upmyData!.eleven,
                    downPrice11: upController.downmyData!.eleven,
                    upPrice12: upController.upmyData!.twelve,
                    downPrice12: upController.downmyData!.twelve,
                    upPrice13: upController.upmyData!.thirteen,
                    downPrice13: upController.downmyData!.thirteen,
                    upPrice14: upController.upmyData!.fourteen,
                    downPrice14: upController.downmyData!.fourteen,
                    upPrice15: upController.upmyData!.fifteen,
                    downPrice15: upController.downmyData!.fifteen,
                    upPrice16: upController.upmyData!.sixteen,
                    downPrice16: upController.downmyData!.sixteen,
                    upPrice17: upController.upmyData!.seventeen,
                    downPrice17: upController.downmyData!.seventeen,
                    upPrice18: upController.upmyData!.eightTeen,
                    downPrice18: upController.downmyData!.eightTeen,
                    upPrice19: upController.upmyData!.nineteen,
                    downPrice19: upController.downmyData!.nine,
                    upPrice20: upController.upmyData!.twenty,
                    downPrice20: upController.downmyData!.twenty,
                    upPrice21: upController.upmyData!.twentyOne,
                    downPrice21: upController.downmyData!.twentyOne,
                    upPrice22: upController.upmyData!.twentyTwo,
                    downPrice22: upController.downmyData!.twentyTwo,
                    upPrice23: upController.upmyData!.twentyThree,
                    downPrice23: upController.downmyData!.twentyThree,
                    upPrice24: upController.upmyData!.twentyFour,
                    downPrice24: upController.downmyData!.twentyFour,
                    upPrice25: upController.upmyData!.twentyFive,
                    downPrice25: upController.downmyData!.twentyFive,
                    upPrice26: upController.upmyData!.twentySix,
                    downPrice26: upController.downmyData!.twentySix,
                    upPrice27: upController.upmyData!.twentySeven,
                    downPrice27: upController.downmyData!.twentySeven,
                    upPrice28: upController.upmyData!.twentyEight,
                    downPrice28: upController.downmyData!.twentyEight,
                    upPrice29: upController.upmyData!.twentyNine,
                    downPrice29: upController.downmyData!.twentyNine,
                    upPrice30: upController.upmyData!.thirteen,
                    downPrice30: upController.downmyData!.thirteen,
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(color: scaColor),
                  );
                }
              },
            ),
            
            bottomNavigationBar: GetBuilder<AdAllController>(builder: (_) {
          return adController.isAdLoaded
              ? SizedBox(
                  height: adController.bannerAdAll.size.height.toDouble(),
                  width: adController.bannerAdAll.size.width.toDouble(),
                  child: AdWidget(ad: adController.bannerAdAll),
                )
              : const SizedBox();
        }),
            
            ),
            
            );
  }
}
