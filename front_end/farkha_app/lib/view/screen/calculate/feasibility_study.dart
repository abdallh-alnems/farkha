import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/class/handling_data.dart';
import '../../../core/shared/calculate_result.dart';
import '../../../core/shared/chicken_form.dart';
import '../../../logic/controller/calculate_controller/feasibility_study_controller.dart';
import '../../widget/ad/banner/ad_second_banner.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/calculate/feasibility_study_title.dart';

class FeasibilityStudy extends StatelessWidget {
  FeasibilityStudy({super.key});

  final FeasibilityController controller = Get.put(FeasibilityController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(
            text: "دراسة جدول",
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ChickenForm(
                controller: controller.countChickens,
                notShowDropdownButton: true.obs,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 9, bottom: 15).r,
                    child: ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        controller.calculateFeasibility();
                      },
                      child: const Text('احسب'),
                    ),
                  ),
                  Obx(() => HandlingDataView(
                        statusRequest: controller.statusRequest,
                        widget: Column(
                          children: [
                            FeasibilityStudyTitle(
                              title: "التكاليف",
                            ),
                            ..._buildCostResults(),
                            FeasibilityStudyTitle(
                              title: "المبيعات",
                            ),
                            CalculateResult(
                              text: controller.salesResult.value,
                            ),
                            FeasibilityStudyTitle(
                              title: "الارباح",
                            ),
                            CalculateResult(
                              text: controller.profitResult.value,
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              controller.showStudyDetailsDialog();
            },
            child: Text(
              "كيف يتم عمل دراسة الجدول",
              style: TextStyle(color: Colors.black38),
            ),
          ),
          SizedBox(height: 21.h),
        ],
      ),
      bottomNavigationBar: const AdSecondBanner(),
    );
  }

  List<Widget> _buildCostResults() {
    return [
      CalculateResult(
        text: controller.chickenCostResult.value,
      ),
      CalculateResult(
        text: controller.feedCostResult.value,
      ),
      CalculateResult(
        text: controller.overheadCostResult.value,
      ),
      CalculateResult(
        text: controller.mortalityResult.value,
      ),
      CalculateResult(
        text: controller.totalCostResult.value,
      ),
    ];
  }
}
