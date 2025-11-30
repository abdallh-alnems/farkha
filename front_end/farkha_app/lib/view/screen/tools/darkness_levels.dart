import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../logic/controller/tools_controller/darkness_levels_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/input_fields/age_dropdown.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/tools_button.dart';
import '../../widget/tools/tools_result_card.dart';

class DarknessLevelsView extends StatelessWidget {
  const DarknessLevelsView({super.key});

  @override
  Widget build(BuildContext context) {
    final DarknessLevelsController controller = Get.put(
      DarknessLevelsController(),
    );
    return Scaffold(
      appBar: const CustomAppBar(text: 'ساعات الاظلام'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
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
              const SizedBox(height: 24),
              const AdNativeWidget(),
              const SizedBox(height: 24),
              ToolsButton(
                text: "احسب ساعات الإظلام",
                onPressed: () => controller.calculateDarknessLevels(),
              ),
              const SizedBox(height: 32),
              Obx(() {
                final hasCalculated =
                    controller.result.value.isNotEmpty &&
                    controller.selectedDay.value != null;
                final darknessHours = controller.darkness;
                final lightHours = controller.light;

                return hasCalculated &&
                        darknessHours != null &&
                        lightHours != null
                    ? Row(
                      children: [
                        Expanded(
                          child: ToolsResultCard(
                            title: 'ساعات الإظلام',
                            value: '${controller.darknessHoursFormatted} ساعة',
                            backgroundColor: Colors.blue.shade50,
                            borderColor: Colors.blue.shade200,
                            titleColor: Colors.blue.shade800,
                            valueColor: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ToolsResultCard(
                            title: 'ساعات الإضاءة',
                            value: '${controller.lightHoursFormatted} ساعة',
                            backgroundColor: Colors.orange.shade50,
                            borderColor: Colors.orange.shade200,
                            titleColor: Colors.orange.shade800,
                            valueColor: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    )
                    : const SizedBox.shrink();
              }),
              const NotesCard(
                notes: [
                  'يتم تطبيق الإظلام تدريجياً حسب عمر الطائر.',
                  'أقصى مدة للظلام ساعتين في المرة الواحدة الباقي من ساعات الإظلام يقسم على باقي اليوم',
                  'الاظلام عملية مهمة جدا في  النمو',
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
