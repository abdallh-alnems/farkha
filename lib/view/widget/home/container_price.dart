import 'package:farkha_app/logic/controller/data_controller/data_frakh_controller.dart';
import 'package:farkha_app/utils/theme.dart';
import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContainerPrice extends StatelessWidget {
  ContainerPrice({super.key});
  final controller = Get.find<DataFrakhController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scaColor,
      height: 100,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTodayPrice(),
          _buildWhiteMeatPrice(),
        ],
      ),
    );
  }

  Widget _buildTodayPrice() {
    return Container(
      alignment: Alignment.center,
      height: 40,
      width: 90,
      color: Colors.white,
      child: GetBuilder<DataFrakhController>(
        builder: (controller) {
          if (controller.frakhAbid.isNotEmpty) {
            return TextUtils(
              text: controller.frakhAbid[0].todayPrice,
              fontSize: 25,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            );
          } else {
            return TextUtils(
              text: 'انتظر',
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            );
          }
        },
      ),
    );
  }

  Widget _buildWhiteMeatPrice() {
    return TextUtils(
      text: 'سعر كيلو الفراخ البيضاء',
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    );
  }
}
