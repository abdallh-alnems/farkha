import 'package:farkha_app/core/class/handling_data.dart';
import 'package:farkha_app/core/constant/routes/route.dart';
import 'package:farkha_app/core/constant/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../logic/controller/price_controller/main_types_controller.dart';
import '../../widget/ad/banner/ad_second_banner.dart';
import '../../widget/ad/native/ad_second_native.dart';
import '../../widget/app_bar/custom_app_bar.dart';

class MainTypes extends StatelessWidget {
  const MainTypes({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MainTypesController());

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(
            text: "الانواع",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 13),
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 13, horizontal: 33),
                        child: GestureDetector(
                          onTap: () => Get.toNamed(
                            AppRoute.lastPrices,
                            arguments: {
                              'main_id': mainTypes['main_id'],
                              "main_name": mainTypes['main_name'],
                            },
                          ),
                          child: Container(
                            width: double.infinity,
                            height: 41,
                            color: AppColor.primaryColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  mainTypes['main_name'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
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
