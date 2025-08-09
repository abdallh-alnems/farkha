import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../logic/controller/calculate_controller/total_revenue_controller.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../../core/shared/input_fields/three_input_fields.dart';
import '../../../core/shared/note_item.dart';
import '../../../core/shared/bottom_message.dart';
import '../../widget/calculate/calculate_button.dart';
import '../../widget/calculate/calculate_result.dart';

class TotalRevenueScreen extends StatelessWidget {
  TotalRevenueScreen({super.key});
  final TotalRevenueController controller = Get.put(TotalRevenueController());

  void _onCalculatePressed(BuildContext context) {
    final birdsCount = controller.birdsCount.value;
    final averageWeight = controller.averageWeight.value;
    final pricePerKg = controller.pricePerKg.value;

    if (birdsCount <= 0 || averageWeight <= 0 || pricePerKg <= 0) {
      BottomMessage.show(context, 'يرجى إدخال قيم صحيحة');
      return;
    }

    controller.calculate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: 'إجمالي الإيرادات'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input fields
              ThreeInputFields(
                firstLabel: 'عدد الطيور',
                secondLabel: 'متوسط الوزن (كجم)',
                thirdLabel: 'سعر الكيلو (جنيه)',
                firstKeyboardType: TextInputType.number,
                secondKeyboardType: TextInputType.number,
                thirdKeyboardType: TextInputType.number,
                onFirstChanged: controller.updateBirdsCount,
                onSecondChanged: controller.updateAverageWeight,
                onThirdChanged: controller.updatePricePerKg,
              ),
              const SizedBox(height: 32),
              // Calculate button
              CalculateButton(
                text: 'احسب الإيرادات',
                onPressed: () => _onCalculatePressed(context),
              ),
              const SizedBox(height: 32),
              // Result display
              Obx(() {
                final revenue = controller.totalRevenue.value;
                return revenue > 0
                    ? CalculateResult(
                      title: 'إجمالي الإيرادات',
                      value: revenue.toStringAsFixed(0),
                      unit: 'جنيه',
                    )
                    : const SizedBox.shrink();
              }),
              const SizedBox(height: 32),
              // Notes section
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '📌 ملاحظات هامة',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 12),
                      NoteItem(
                        'يتم حساب الإيرادات بناءً على عدد الطيور ومتوسط الوزن وسعر الكيلو.',
                      ),
                      NoteItem(
                        'الإيرادات = عدد الطيور × متوسط الوزن × سعر الكيلو.',
                      ),
                      NoteItem(
                        'يجب التأكد من دقة البيانات المدخلة للحصول على نتائج صحيحة.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
