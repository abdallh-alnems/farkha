import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../core/shared/note_item.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../../logic/controller/calculate_controller/mortality_rate_controller.dart';
import '../../../core/functions/valid_input/calculate_validation.dart';
import '../../../core/shared/bottom_message.dart';
import '../../widget/calculate/calculate_button.dart';
import '../../widget/calculate/calculate_result.dart';

class MortalityRateScreen extends StatelessWidget {
  MortalityRateScreen({super.key});
  final MortalityRateController controller = Get.put(MortalityRateController());

  void _onCalculatePressed(BuildContext context) {
    final initial = controller.initialCount.value;
    final deaths = controller.deaths.value;

    if (!CalculateValidation.validateNumbersWithConditions(
      context,
      [initial],
      [deaths < 0, deaths > initial],
      'يرجى إدخال قيم صحيحة',
    )) {
      BottomMessage.show(context, 'يرجى إدخال قيم صحيحة');
      return;
    }

    controller.calculateMortalityRate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: 'نسبة النفوق'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TwoInputFields(
                firstLabel: 'عدد الطيور عند البداية',
                secondLabel: 'عدد النافق',
                firstKeyboardType: TextInputType.number,
                secondKeyboardType: TextInputType.number,
                onFirstChanged:
                    (value) =>
                        controller.initialCount.value =
                            int.tryParse(value) ?? 0,
                onSecondChanged:
                    (value) =>
                        controller.deaths.value = int.tryParse(value) ?? 0,
              ),
              const SizedBox(height: 24),
              CalculateButton(
                text: 'احسب نسبة النفوق',
                onPressed: () => _onCalculatePressed(context),
              ),
              const SizedBox(height: 32),
              Obx(() {
                final value = controller.mortalityRate.value;
                return value > 0
                    ? CalculateResult(
                      title: 'نسبة النفوق',
                      value: value.toStringAsFixed(1),
                      unit: '%',
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
