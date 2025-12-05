import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../logic/controller/tools_controller/total_revenue_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/input_fields/three_input_fields.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/tools_button.dart';
import '../../widget/tools/tools_result.dart';

class TotalRevenueScreen extends StatelessWidget {
  TotalRevenueScreen({super.key});
  final TotalRevenueController controller = Get.put(TotalRevenueController());

  void _onCalculatePressed(BuildContext context) {
    final birdsCount = controller.birdsCount.value;
    final averageWeight = controller.averageWeight.value;
    final pricePerKg = controller.pricePerKg.value;

    if (birdsCount <= 0 || averageWeight <= 0 || pricePerKg <= 0) {
      return;
    }

    controller.calculate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: 'إجمالي الإيرادات'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            children: [
              // Input fields
              ThreeInputFields(
                firstLabel: 'عدد الطيور',
                secondLabel: 'متوسط الوزن',
                thirdLabel: 'سعر الكيلو',
                onFirstChanged: controller.updateBirdsCount,
                onSecondChanged: controller.updateAverageWeight,
                onThirdChanged: controller.updatePricePerKg,
              ),
              const SizedBox(height: 21),
              const AdNativeWidget(),
              const SizedBox(height: 21),
              // Calculate button
              ToolsButton(
                text: 'احسب الإيرادات',
                onPressed: () => _onCalculatePressed(context),
              ),
              const SizedBox(height: 21),
              // Result display
              Obx(() {
                final formattedRevenue = controller.getFormattedRevenue();
                return formattedRevenue.isNotEmpty
                    ? ToolsResult(
                      title: 'إجمالي الإيرادات',
                      value: formattedRevenue,
                      unit: 'جنيه',
                    )
                    : const SizedBox.shrink();
              }),
              // Notes section
              const NotesCard(
                notes: [
                  'يتم حساب الإيرادات بناءً على عدد الطيور ومتوسط الوزن وسعر الكيلو.',
                  'الإيرادات = عدد الطيور × متوسط الوزن × سعر الكيلو.',
                  'يجب التأكد من دقة البيانات المدخلة للحصول على نتائج صحيحة.',
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
