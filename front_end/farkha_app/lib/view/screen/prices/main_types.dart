import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/class/handling_data.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/shared/card_title.dart';
import '../../../logic/controller/price_controller/main_types_controller.dart';
import '../../widget/app/ad/banner/ad_second_banner.dart';
import '../../widget/app/ad/native/ad_second_native.dart';
import '../../widget/app/app_bar/custom_app_bar.dart';

class MainTypes extends StatelessWidget {
  const MainTypes({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MainTypesController());

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: "الانواع"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11).r,
            child: const AdSecondNative(),
          ),
          Expanded(
            child: GetBuilder<MainTypesController>(
              builder: (controller) {
                return HandlingDataView(
                  statusRequest: controller.statusRequest,
                  widget: ListView.builder(
                    itemCount: controller.mainTypesList.length,
                    itemBuilder: (context, index) {
                      final mainTypes = controller.mainTypesList[index];
                      return CardTitle(
                        onTap: () => Get.toNamed(
                          AppRoute.lastPrices,
                          arguments: {
                            'main_id': mainTypes['main_id'],
                            "main_name": mainTypes['main_name'],
                          },
                        ),
                        text: mainTypes['main_name'],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdSecondBanner(),
    );
  }
}
