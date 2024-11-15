import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/shared/custom_text_filed.dart';
import '../../../logic/controller/calculate_controller/chicken_density_controller.dart';
import '../../widget/ad/banner/ad_second_banner.dart';
import '../../widget/ad/native/ad_second_native.dart';
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19).r,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 17).r,
                    child: AdSecondNative(),
                  ),
                  CustomTextFiled(
                    controller: controller.chickensController,
                  ),
                  Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedAge.value.isEmpty
                            ? null
                            : controller.selectedAge.value,
                        hint: Text('اختر عمر الفراخ'),
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
                        onChanged: (String? newValue) {
                          controller.selectedAge.value = newValue!;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        icon: Icon(Icons.arrow_drop_down,
                            textDirection: TextDirection.ltr),
                        isExpanded: true,
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 19, bottom: 17).r,
                    child: ElevatedButton(
                      onPressed: controller.calculateArea,
                      child: Text('احسب المساحة'),
                    ),
                  ),
                 
                  Obx(
                    () => Text(
                      controller.areaResult.value,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdSecondBanner(),
    );
  }
}
