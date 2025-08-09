import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/shared/bottom_message.dart';
import '../../../core/shared/note_item.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../../logic/controller/calculate_controller/weight_by_age_controller.dart';
import '../../../core/shared/input_fields/age_dropdown.dart';

class WeightByAgeScreen extends StatefulWidget {
  WeightByAgeScreen({super.key});

  @override
  State<WeightByAgeScreen> createState() => _WeightByAgeScreenState();
}

class _WeightByAgeScreenState extends State<WeightByAgeScreen> {
  final WeightByAgeController controller = Get.put(WeightByAgeController());
  bool showResult = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: 'الوزن حسب العمر'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Minimal dropdown for day selection
              AgeDropdown(
                selectedAge: controller.selectedAge.value,
                onAgeChanged: (value) {
                  controller.selectedAge.value = value;
                  controller.calculateWeight();
                  setState(() {
                    showResult = true;
                  });
                },
                maxAge: 45,
                hint: 'اختر اليوم',
              ),
              const SizedBox(height: 40),
              if (showResult)
                Obx(() {
                  final weight = controller.weight.value;
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$weight',
                            style: const TextStyle(
                              fontSize: 31,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'جرام',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 32),
              // Notes section for Weight by Age
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
                      NoteItem('يتم حساب الوزن بناءً على عمر الفرخ باليوم.'),
                      NoteItem('الوزن يختلف حسب السلالة والظروف البيئية.'),
                      NoteItem(
                        'لحساب الوزن الكلي للقطيع: وزّن 10 فراخ عشوائيًا، احسب متوسط الوزن (قسمة على 10)، ثم اضربه في عدد الطيور.',
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
