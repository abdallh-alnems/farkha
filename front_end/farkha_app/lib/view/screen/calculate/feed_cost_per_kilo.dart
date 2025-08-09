import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../../logic/controller/calculate_controller/feed_cost_per_kilo_controller.dart';
import '../../../core/shared/input_fields/three_input_fields.dart';
import '../../../core/functions/valid_input/calculate_validation.dart';
import '../../../core/shared/bottom_message.dart';
import '../../widget/calculate/calculate_button.dart';
import '../../widget/calculate/calculate_result.dart';

class FeedCostPerKiloScreen extends StatelessWidget {
  FeedCostPerKiloScreen({super.key});
  final FeedCostPerKiloController controller = Get.put(
    FeedCostPerKiloController(),
  );

  void _onCalculatePressed(BuildContext context) {
    final totalFeed = controller.totalFeedConsumed.value;
    final totalWeight = controller.totalWeightSold.value;
    final pricePerTon = controller.feedPricePerTon.value;

    if (!CalculateValidation.validateNumbers(context, [
      totalFeed,
      totalWeight,
      pricePerTon,
    ], 'يرجى إدخال قيم صحيحة')) {
      BottomMessage.show(context, 'يرجى إدخال قيم صحيحة');
      return;
    }

    controller.calculateFeedCostPerKilo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: 'تكلفة العلف لكل كيلو وزن'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ThreeInputFields(
                firstLabel: 'كمية العلف الكلية المستهلكة (طن)',
                secondLabel: 'الوزن الكلي المباع (طن)',
                thirdLabel: 'سعر الطن علف (جنيه)',
                firstKeyboardType: TextInputType.number,
                secondKeyboardType: TextInputType.number,
                thirdKeyboardType: TextInputType.number,
                onFirstChanged: (value) {
                  controller.totalFeedConsumed.value =
                      double.tryParse(value) ?? 0.0;
                  controller.resetCalculation();
                },
                onSecondChanged: (value) {
                  controller.totalWeightSold.value =
                      double.tryParse(value) ?? 0.0;
                  controller.resetCalculation();
                },
                onThirdChanged: (value) {
                  controller.feedPricePerTon.value =
                      double.tryParse(value) ?? 0.0;
                  controller.resetCalculation();
                },
              ),
              SizedBox(height: 24.h),
              CalculateButton(
                text: 'احسب تكلفة العلف لكل طن وزن',
                onPressed: () => _onCalculatePressed(context),
              ),
              SizedBox(height: 32.h),
              Obx(() {
                final hasCalculated = controller.hasCalculated.value;

                return hasCalculated
                    ? Row(
                      children: [
                        CalculateResultCard(
                          title: 'تكلفة العلف لكل كيلو وزن',
                          value: controller.getFormattedResult(),
                          backgroundColor: Colors.green.shade50,
                          borderColor: Colors.green.shade200,
                          titleColor: Colors.green.shade800,
                          valueColor: Colors.green.shade700,
                        ),
                        CalculateResultCard(
                          title: 'إجمالي تكلفة العلف',
                          value: controller.getTotalFeedCostFormatted(),
                          backgroundColor: Colors.orange.shade50,
                          borderColor: Colors.orange.shade200,
                          titleColor: Colors.orange.shade800,
                          valueColor: Colors.orange.shade700,
                        ),
                      ],
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
