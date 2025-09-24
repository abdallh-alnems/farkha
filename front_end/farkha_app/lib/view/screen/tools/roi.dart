import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../logic/controller/tools_controller/roi_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/tools/tools_button.dart';
import '../../widget/tools/tools_result.dart';

class RoiScreen extends StatelessWidget {
  RoiScreen({super.key});
  final RoiController controller = Get.put(RoiController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onCalculatePressed(BuildContext context) {
    final investment = controller.investmentCost.value;
    final totalSale = controller.totalSale.value;

    // حساب الربح الصافي = إجمالي البيع - تكلفة الدورة
    final actualProfit = totalSale - investment;
    controller.netProfit.value = actualProfit;
    controller.calculateROI(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'العائد على الاستثمار',
        toolKey: 'roiDialog',
      ),
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
                      ? ToolsResult(
                        title: '(ROI) العائد على الاستثمار',
                        value:
                            '${actualProfit.toInt()} جنيه (%${value.toStringAsFixed(1)})',
                        valueColor:
                            actualProfit >= 0 ? Colors.green : Colors.red,
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
