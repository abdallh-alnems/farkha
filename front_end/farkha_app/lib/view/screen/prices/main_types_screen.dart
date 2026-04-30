import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/shared/buttons/app_button.dart';
import '../../../logic/controller/price_controller/main_types_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';

class MainTypes extends StatelessWidget {
  const MainTypes({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MainTypesController());

    return Scaffold(
      appBar: const CustomAppBar(text: 'الأنواع'),
      body: Column(
        children: [
          Expanded(
            child: GetBuilder<MainTypesController>(
              builder: (controller) {
                return HandlingDataView(
                  statusRequest: controller.statusRequest,
                  widget: ListView.builder(
                    itemCount: controller.items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 9).r,
                          child: const AdNativeWidget(),
                        );
                      } else {
                        final mainTypes = controller.items[index - 1];
                        return AppButton(
                          onPressed:
                              () => Get.toNamed<void>(
                                AppRoute.pricesByType,
                                arguments: {
                                  'main_id': mainTypes['id'],
                                  'main_name': (mainTypes['name'] ?? '').toString(),
                                },
                              ),
                          label: (mainTypes['name'] ?? '').toString(),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
