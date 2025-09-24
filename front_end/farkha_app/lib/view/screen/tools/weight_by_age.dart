import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/shared/input_fields/age_dropdown.dart';
import '../../../logic/controller/tools_controller/weight_by_age_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/tools/notes_card.dart';

class WeightByAgeScreen extends StatefulWidget {
  const WeightByAgeScreen({super.key});

  @override
  State<WeightByAgeScreen> createState() => _WeightByAgeScreenState();
}

class _WeightByAgeScreenState extends State<WeightByAgeScreen> {
  final WeightByAgeController controller = Get.put(WeightByAgeController());
  bool showResult = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'الوزن حسب العمر',
        toolKey: 'weightByAgeDialog',
      ),
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
              const SizedBox(height: 20),
              const AdNativeWidget(),
              const SizedBox(height: 20),
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
              const NotesCard(
                notes: [
                  'الوزن المتوقع يعتمد على السلالة ونوع العلف وجودة الرعاية.',
                  'يتم حساب الوزن بناءً على متوسطات عالمية للدجاج البياض.',
                  'الوزن الفعلي قد يختلف حسب الظروف البيئية والإدارية.',
                  'يفضل وزن عينة من الطيور للمقارنة مع الأوزان المتوقعة.',
                ],
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
