import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../logic/controller/calculate_controller/darkness_levels_controller.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../../core/shared/input_fields/age_dropdown.dart';
import '../../../core/shared/note_item.dart';

class DarknessLevelsView extends StatelessWidget {
  const DarknessLevelsView({super.key});

  @override
  Widget build(BuildContext context) {
    final DarknessLevelsController controller = Get.put(
      DarknessLevelsController(),
    );
    return Scaffold(
      appBar: const CustomAppBar(text: 'ساعات الإظلام حسب العمر'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(
              () => AgeDropdown(
                selectedAge: controller.selectedDay.value,
                onAgeChanged: (value) => controller.setDay(value),
                maxAge: controller.maxDay,
                hint: 'اختر اليوم',
              ),
            ),
            const SizedBox(height: 40),
            Obx(
              () => Card(
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
                        '${controller.darkness}',
                        style: Theme.of(
                          context,
                        ).textTheme.displayLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ساعات',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Notes section for Darkness Levels
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
                    NoteItem('يتم تطبيق الإظلام تدريجياً حسب عمر الطائر.'),
                    NoteItem(
                      'أقصى مدة للظلام ساعتين في المرة الواحدة الباقي من ساعات الإظلام يقسم على باقي اليوم',
                    ),
                    NoteItem('الاظلام عملية مهمة جدا في  النمو'),
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
