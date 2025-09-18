import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../logic/controller/tools_controller/mortality_rate_controller.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/tools/tools_button.dart';
import '../../widget/tools/tools_result.dart';

class MortalityRateScreen extends StatelessWidget {
  MortalityRateScreen({super.key});
  final MortalityRateController controller = Get.put(MortalityRateController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onCalculatePressed(BuildContext context) {
    controller.calculateMortalityRate(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'معدل النفوق',
        toolKey: 'mortalityRateDialog',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TwoInputFields(
                  firstLabel: 'عدد الطيور عند البداية',
                  secondLabel: 'عدد النافق',
                  onFirstChanged:
                      (value) =>
                          controller.initialCount.value =
                              int.tryParse(value) ?? 0,
                  onSecondChanged:
                      (value) =>
                          controller.deaths.value = int.tryParse(value) ?? 0,
                ),
                const SizedBox(height: 24),
                ToolsButton(
                  text: 'احسب نسبة النفوق',
                  onPressed: () => _onCalculatePressed(context),
                ),
                const SizedBox(height: 32),
                Obx(() {
                  final value = controller.mortalityRate.value;
                  return value > 0
                      ? ToolsResult(
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
      ),
    );
  }
}
