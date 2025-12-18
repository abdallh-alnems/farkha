import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../logic/controller/tools_controller/bird_net_profit_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/input_fields/three_input_fields.dart';
import '../../widget/tools/tools_button.dart';
import '../../widget/tools/tools_result.dart';

class BirdNetProfitScreen extends StatefulWidget {
  const BirdNetProfitScreen({super.key});

  @override
  State<BirdNetProfitScreen> createState() => _BirdNetProfitScreenState();
}

class _BirdNetProfitScreenState extends State<BirdNetProfitScreen> {
  final BirdNetProfitController controller = Get.put(BirdNetProfitController());
  bool showResult = false;
  double? lastValidResult;

  void _onCalculatePressed() {
    controller.calculateNetProfit();
    setState(() {
      showResult = true;
      lastValidResult = controller.netProfit.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: 'صافي ربح الطائر'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            children: [
              ThreeInputFields(
                firstLabel: 'إجمالي البيع',
                secondLabel: 'إجمالي التكاليف',
                thirdLabel: 'عدد الطيور المباعة',
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
              const AdNativeWidget(),
              const SizedBox(height: 24),
              ToolsButton(
                text: 'احسب الربح الصافي للطائر',
                onPressed: _onCalculatePressed,
              ),
              const SizedBox(height: 32),
              if (showResult && lastValidResult != null)
                ToolsResult(
                  title: 'الربح الصافي للطائر',
                  value: lastValidResult!.toStringAsFixed(1),
                  unit: 'جنيه',
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
