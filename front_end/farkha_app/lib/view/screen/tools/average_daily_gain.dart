import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../logic/controller/tools_controller/adg_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/input_fields/two_input_fields.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/tools_button.dart';
import '../../widget/tools/tools_result.dart';

class AverageDailyGain extends StatelessWidget {
  AverageDailyGain({super.key});
  final AdgController controller = Get.put(AdgController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: 'متوسط زيادة الوزن اليومية'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TwoInputFields(
                  firstLabel: 'العمر',
                  secondLabel: 'الوزن الحالي ',
                  onFirstChanged: (value) {
                    controller.days.value = int.tryParse(value) ?? 0;
                  },
                  onSecondChanged: (value) {
                    final kg = double.tryParse(value) ?? 0.0;
                    controller.currentWeight.value = kg * 1000;
                  },
                ),
                const SizedBox(height: 24),
                const AdNativeWidget(),
                const SizedBox(height: 24),
                ToolsButton(
                  text: 'ADG احسب',
                  onPressed: () => controller.calculateADG(context),
                ),
                const SizedBox(height: 32),
                Obx(() {
                  final value = controller.adg.value;
                  return value > 0
                      ? ToolsResult(
                        title: 'متوسط الزيادة اليومية (ADG)',
                        value: value.toStringAsFixed(2),
                      )
                      : const SizedBox.shrink();
                }),
                const SizedBox(height: 32),
                // Notes section for ADG
                const NotesCard(
                  notes: [
                    'بعد عمر 7 أيام يفضل حساب متوسط زيادة الوزن',
                    ' ارتفاع متوسط زيادة الوزن يدل على سرعة نمو جيدة',
                    'لحساب الوزن الكلي للقطيع : اوزن 10 فراخ عشوائيًا احسب متوسط الوزن (قسمة على 10) ثم اضربه في عدد الطيور',
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
