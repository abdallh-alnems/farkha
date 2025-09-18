import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/shared/input_fields/three_input_fields.dart';
import '../../../logic/controller/tools_controller/feed_cost_per_bird_controller.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/tools/tools_button.dart';
import '../../widget/tools/tools_result.dart';

class FeedCostPerBirdScreen extends StatelessWidget {
  FeedCostPerBirdScreen({super.key});
  final FeedCostPerBirdController controller = Get.put(
    FeedCostPerBirdController(),
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onCalculatePressed(BuildContext context) {
    controller.calculateFeedCostPerBird(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'تكلفة العلف لكل طائر',
        toolKey: 'feedCostPerBirdDialog',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ThreeInputFields(
                  firstLabel: 'إجمالي كمية العلف (طن)',
                  secondLabel: 'سعر الطن الواحد (جنيه)',
                  thirdLabel: 'عدد الطيور',
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
                ToolsButton(
                  text: 'احسب تكلفة العلف لكل طائر',
                  onPressed: () => _onCalculatePressed(context),
                ),
                SizedBox(height: 32.h),
                Obx(() {
                  final hasCalculated = controller.hasCalculated.value;

                  return hasCalculated
                      ? ToolsResult(
                        title: 'تكلفة العلف لكل طائر',
                        value: controller.getFormattedResult(),
                        unit: 'جنيه',
                      )
                      : const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
