import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/shared/input_fields/age_dropdown.dart';
import '../../../logic/controller/tools_controller/darkness_levels_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/tools_button.dart';
import '../../widget/tools/tools_result.dart';

class DarknessLevelsView extends StatelessWidget {
  const DarknessLevelsView({super.key});

  @override
  Widget build(BuildContext context) {
    final DarknessLevelsController controller = Get.put(
      DarknessLevelsController(),
    );
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'درجات الظلام',
        toolKey: 'darknessLevelsDialog',
      ),
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
              Obx(() {
                if (controller.result.value.isNotEmpty) {
                  return ToolsResult(
                    title: "ساعات الإظلام",
                    value: controller.result.value,
                  );
                }
                return const SizedBox.shrink();
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
