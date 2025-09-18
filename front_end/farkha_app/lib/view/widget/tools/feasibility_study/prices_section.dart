import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/class/status_request.dart';
import '../../../../core/package/snackbar_message.dart';
import '../../../../logic/controller/tools_controller/feasibility_study_controller.dart';
import '../tools_button.dart';

class PricesSection extends StatelessWidget {
  const PricesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final FeasibilityController controller = Get.find<FeasibilityController>();

    return Column(
      children: [
        const SizedBox(height: 5),
        // Price inputs section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'الأسعار',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 9),
                Obx(
                  () => GestureDetector(
                    onTap: () {
                      controller.isPricesExpanded.value =
                          !controller.isPricesExpanded.value;
                    },
                    child: AnimatedRotation(
                      turns: controller.isPricesExpanded.value ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => controller.fetchFeasibilityData(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!, width: 1),
                ),
                child: Text(
                  'متوسط اسعار البورصة',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // Price inputs with loading state
        Obx(
          () => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: controller.isPricesExpanded.value ? null : 0,
            child:
                controller.isPricesExpanded.value
                    ? Column(
                      children: [
                        Obx(() {
                          if (controller.pricesStatusRequest ==
                              StatusRequest.loading) {
                            return Center(
                              child: Lottie.asset(
                                'assets/lottie/loading.json',
                                width: 80.w,
                                height: 80.h,
                              ),
                            );
                          } else if (controller.pricesStatusRequest ==
                                  StatusRequest.failure ||
                              controller.pricesStatusRequest ==
                                  StatusRequest.serverFailure ||
                              controller.pricesStatusRequest ==
                                  StatusRequest.offlineFailure) {
                            return Center(
                              child: Lottie.asset(
                                'assets/lottie/error.json',
                                width: 60.w,
                                height: 60.h,
                              ),
                            );
                          } else {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            controller
                                                .chickenSalePriceController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'لحم ابيض',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            controller.chickPriceController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'كتكوت ابيض ',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 12.h),

                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            controller.badiPriceController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'بادي (طن)',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            controller.namiPriceController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'نامي (طن)',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 12.h),

                                // ناهي (Nahi Price) - single field in center
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: TextFormField(
                                    controller: controller.nahiPriceController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'ناهي (طن)',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        }),
                        const SizedBox(height: 19),

                        // Calculate button
                        ToolsButton(
                          text: "احسب دراسة الجدوي",
                          onPressed: () => _onCalculatePressed(context),
                        ),
                      ],
                    )
                    : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  void _onCalculatePressed(BuildContext context) {
    final FeasibilityController controller = Get.find<FeasibilityController>();

    // Validate based on current mode
    if (controller.isChickenCountMode.value) {
      final chickenCount = controller.countController.text;
      final count = int.tryParse(chickenCount);

      if (count == null || count <= 0) {
        _showError(context, 'يرجى إدخال عدد صحيح من الفراخ');
        return;
      }
    } else {
      final budget = controller.budgetController.text;
      final budgetAmount = double.tryParse(budget);

      if (budgetAmount == null || budgetAmount <= 0) {
        _showError(context, 'يرجى إدخال مبلغ مالي صحيح');
        return;
      }
    }

    // Validate price inputs
    final prices = [
      controller.chickenSalePriceController.text,
      controller.chickPriceController.text,
      controller.badiPriceController.text,
      controller.namiPriceController.text,
      controller.nahiPriceController.text,
    ];

    for (int i = 0; i < prices.length; i++) {
      final price = int.tryParse(prices[i]);
      if (price == null || price < 0) {
        final fieldNames = ['لحم ابيض', 'ابيض (شركات)', 'بادي', 'نامي', 'ناهي'];
        _showError(context, 'يرجى إدخال سعر صحيح لـ ${fieldNames[i]}');
        return;
      }
    }

    FocusScope.of(context).unfocus();
    controller.isPricesExpanded.value = false; // إخفاء حقول الأسعار
    controller.calculateFeasibility();
  }

  void _showError(BuildContext context, String message) {
    SnackbarMessage.show(context, message, icon: Icons.error);
  }
}
