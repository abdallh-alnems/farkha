import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/shared/calculate_result.dart';
import '../../../core/shared/chicken_form.dart';
import '../../../logic/controller/calculate_controller/chicken_density_controller.dart';
import '../../widget/ad/banner/ad_second_banner.dart';
import '../../widget/app_bar/custom_app_bar.dart';

class ChickenDensity extends StatelessWidget {
  const ChickenDensity({super.key});

  @override
  Widget build(BuildContext context) {
    final ChickenDensityController controller =
        Get.put(ChickenDensityController());

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            text: "كثافة الفراخ",
          ),
          ChickenForm(
            controller: controller.chickensController,
            onChanged: (dynamic newValue) {
              controller.selectedAge.value = newValue!;
            },
            selectedAge: controller.selectedAge.value,
            items: <String>[
              '( 7 - 1 ) الاسبوع الاول',
              '( 14 - 7 ) الاسبوع الثاني',
              '( 21 - 14 ) الاسبوع الثالث',
              '( 28 - 21 ) الاسبوع الرابع',
              '( الي نهاية الدورة ) الاسبوع الخامس',
            ].map((String age) {
              return DropdownMenuItem<String>(
                value: age,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(age),
                ),
              );
            }).toList(),
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 19, bottom: 17).r,
                child: ElevatedButton(
                  onPressed: controller.calculateArea,
                  child: Text('احسب المساحة'),
                ),
              ),
              Obx(
                () => CalculateResult(
                  text: controller.areaResult.value,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const AdSecondBanner(),
    );
  }
}
