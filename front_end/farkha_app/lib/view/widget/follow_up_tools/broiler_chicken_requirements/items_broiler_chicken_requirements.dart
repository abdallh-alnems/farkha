import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/class/handling_data.dart';
import '../../../../core/constant/theme/color.dart';
import '../../../../core/constant/theme/image_asset.dart';
import '../../../../logic/controller/follow_up_tools_controller/broiler_chicken_requirements_controller.dart';
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
          return HandlingDataView(
            statusRequest: controller.statusRequest,
            widget: Column(
              children: [
                DetailsBroiler(),
                CardBroilerChickenRequirements(
                  text1:
                      "درجة الحرارة المطلوبة : °${controller.ageTemperature}",
                  text2: "درجة حرارة الطقس: °${controller.currentTemperature}",
                  image: ImageAsset.thermometer,
                ),
                CardBroilerChickenRequirements(
                  text1:
                      "المساحة المطلوبة : ${controller.requiredArea.toStringAsFixed(0)}م",
                  text2:
                      "المساحة الكلية : ${controller.collegeArea.toStringAsFixed(0)}م",
                  image: ImageAsset.chickenDensity,
                ),
                CardBroilerChickenRequirements(
                  text1: "نسبة الرطوبة هي : ${controller.ageHumidityRange}",
                  text2: "نسبة رطوبة الطقس : ${controller.currentHumidity}%",
                  image: ImageAsset.humidity,
                ),
                CardBroilerChickenRequirements(
                  text1: " سرعة الرياح : ${controller.currentWindSpeed}كم/ساعة",
                  image: ImageAsset.ventilation,
                  showText2: false,
                ),
                CardBroilerChickenRequirements(
                  text1:
                      "عدد ساعات الاظلام هي : ${controller.ageDarkness} ساعة",
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
                      " استهلاك العلف اليومي : ${controller.dailyFeedConsumption} جرام",
                  text2:
                      "استهلاك العلف الكلي : ${controller.totalFeedConsumption}كيلو",
                  image: ImageAsset.feed,
                ),
                Divider(
                  color: AppColor.primaryColor,
                  height: 0,
                  thickness: 1,
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(top: 35),
            child: Text('ادخل العدد والعمر'),
          );
        }
      }),
    );
  }
}
