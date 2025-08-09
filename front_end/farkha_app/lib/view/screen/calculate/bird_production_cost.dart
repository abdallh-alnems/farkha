import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/shared/input_fields/input_field.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../../logic/controller/calculate_controller/bird_production_cost_controller.dart';
import '../../../core/functions/valid_input/calculate_validation.dart';
import '../../../core/shared/bottom_message.dart';
import '../../widget/calculate/calculate_button.dart';
import '../../widget/calculate/calculate_result.dart';

class BirdProductionCostScreen extends StatelessWidget {
  BirdProductionCostScreen({super.key});
  final BirdProductionCostController controller = Get.put(
    BirdProductionCostController(),
  );

  void _onCalculatePressed(BuildContext context) {
    final total = controller.totalCosts.value;
    final birds = controller.liveBirds.value;

    if (!CalculateValidation.validateNumbers(context, [
      total,
      birds,
    ], 'يرجى إدخال قيم صحيحة')) {
      BottomMessage.show(context, 'يرجى إدخال قيم صحيحة');
      return;
    }

    controller.calculateCostPerBird();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: 'تكلفة إنتاج الفرخ'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TwoInputFields(
                firstLabel: 'إجمالي التكاليف',
                secondLabel: 'عدد الطيور الحية عند التسويق',
                firstKeyboardType: TextInputType.number,
                secondKeyboardType: TextInputType.number,
                onFirstChanged:
                    (value) =>
                        controller.totalCosts.value =
                            double.tryParse(value) ?? 0.0,
                onSecondChanged:
                    (value) =>
                        controller.liveBirds.value = int.tryParse(value) ?? 0,
              ),
              const SizedBox(height: 24),
              CalculateButton(
                text: 'احسب تكلفة إنتاج الفرخ',
                onPressed: () => _onCalculatePressed(context),
              ),
              const SizedBox(height: 32),
              Obx(() {
                final value = controller.costPerBird.value;
                return value > 0
                    ? CalculateResult(
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
