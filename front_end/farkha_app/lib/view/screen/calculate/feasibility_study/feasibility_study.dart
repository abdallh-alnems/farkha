import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/class/handling_data.dart';
import '../../../../core/constant/routes/route.dart';
import '../../../widget/calculate/calculate_result.dart';
import '../../../../core/shared/chicken_form.dart';
import '../../../../logic/controller/calculate_controller/feasibility_study_controller.dart';
import '../../../widget/app/ad/banner/ad_second_banner.dart';
import '../../../widget/bar/app_bar/custom_app_bar.dart';
import '../../../widget/calculate/feasibility_study_title.dart';

class FeasibilityStudy extends StatelessWidget {
  FeasibilityStudy({super.key});

  final FeasibilityController controller = Get.put(FeasibilityController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: "دراسة جدوي"),
          ChickenForm(
            controller: controller.countController,
            notShowDropdownButton: true.obs,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 19, bottom: 17).r,
                child: ElevatedButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    controller.calculateFeasibility();
                  },
                  child: Text("احسب دراسة الجدوي"),
                ),
              ),
              Obx(() {
                if (controller.showResults.value) {
                  return HandlingDataView(
                    statusRequest: controller.statusRequest,
                    widget: Column(
                      children: [
                        ResultTitle(title: "التكاليف"),
                        ..._buildCostResults(),
                        ResultTitle(title: "المبيعات"),
                        CalculateResult(text: controller.totalSalesText.value),
                        ResultTitle(title: "الارباح"),
                        CalculateResult(text: controller.profitText.value),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(top: 35),
                    child: Text('ادخل عدد الفراخ'),
                  );
                }
              }),
            ],
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed(AppRoute.howToDoAFeasibilityStudy);
            },
            child: Text(
              "كيف يتم عمل دراسة الجدوي",
              style: TextStyle(color: Colors.black38),
            ),
          ),
          SizedBox(height: 21.h)
        ],
      ),
      bottomNavigationBar: const AdSecondBanner(),
    );
  }

  List<Widget> _buildCostResults() {
    // التأكد من أن القيم تظهر بشكل صحيح في واجهة المستخدم
    return [
      CalculateResult(text: controller.chickenCostText.value),
      CalculateResult(text: controller.feedCostText.value),
      CalculateResult(text: controller.overheadCostText.value),
      CalculateResult(text: controller.mortalityRateText.value),
      CalculateResult(text: controller.totalCostText.value),
    ];
  }
}
