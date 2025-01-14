import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/class/handling_data.dart';
import '../../../../logic/controller/calculate_controller/feasibility_study_controller.dart';
import '../../../widget/bar/app_bar/custom_app_bar.dart';

class HowToDoAFeasibilityStudy extends StatelessWidget {
  const HowToDoAFeasibilityStudy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<FeasibilityController>(
        builder: (controller) {
          controller.ensureFeasibilityData();
          return HandlingDataView(
            statusRequest: controller.statusRequest,
            widget: Column(
              children: [
                const CustomAppBar(text: "كيف تعمل دراسة الجدوي"),
                const Text(
                  "الاسعار المستخدمة (هذه الاسعار هي اسعار اليوم)",
                  style: TextStyle(fontSize: 13),
                ),
                Row(
                  children: [
                    Text(controller.feasibilityModel.chickenSalePrice
                        .toString()),
                    const Text(" : اللحم الابيض"),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

