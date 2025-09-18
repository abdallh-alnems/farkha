import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constant/image_asset.dart';
import '../../../../core/constant/theme/color.dart';
import '../../../../logic/controller/tools_controller/broiler_controller.dart';
import 'card_broiler_chicken_requirements.dart';
import 'details_broiler.dart';

class ItemsBroilerChickenRequirements extends GetView<BroilerController> {
  const ItemsBroilerChickenRequirements({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15).r,
      child: Obx(() {
        if (controller.showData.value) {
          return Column(
            children: [
              const DetailsBroiler(),
              CardBroilerChickenRequirements(
                text1: "درجة الحرارة المطلوبة : °${controller.ageTemperature}",
                image: ImageAsset.thermometer,
                showText2: false,
              ),
              CardBroilerChickenRequirements(
                text1:
                    "المساحة المطلوبة : ${controller.requiredArea.toStringAsFixed(0)}م",
                text2:
                    "المساحة الكلية : ${controller.collegeArea.toStringAsFixed(0)}م",
                image: ImageAsset.chickenDensity,
              ),
              CardBroilerChickenRequirements(
                text1: "نسبة الرطوبة المطلوبة : ${controller.ageHumidityRange}",
                image: ImageAsset.humidity,
                showText2: false,
              ),
              CardBroilerChickenRequirements(
                text1: "عدد ساعات الاظلام : ${controller.ageDarkness} ساعة",
                text2:
                    "عدد ساعات الاضاءة : ${24 - controller.ageDarkness} ساعة",
                image: ImageAsset.lighting,
              ),
              CardBroilerChickenRequirements(
                text1: "متوسط الوزن : ${controller.ageWeight} جرام",
                image: ImageAsset.weighing,
                showText2: false,
              ),
              CardBroilerChickenRequirements(
                text1:
                    "استهلاك العلف اليومي : ${_formatFeed(controller.dailyFeedConsumption)}",
                text2:
                    "استهلاك العلف الكلي : ${_formatTotalFeed(controller.totalFeedConsumption)}",
                image: ImageAsset.feed,
              ),
              const Divider(
                color: AppColor.primaryColor,
                height: 0,
                thickness: 1,
              ),
            ],
          );
        } else {
          return const Padding(
            padding: EdgeInsets.only(top: 35),
            child: Text('ادخل العدد والعمر'),
          );
        }
      }),
    );
  }

  String _formatFeed(int dailyFeed) {
    if (dailyFeed >= 1000) {
      double dailyFeedInKg = dailyFeed / 1000;
      return "${dailyFeedInKg.toStringAsFixed(1)} كيلو";
    } else {
      return "$dailyFeed جرام";
    }
  }

  String _formatTotalFeed(double totalFeed) {
    if (totalFeed >= 1000) {
      double totalFeedInTon = totalFeed / 1000;
      return "${totalFeedInTon.toStringAsFixed(1)} طن";
    } else {
      return "${totalFeed.toStringAsFixed(0)} كيلو";
    }
  }
}
