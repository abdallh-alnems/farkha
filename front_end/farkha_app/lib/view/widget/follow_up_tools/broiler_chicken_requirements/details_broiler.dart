import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/theme/color.dart';
import '../../../../logic/controller/follow_up_tools_controller/broiler_controller.dart';

class DetailsBroiler extends GetView<BroilerController> {
  const DetailsBroiler({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                "العدد",
                style: Theme.of(context).textTheme.displayMedium,
              ),
              _divider(),
              Text(
                controller.chickensCountController.text,
                style: Theme.of(context).textTheme.displayMedium,
              )
            ],
          ),
          Column(
            children: [
              Text(
                "العمر",
                style: Theme.of(context).textTheme.displayMedium,
              ),
              _divider(),
              Text(
                "${controller.selectedChickenAge}",
                style: Theme.of(context).textTheme.displayMedium,
              )
            ],
          ),
          Column(
            children: [
              Text(
                "الموقع",
                style: Theme.of(context).textTheme.displayMedium,
              ),
              _divider(),
              Text(
                "${controller.currentCenter}/${controller.currentRegion}",
                style: Theme.of(context).textTheme.displayMedium,
              )
            ],
          )
        ],
      ),
    );
  }
}

Widget _divider() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Container(
      decoration:
          BoxDecoration(border: Border.all(), color: AppColor.primaryColor),
      width: 31,
    ),
  );
}
