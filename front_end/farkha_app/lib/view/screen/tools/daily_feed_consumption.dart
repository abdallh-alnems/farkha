import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../logic/controller/tools_controller/daily_feed_consumption_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/input_fields/chicken_age_count_input.dart';
import '../../widget/tools/tools_button.dart';
import '../../widget/tools/tools_result.dart';

class DailyFeedConsumption extends StatelessWidget {
  const DailyFeedConsumption({super.key});

  @override
  Widget build(BuildContext context) {
    final DailyFeedConsumptionController controller = Get.put(
      DailyFeedConsumptionController(),
    );

    return Scaffold(
      appBar: const CustomAppBar(text: 'استهلاك العلف اليومي'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                children: [
                  ChickenAgeCountInput(
                    controller: controller.textController,
                    selectedAge: controller.selectedAge.value,
                    onAgeChanged: (value) {
                      controller.selectedAge.value = value;
                    },
                    maxAge: 45,
                    ageHint: 'اختر اليوم',
                  ),
                  SizedBox(height: 24.h),
                  const AdNativeWidget(),
                  SizedBox(height: 24.h),
                  ToolsButton(
                    text: "احسب الاستهلاك اليومي",
                    onPressed:
                        () => controller.calculateDailyFeedConsumption(context),
                  ),

                  SizedBox(height: 32.h),
                  Obx(() {
                    if (controller.result.value.isNotEmpty) {
                      return ToolsResult(
                        title: "استهلاك العلف اليومي",
                        value: controller.result.value,
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
