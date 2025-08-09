import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/class/handling_data.dart';
import '../../../../core/constant/routes/route.dart';
import '../../../widget/ad/banner.dart';
import '../../../widget/ad/native.dart';
import '../../../widget/calculate/calculate_button.dart';
import '../../../../logic/controller/calculate_controller/feasibility_study_controller.dart';
import '../../../widget/app_bar/custom_app_bar.dart';
import '../../../widget/calculate/feasibility_study/feasibility_study_title.dart';
import '../../../../core/shared/bottom_message.dart';
import '../../../../core/shared/input_fields/input_field.dart';

class FeasibilityStudy extends StatelessWidget {
  FeasibilityStudy({super.key});

  final FeasibilityController controller = Get.put(FeasibilityController());

  void _onCalculatePressed(BuildContext context) {
    final chickenCount = controller.countController.text;
    final count = int.tryParse(chickenCount);

    if (count == null || count <= 0) {
      BottomMessage.show(context, 'يرجى إدخال عدد صحيح من الفراخ');
      return;
    }

    FocusScope.of(context).unfocus();
    controller.calculateFeasibility();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: 'دراسة جدوي'),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 19.w),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: SingleChildScrollView(
                  child: Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: controller.countController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'عدد الفراخ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 17.h),
                          child: CalculateButton(
                            text: "احسب دراسة الجدوي",
                            onPressed: () => _onCalculatePressed(context),
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
                                  // CalculateResult(
                                  //   text: controller.totalSalesText.value,
                                  // ),
                                  ResultTitle(title: "الارباح"),
                                  // CalculateResult(
                                  //   text: controller.profitText.value,
                                  // ),
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
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed(AppRoute.howToDoAFeasibilityStudy);
            },
            child: Text(
              "! كيف يتم عمل دراسة الجدوي",
              style: TextStyle(color: Colors.black),
            ),
          ),
          SizedBox(height: 15.h),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(adIndex: 1),
    );
  }

  List<Widget> _buildCostResults() {
    return [
      // CalculateResult(text: controller.chickenCostText.value),
      // CalculateResult(text: controller.feedCostText.value),
      // CalculateResult(text: controller.overheadCostText.value),
      // CalculateResult(text: controller.mortalityRateText.value),
      // CalculateResult(text: controller.totalCostText.value),
    ];
  }
}
