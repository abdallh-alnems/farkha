import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../../logic/controller/calculate_controller/feed_cost_per_bird_controller.dart';
import '../../../core/shared/input_fields/three_input_fields.dart';
import '../../../core/functions/valid_input/calculate_validation.dart';
import '../../../core/shared/bottom_message.dart';
import '../../widget/calculate/calculate_button.dart';
import '../../widget/calculate/calculate_result.dart';

class FeedCostPerBirdScreen extends StatelessWidget {
  FeedCostPerBirdScreen({super.key});
  final FeedCostPerBirdController controller = Get.put(
    FeedCostPerBirdController(),
  );

  void _onCalculatePressed(BuildContext context) {
    final totalFeed = controller.totalFeedQuantity.value;
    final pricePerTon = controller.feedPricePerTon.value;
    final birdsCount = controller.numberOfBirds.value;

    if (!CalculateValidation.validateNumbers(context, [
      totalFeed,
      pricePerTon,
      birdsCount.toDouble(),
    ], 'يرجى إدخال قيم صحيحة')) {
      BottomMessage.show(context, 'يرجى إدخال قيم صحيحة');
      return;
    }

    controller.calculateFeedCostPerBird();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: 'تكلفة العلف لكل طائر'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ThreeInputFields(
                firstLabel: 'إجمالي كمية العلف (طن)',
                secondLabel: 'سعر الطن الواحد (جنيه)',
                thirdLabel: 'عدد الطيور',
                firstKeyboardType: TextInputType.number,
                secondKeyboardType: TextInputType.number,
                thirdKeyboardType: TextInputType.number,
                onFirstChanged: (value) {
                  controller.totalFeedQuantity.value =
                      double.tryParse(value) ?? 0.0;
                  controller.resetCalculation();
                },
                onSecondChanged: (value) {
                  controller.feedPricePerTon.value =
                      double.tryParse(value) ?? 0.0;
                  controller.resetCalculation();
                },
                onThirdChanged: (value) {
                  controller.numberOfBirds.value = int.tryParse(value) ?? 0;
                  controller.resetCalculation();
                },
              ),
              SizedBox(height: 24.h),
              CalculateButton(
                text: 'احسب تكلفة العلف لكل طائر',
                onPressed: () => _onCalculatePressed(context),
              ),
              SizedBox(height: 32.h),
              Obx(() {
                final hasCalculated = controller.hasCalculated.value;

                return hasCalculated
                    ? CalculateResult(
                      title: 'تكلفة العلف لكل طائر',
                      value: controller.getFormattedResult(),
                      unit: 'جنيه',
                    )
                    : SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
