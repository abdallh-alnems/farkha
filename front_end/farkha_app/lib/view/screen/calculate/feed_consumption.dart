import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/calculate/calculate_result.dart';
import '../../widget/calculate/calculate_button.dart';
import '../../../core/shared/input_fields/chicken_form.dart';
import '../../../core/shared/input_fields/input_field.dart';
import '../../../core/shared/bottom_message.dart';
import '../../../logic/controller/calculate_controller/feed_consumption_controller.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/calculate/feed_toggle_button.dart';

class FeedConsumption extends StatelessWidget {
  const FeedConsumption({super.key});

  @override
  Widget build(BuildContext context) {
    final FeedConsumptionController controller = Get.put(
      FeedConsumptionController(),
    );

    return Scaffold(
      appBar: CustomAppBar(text: 'استهلاك العلف'),
      body: Column(
        children: [
          FeedToggleButtons(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(() {
                    if (controller.isCumulative.value) {
                      // استخدام InputField فقط للحساب الإجمالي
                      return InputField(
                        label: 'عدد الفراخ',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          controller.textController.text = value;
                        },
                      );
                    } else {
                      // استخدام ChickenForm للحساب اليومي
                      return ChickenForm(
                        controller: controller.textController,
                        selectedAge: controller.selectedAge.value,
                        onAgeChanged: (value) {
                          // فقط تحديث القيمة بدون حساب تلقائي
                          controller.selectedAge.value = value;
                        },
                        maxAge: 45,
                        ageHint: 'اختر اليوم',
                      );
                    }
                  }),
                  SizedBox(height: 24.h),

                  CalculateButton(
                    text: "احسب الاستهلاك",
                    onPressed:
                        () => controller.calculateFeedConsumption(context),
                  ),

                  SizedBox(height: 32.h),
                  Obx(() {
                    if (controller.result.value.isNotEmpty) {
                      return CalculateResult(
                        title: "استهلاك العلف",
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
      bottomNavigationBar: const AdBannerWidget(adIndex: 1),
    );
  }
}
