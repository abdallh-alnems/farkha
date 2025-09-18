import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../logic/controller/tools_controller/bird_production_cost_controller.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/tools/tools_button.dart';
import '../../widget/tools/tools_result.dart';

class BirdProductionCostScreen extends StatelessWidget {
  BirdProductionCostScreen({super.key});
  final BirdProductionCostController controller = Get.put(
    BirdProductionCostController(),
  );

  void _onCalculatePressed(BuildContext context) {
    final total = controller.totalCosts.value;
    final birds = controller.liveBirds.value;

    if (total <= 0 || birds <= 0) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال قيم صحيحة',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    controller.calculateCostPerBird();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'تكلفة إنتاج الطائر',
        toolKey: 'birdProductionCostDialog',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            children: [
              TwoInputFields(
                firstLabel: 'إجمالي التكاليف',
                secondLabel: 'عدد الطيور الحية عند التسويق',
                onFirstChanged:
                    (value) =>
                        controller.totalCosts.value =
                            double.tryParse(value) ?? 0.0,
                onSecondChanged:
                    (value) =>
                        controller.liveBirds.value = int.tryParse(value) ?? 0,
              ),
              const SizedBox(height: 24),
              ToolsButton(
                text: 'احسب تكلفة إنتاج الفرخ',
                onPressed: () => _onCalculatePressed(context),
              ),
              const SizedBox(height: 32),
              Obx(() {
                final value = controller.costPerBird.value;
                return value > 0
                    ? ToolsResult(
                      title: 'تكلفة إنتاج الفرخ',
                      value: value.toStringAsFixed(2),
                      unit: 'جنيه',
                    )
                    : const SizedBox.shrink();
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
