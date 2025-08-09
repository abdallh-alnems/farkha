import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../../core/shared/note_item.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../logic/controller/calculate_controller/total_farm_weight_controller.dart';
import '../../../core/shared/bottom_message.dart';
import '../../widget/calculate/calculate_button.dart';
import '../../widget/calculate/calculate_result.dart';

class TotalFarmWeightScreen extends StatelessWidget {
  const TotalFarmWeightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TotalFarmWeightController controller = Get.put(
      TotalFarmWeightController(),
    );
    return Scaffold(
      appBar: const CustomAppBar(text: 'حساب الوزن الإجمالي للمزرعة'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            TwoInputFields(
              firstLabel: 'عدد الطيور',
              secondLabel: 'الوزن المتوقع للطائر (كيلو جرام)',
              firstKeyboardType: TextInputType.number,
              secondKeyboardType: TextInputType.number,
              onFirstChanged: (val) => controller.birdsCount.value = val,
              onSecondChanged: (val) => controller.birdWeight.value = val,
            ),
            const SizedBox(height: 28),
            CalculateButton(
              text: 'احسب',
              onPressed: () {
                final birdsCountStr = controller.birdsCount.value;
                final birdWeightStr = controller.birdWeight.value;

                final birdsCount = int.tryParse(birdsCountStr);
                final birdWeight = double.tryParse(birdWeightStr);

                if (birdsCount == null ||
                    birdWeight == null ||
                    birdsCount <= 0 ||
                    birdWeight <= 0) {
                  BottomMessage.show(context, 'يرجى إدخال قيم صحيحة');
                  return;
                }

                controller.calculate();
              },
            ),
            const SizedBox(height: 32),
            Obx(
              () =>
                  controller.totalWeight.value > 0
                      ? CalculateResult(
                        title: 'الوزن الإجمالي',
                        value: controller.totalWeight.value.toStringAsFixed(0),
                        unit: 'كيلو جرام',
                      )
                      : const SizedBox(),
            ),
            const SizedBox(height: 32),
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
                      'لحساب الوزن الكلي للقطيع: وزّن 10 فراخ عشوائيًا، احسب متوسط الوزن (قسمة على 10)، ثم اضربه في عدد الطيور.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
