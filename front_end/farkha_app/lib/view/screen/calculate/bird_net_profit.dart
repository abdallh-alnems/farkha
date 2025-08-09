import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/shared/input_fields/three_input_fields.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../../logic/controller/calculate_controller/bird_net_profit_controller.dart';
import '../../../core/functions/valid_input/calculate_validation.dart';
import '../../../core/shared/bottom_message.dart';
import '../../widget/calculate/calculate_button.dart';
import '../../widget/calculate/calculate_result.dart';

class BirdNetProfitScreen extends StatefulWidget {
  BirdNetProfitScreen({super.key});

  @override
  State<BirdNetProfitScreen> createState() => _BirdNetProfitScreenState();
}

class _BirdNetProfitScreenState extends State<BirdNetProfitScreen> {
  final BirdNetProfitController controller = Get.put(BirdNetProfitController());
  bool showResult = false;
  double? lastValidResult;

  void _onCalculatePressed(BuildContext context) {
    final totalSale = controller.totalSale.value;
    final totalCost = controller.totalCost.value;
    final soldBirds = controller.soldBirds.value;

    if (!CalculateValidation.validateNumbersWithConditions(
      context,
      [totalSale, soldBirds],
      [totalCost < 0],
      'يرجى إدخال قيم صحيحة',
    )) {
      BottomMessage.show(context, 'يرجى إدخال قيم صحيحة');
      setState(() {
        showResult = false;
        lastValidResult = null;
      });
      return;
    }

    controller.calculateNetProfit();
    setState(() {
      showResult = true;
      lastValidResult = controller.netProfit.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: 'الربح الصافي للطائر'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ThreeInputFields(
                firstLabel: 'إجمالي البيع',
                secondLabel: 'إجمالي التكاليف',
                thirdLabel: 'عدد الطيور المباعة',
                firstKeyboardType: TextInputType.number,
                secondKeyboardType: TextInputType.number,
                thirdKeyboardType: TextInputType.number,
                onFirstChanged: (value) {
                  controller.totalSale.value = double.tryParse(value) ?? 0.0;
                  setState(() {
                    showResult = false;
                    lastValidResult = null;
                  });
                },
                onSecondChanged: (value) {
                  controller.totalCost.value = double.tryParse(value) ?? 0.0;
                  setState(() {
                    showResult = false;
                    lastValidResult = null;
                  });
                },
                onThirdChanged: (value) {
                  controller.soldBirds.value = int.tryParse(value) ?? 0;
                  setState(() {
                    showResult = false;
                    lastValidResult = null;
                  });
                },
              ),
              const SizedBox(height: 24),
              CalculateButton(
                text: 'احسب الربح الصافي للطائر',
                onPressed: () => _onCalculatePressed(context),
              ),
              const SizedBox(height: 32),
              if (showResult && lastValidResult != null)
                CalculateResult(
                  title: 'الربح الصافي للطائر',
                  value: lastValidResult!.toStringAsFixed(1),
                  unit: 'جنيه',
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
