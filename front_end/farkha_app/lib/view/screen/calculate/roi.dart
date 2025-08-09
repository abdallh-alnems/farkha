import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../../logic/controller/calculate_controller/roi_controller.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../core/functions/valid_input/calculate_validation.dart';
import '../../../core/shared/bottom_message.dart';
import '../../widget/calculate/calculate_button.dart';
import '../../widget/calculate/calculate_result.dart';

class RoiScreen extends StatelessWidget {
  RoiScreen({super.key});
  final RoiController controller = Get.put(RoiController());

  void _onCalculatePressed(BuildContext context) {
    final investment = controller.investmentCost.value;
    final totalSale = controller.totalSale.value;

    if (!CalculateValidation.validateNumbers(context, [
      investment,
    ], 'يرجى إدخال قيم صحيحة')) {
      BottomMessage.show(context, 'يرجى إدخال قيم صحيحة');
      return;
    }

    // حساب الربح الصافي = إجمالي البيع - تكلفة الدورة
    final actualProfit = totalSale - investment;
    controller.netProfit.value = actualProfit;
    controller.calculateROI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: 'ROI'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TwoInputFields(
                firstLabel: 'اجمالي البيع',
                secondLabel: 'تكلفة الدورة',
                firstKeyboardType: TextInputType.number,
                secondKeyboardType: TextInputType.number,
                onFirstChanged: (value) {
                  controller.totalSale.value = double.tryParse(value) ?? 0.0;
                  controller.resetCalculation();
                },
                onSecondChanged: (value) {
                  controller.investmentCost.value =
                      double.tryParse(value) ?? 0.0;
                  controller.resetCalculation();
                },
              ),
              const SizedBox(height: 24),
              CalculateButton(
                text: 'ROI احسب',
                onPressed: () => _onCalculatePressed(context),
              ),
              const SizedBox(height: 32),
              Obx(() {
                final value = controller.roi.value;
                final actualProfit = controller.netProfit.value;
                final hasCalculated = controller.hasCalculated.value;

                // عرض النتيجة فقط بعد الضغط على الزر
                return hasCalculated
                    ? CalculateResult(
                      title: '(ROI) العائد على الاستثمار',
                      value:
                          '${actualProfit.toInt()} جنيه (%${value.toStringAsFixed(1)})',
                      valueColor: actualProfit >= 0 ? Colors.green : Colors.red,
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
