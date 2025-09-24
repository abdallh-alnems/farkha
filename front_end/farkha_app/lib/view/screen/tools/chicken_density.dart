import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/shared/input_fields/input_field.dart';
import '../../../logic/controller/tools_controller/chicken_density_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/tools/tools_button.dart';
import '../../widget/tools/tools_result.dart';

class ChickenDensity extends StatelessWidget {
  const ChickenDensity({super.key});

  @override
  Widget build(BuildContext context) {
    final ChickenDensityController controller = Get.put(
      ChickenDensityController(),
    );

    return Scaffold(
      appBar: const CustomAppBar(
        text: 'كثافة الفراخ',
        toolKey: 'chickenDensityDialog',
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InputField(
                          label: 'عدد الفراخ',
                          onChanged: (value) {
                            controller.chickenCountTextController.text = value;
                          },
                        ),
                      ),
                      SizedBox(width: 11.w),
                      Expanded(
                        child: Obx(
                          () => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.selectedAgeCategory.value,
                                isExpanded: true,
                                alignment: Alignment.centerRight,
                                dropdownColor: Colors.white,
                                hint: const Text(
                                  'اختر الأسبوع',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: 16),
                                ),
                                items:
                                    [
                                      'الاسبوع الاول',
                                      'الاسبوع الثاني',
                                      'الاسبوع الثالث',
                                      'الاسبوع الرابع',
                                      'الاسبوع الخامس',
                                    ].map((week) {
                                      return DropdownMenuItem<String>(
                                        value: week,
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: Text(
                                              week,
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    controller.selectedAgeCategory.value =
                                        value;
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  const AdNativeWidget(),
                  SizedBox(height: 24.h),
                  ToolsButton(
                    text: "احسب الكثافة",
                    onPressed: () => controller.calculateAreas(context),
                  ),

                  SizedBox(height: 32.h),
                  Obx(() {
                    if (controller.shouldDisplayResults.value) {
                      return Column(
                        children: [
                          const SizedBox(height: 33),
                          Padding(
                            padding: const EdgeInsets.only(top: 7, bottom: 3),
                            child: Text(
                              "الارضي",
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                          ToolsResult(
                            title: "المساحة الحالية",
                            value: controller.currentAgeGroundAreaResult.value,
                          ),
                          const SizedBox(height: 5),
                          ToolsResult(
                            title: "المساحة الإجمالية",
                            value: controller.totalGroundAreaResult.value,
                          ),
                          const SizedBox(height: 13),
                          Padding(
                            padding: const EdgeInsets.only(top: 7, bottom: 3),
                            child: Text(
                              "البطاريات",
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                          ToolsResult(
                            title: "مساحة البطاريات",
                            value: controller.batteryCageAreaResult.value,
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink(); // لا تظهر أي شيء حتى يتم الحساب
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
