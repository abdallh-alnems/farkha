import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../logic/controller/calculate_controller/adg_controller.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../../core/shared/input_fields/input_field.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../core/shared/note_item.dart';
import '../../../core/functions/valid_input/calculate_validation.dart';
import '../../../core/shared/bottom_message.dart';
import '../../widget/calculate/calculate_button.dart';
import '../../widget/calculate/calculate_result.dart';

class Adg extends StatelessWidget {
  Adg({super.key});
  final AdgController controller = Get.put(AdgController());

  void _onCalculatePressed(BuildContext context) {
    final days = controller.days.value;
    final weight = controller.currentWeight.value;

    if (!CalculateValidation.validateNumbersWithConditions(
      context,
      [days],
      [weight <= AdgController.initialWeight],
      'يرجى إدخال قيم صحيحة',
    )) {
      BottomMessage.show(context, 'يرجى إدخال قيم صحيحة');
      return;
    }

    controller.calculateADG();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: 'ADG'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TwoInputFields(
                firstLabel: 'العمر (يوم)',
                secondLabel: 'الوزن الحالي (كجم)',
                firstKeyboardType: TextInputType.number,
                secondKeyboardType: TextInputType.number,
                onFirstChanged:
                    (value) => controller.days.value = int.tryParse(value) ?? 0,
                onSecondChanged: (value) {
                  final kg = double.tryParse(value) ?? 0.0;
                  controller.currentWeight.value = kg * 1000;
                },
              ),
              const SizedBox(height: 24),
              CalculateButton(
                text: 'ADG احسب',
                onPressed: () => _onCalculatePressed(context),
              ),
              const SizedBox(height: 32),
              Obx(() {
                final value = controller.adg.value;
                return value > 0
                    ? CalculateResult(
                      title: '(ADG) متوسط الزيادة اليومية',
                      value: value.toStringAsFixed(2),
                    )
                    : const SizedBox.shrink();
              }),
              const SizedBox(height: 32),
              // Notes section for ADG
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
                      NoteItem('يفضل حساب ADG بعد عمر 7 أيام.'),
                      NoteItem('الوزن الحالي يجب أن يكون بالكيلوغرام.'),
                      NoteItem(
                        'ADG = (الوزن الحالي - وزن البداية) ÷ عدد الأيام.',
                      ),
                      NoteItem('ارتفاع ADG يدل على سرعة نمو جيدة.'),
                      NoteItem(
                        'يجب وزن الفراخ في نفس الوقت يومياً للمقارنة الدقيقة.',
                      ),
                      NoteItem(
                        'لحساب الوزن الكلي للقطيع: اوزن 10 فراخ عشوائيًا، احسب متوسط الوزن (قسمة على 10)، ثم اضربه في عدد الطيور.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
