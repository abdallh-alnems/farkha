import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/color.dart';
import '../../../core/shared/input_fields/age_dropdown.dart';
import '../../../logic/controller/tools_controller/vaccination_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/app_bar/custom_app_bar.dart';

class VaccinationSchedule extends StatelessWidget {
  const VaccinationSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VaccinationController());

    return Scaffold(
      appBar: const CustomAppBar(
        text: 'جدول التطعيم',
        toolKey: 'vaccinationScheduleDialog',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Age Selector
            Obx(
              () => AgeDropdown(
                selectedAge:
                    controller.currentAge.value == 0
                        ? null
                        : controller.currentAge.value,
                onAgeChanged: controller.setCurrentAge,
                maxAge: 30,
                hint: 'اختر العمر',
              ),
            ),

            const SizedBox(height: 20),
            const AdNativeWidget(),
            const SizedBox(height: 20),

            // Results Section
            Obx(() {
              // Only show results if an age is selected
              if (controller.currentAge.value == 0) {
                return const SizedBox.shrink();
              }

              final currentVaccination = controller.currentVaccination.value;
              final nextVaccination = controller.nextVaccination.value;

              return Column(
                children: [
                  // Current Vaccination
                  if (currentVaccination != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColor.primaryColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.today,
                                color: AppColor.primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "التحصين الحالي (عمر ${currentVaccination.age} يوم)",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentVaccination.vaccineName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentVaccination.notes,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            "لا يوجد تحصين لهذا العمر",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Next Vaccination
                  if (nextVaccination != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                color: Colors.green,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "التحصين القادم (عمر ${nextVaccination.age} يوم)",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            nextVaccination.vaccineName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            nextVaccination.notes,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            "لا يوجد تحصين قادم",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
