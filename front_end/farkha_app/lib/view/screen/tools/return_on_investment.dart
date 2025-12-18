import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../logic/controller/tools_controller/return_on_investment_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/input_fields/two_input_fields.dart';
import '../../widget/tools/tools_button.dart';
import '../../widget/tools/tools_result.dart';

class ReturnOnInvestment extends StatelessWidget {
  ReturnOnInvestment({super.key});
  final ReturnOnInvestmentController controller = Get.put(
    ReturnOnInvestmentController(),
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onCalculatePressed() {
    final investment = controller.investmentCost.value;
    final totalSale = controller.totalSale.value;

    final actualProfit = totalSale - investment;
    controller.netProfit.value = actualProfit;
    controller.calculateROI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: 'العائد على الاستثمار'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TwoInputFields(
                  firstLabel: 'اجمالي البيع',
                  secondLabel: 'تكلفة الدورة',
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
                const AdNativeWidget(),
                const SizedBox(height: 24),
                ToolsButton(
                  text: 'احسب العائد علي الاستثمار',
                  onPressed: _onCalculatePressed,
                ),
                const SizedBox(height: 32),
                Obx(() {
                  final value = controller.roi.value;
                  final actualProfit = controller.netProfit.value;
                  final hasCalculated = controller.hasCalculated.value;

                  // عرض النتيجة فقط بعد الضغط على الزر
                  return hasCalculated
                      ? ToolsResult(
                        title: 'العائد على الاستثمار',
                        value:
                            '${actualProfit.toInt()} جنيه (%${value.toStringAsFixed(1)})',
                      )
                      : const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
