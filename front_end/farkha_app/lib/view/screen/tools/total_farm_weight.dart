import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../logic/controller/tools_controller/total_farm_weight_controller.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/tools_button.dart';

class TotalFarmWeightScreen extends StatelessWidget {
  TotalFarmWeightScreen({super.key});
  final TotalFarmWeightController controller = Get.put(
    TotalFarmWeightController(),
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'إجمالي وزن المزرعة',
        toolKey: 'totalFarmWeightDialog',
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 24),
              TwoInputFields(
                firstLabel: 'عدد الطيور',
                secondLabel: 'الوزن المتوقع للطائر (كيلو جرام)',
                onFirstChanged: (val) => controller.birdsCount.value = val,
                onSecondChanged: (val) => controller.birdWeight.value = val,
              ),
              const SizedBox(height: 28),
              ToolsButton(
                text: 'احسب',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    controller.calculate();
                  }
                },
              ),
              const SizedBox(height: 32),
              Obx(
                () =>
                    controller.totalWeight.value > 0
                        ? Card(
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
                              children: [
                                Text(
                                  controller.totalWeight.value.toStringAsFixed(
                                    0,
                                  ),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayLarge?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'كيلو جرام (الوزن الإجمالي)',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        )
                        : const SizedBox(),
              ),
              const SizedBox(height: 32),
              const NotesCard(
                notes: [
                  'لحساب الوزن الكلي للقطيع: وزّن 10 فراخ عشوائيًا، احسب متوسط الوزن (قسمة على 10)، ثم اضربه في عدد الطيور.',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
