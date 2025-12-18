import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../logic/controller/tools_controller/total_feed_consumption_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/input_fields/input_field.dart';
import '../../widget/tools/tools_button.dart';
import '../../widget/tools/tools_result.dart';

class TotalFeedConsumption extends StatelessWidget {
  const TotalFeedConsumption({super.key});

  @override
  Widget build(BuildContext context) {
    final TotalFeedConsumptionController controller = Get.put(
      TotalFeedConsumptionController(),
    );

    return Scaffold(
      appBar: const CustomAppBar(text: 'استهلاك العلف الكلي'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                children: [
                  InputField(
                    label: 'عدد الفراخ',
                    onChanged: (value) {
                      controller.textController.text = value;
                    },
                  ),
                  SizedBox(height: 24.h),
                  const AdNativeWidget(),
                  SizedBox(height: 24.h),
                  ToolsButton(
                    text: "احسب الاستهلاك الكلي",
                    onPressed: () => controller.calculateTotalFeedConsumption(),
                  ),

                  SizedBox(height: 32.h),
                  Obx(() {
                    if (controller.result.value.isNotEmpty) {
                      return ToolsResult(
                        title: "استهلاك العلف الكلي",
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
