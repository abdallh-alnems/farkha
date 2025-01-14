import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widget/calculate/calculate_result.dart';
import '../../../core/shared/chicken_form.dart';
import '../../../logic/controller/calculate_controller/chicken_density_controller.dart';
import '../../widget/app/ad/banner/ad_second_banner.dart';
import '../../widget/bar/app_bar/custom_app_bar.dart';
import '../../widget/calculate/feasibility_study_title.dart';

class ChickenDensity extends StatelessWidget {
  const ChickenDensity({super.key});

  @override
  Widget build(BuildContext context) {
    final ChickenDensityController controller =
        Get.put(ChickenDensityController());

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: "كثافة الفراخ"),
          ChickenForm(
            controller: controller.chickenCountTextController,
            selectedAge: controller.selectedAgeCategory.value,
            onChanged: (value) {
              controller.selectedAgeCategory.value = value!;
              controller.calculateAreas();
            },
            items: [
              'الاسبوع الاول',
              'الاسبوع الثاني',
              'الاسبوع الثالث',
              'الاسبوع الرابع',
              'الاسبوع الخامس'
            ]
                .map((age) => DropdownMenuItem<String>(
                      value: age,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(age, style: TextStyle(fontSize: 13.sp)),
                      ),
                    ))
                .toList(),
            children: [
              Obx(() {
                if (controller.shouldDisplayResults.value) {
                  return Column(
                    children: [
                      SizedBox(height: 33),
                      ResultTitle(title: "الارضي"),
                      CalculateResult(
                          text: controller.currentAgeGroundAreaResult.value),
                      const SizedBox(height: 5),
                      CalculateResult(
                          text: controller.totalGroundAreaResult.value),
                      const SizedBox(height: 13),
                      ResultTitle(title: "البطاريات"),
                      CalculateResult(
                          text: controller.batteryCageAreaResult.value),
                    ],
                  );
                }
                return const Padding(
                  padding: EdgeInsets.only(top: 35),
                  child: Text('ادخل العدد والعمر'),
                );
              }),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const AdSecondBanner(),
    );
  }
}
