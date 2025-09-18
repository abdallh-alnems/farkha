import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/shared/input_fields/three_input_fields.dart';
import '../../../logic/controller/tools_controller/feed_cost_per_kilo_controller.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/tools/tools_button.dart';
import '../../widget/tools/tools_result.dart';

class FeedCostPerKiloScreen extends StatelessWidget {
  FeedCostPerKiloScreen({super.key});
  final FeedCostPerKiloController controller = Get.put(
    FeedCostPerKiloController(),
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onCalculatePressed(BuildContext context) {
    controller.calculateFeedCostPerKilo(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'تكلفة العلف لكل كيلو',
        toolKey: 'feedCostPerKiloDialog',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: ThreeInputFields(
                  firstLabel: 'كمية العلف الكلية المستهلكة (طن)',
                  secondLabel: 'الوزن الكلي المباع (طن)',
                  thirdLabel: 'سعر الطن علف (جنيه)',
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
              ),
              SizedBox(height: 24.h),
              ToolsButton(
                text: 'احسب تكلفة العلف لكل طن وزن',
                onPressed: () => _onCalculatePressed(context),
              ),
              SizedBox(height: 32.h),
              Obx(() {
                final hasCalculated = controller.hasCalculated.value;

                return hasCalculated
                    ? Row(
                      children: [
                        ToolsResultCard(
                          title: 'تكلفة العلف لكل كيلو وزن',
                          value: controller.getFormattedResult(),
                          backgroundColor: Colors.green.shade50,
                          borderColor: Colors.green.shade200,
                          titleColor: Colors.green.shade800,
                          valueColor: Colors.green.shade700,
                        ),
                        ToolsResultCard(
                          title: 'إجمالي تكلفة العلف',
                          value: controller.getTotalFeedCostFormatted(),
                          backgroundColor: Colors.orange.shade50,
                          borderColor: Colors.orange.shade200,
                          titleColor: Colors.orange.shade800,
                          valueColor: Colors.orange.shade700,
                        ),
                      ],
                    )
                    : const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
