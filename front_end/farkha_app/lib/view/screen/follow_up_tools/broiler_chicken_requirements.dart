import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/shared/chicken_form.dart';
import '../../../logic/controller/follow_up_tools_controller/broiler_chicken_requirements_controller.dart';
import '../../widget/ad/banner/ad_second_banner.dart';
import '../../widget/app_bar/custom_app_bar.dart';

class BroilerChickenRequirements extends StatelessWidget {
  const BroilerChickenRequirements({super.key});

  @override
  Widget build(BuildContext context) {
    final BroilerChickenRequirementsController controller =
        Get.put(BroilerChickenRequirementsController());

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            text: "احتياجات فراخ التسمين",
          ),
          ChickenForm(
            controller: controller.chickensController,
            onChanged: (newValue) {
              controller.selectedAge.value = newValue;
            },
            selectedAge: controller.selectedAge.value,
            items: List.generate(45, (index) => index + 1).map((age) {
              return DropdownMenuItem<int>(
                value: age,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('$age يوم'),
                ),
              );
            }).toList(),
            onPressed: () {},
            textElevatedButton: 'احتياجات فراخ التسمين',
            children: [
              Obx(() {
                // Show the temperature based on selected age
                int temperature = controller.getTemperature();
                return Text(temperature != 0 ? 'درجة الحرارة: $temperature' : 'الرجاء اختيار العمر');
              }),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const AdSecondBanner(),
    );
  }
}
