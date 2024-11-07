import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/class/handling_data.dart';
import '../../../core/constant/theme/color.dart';
import '../../../core/shared/price_index.dart';
import '../../../logic/controller/price_controller/farkh_abid_controller.dart';

class CardPriceFarkhAbidHome extends StatelessWidget {
  const CardPriceFarkhAbidHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 15,
      ).r,
      child: Container(
        width: double.infinity,
        height: 45.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: AppColor.secondaryColor,
        ),
        child: GetBuilder<FarkhAbidController>(
          builder: (controller) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              PriceIndex(
                todayPrice: double.tryParse(controller.todayPrice) ?? 0,
                yesterdayPrice: double.tryParse(controller.yesterdayPrice) ?? 0,
              ),
              // فرق السعر
              // HandlingDataView(
              //   statusRequest: controller.statusRequest,
              //   widget: Text(controller.priceYesterday),
              // ),
              HandlingDataView(
                statusRequest: controller.statusRequest,
                widget: Text(
                  controller.todayPrice,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                "اللحم الابيض",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
