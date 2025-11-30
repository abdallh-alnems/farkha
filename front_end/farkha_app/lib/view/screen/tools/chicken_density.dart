import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../logic/controller/tools_controller/chicken_density_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/input_fields/input_field.dart';
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
      appBar: const CustomAppBar(text: 'كثافة الفراخ'),
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
                        child: Obx(() {
                          return DropdownButtonFormField<String>(
                            initialValue: controller.selectedAgeCategory.value,
                            decoration: InputDecoration(
                              labelText: 'اختر الأسبوع',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                            ),
                            dropdownColor:
                                Theme.of(context).colorScheme.surface,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
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
                                    child: Text(
                                      week,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                controller.selectedAgeCategory.value = value;
                              }
                            },
                          );
                        }),
                      ),
                      SizedBox(width: 11.w),

                      Expanded(
                        child: InputField(
                          label: 'عدد الفراخ',
                          onChanged: (value) {
                            controller.chickenCountTextController.text = value;
                          },
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
                          ToolsResult(
                            title: "مساحة التربية الارضي",
                            value: controller.currentAgeGroundAreaResult.value,
                          ),
                          const SizedBox(height: 11),
                          ToolsResult(
                            title: "المساحة الإجمالية",
                            value: controller.totalGroundAreaResult.value,
                          ),
                          const SizedBox(height: 33),

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
