import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constant/theme/color.dart';
import '../../../../logic/controller/tools_controller/feasibility_study_controller.dart';

class InputSection extends StatelessWidget {
  const InputSection({super.key});

  @override
  Widget build(BuildContext context) {
    final FeasibilityController controller = Get.find<FeasibilityController>();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey[50]!],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!controller.isChickenCountMode.value) {
                              controller.toggleCalculationMode();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              gradient:
                                  controller.isChickenCountMode.value
                                      ? LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColor.primaryColor,
                                          AppColor.primaryColor.withOpacity(
                                            0.8,
                                          ),
                                        ],
                                      )
                                      : null,
                              color:
                                  controller.isChickenCountMode.value
                                      ? null
                                      : Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    controller.isChickenCountMode.value
                                        ? AppColor.primaryColor
                                        : Colors.grey[300]!,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'عدد الفراخ',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        controller.isChickenCountMode.value
                                            ? Colors.white
                                            : Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'دراسة بالعدد',
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    color:
                                        controller.isChickenCountMode.value
                                            ? Colors.white70
                                            : Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (controller.isChickenCountMode.value) {
                              controller.toggleCalculationMode();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              gradient:
                                  !controller.isChickenCountMode.value
                                      ? LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColor.primaryColor,
                                          AppColor.primaryColor.withOpacity(
                                            0.8,
                                          ),
                                        ],
                                      )
                                      : null,
                              color:
                                  !controller.isChickenCountMode.value
                                      ? null
                                      : Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    !controller.isChickenCountMode.value
                                        ? AppColor.primaryColor
                                        : Colors.grey[300]!,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'مبلغ مالي',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        !controller.isChickenCountMode.value
                                            ? Colors.white
                                            : Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'دراسة بالميزانية',
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    color:
                                        !controller.isChickenCountMode.value
                                            ? Colors.white70
                                            : Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 9.h),
                  // Input field based on mode
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.03),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child:
                        controller.isChickenCountMode.value
                            ? TextFormField(
                              controller: controller.countController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'عدد الفراخ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey[100]!,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColor.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[15],
                              ),
                            )
                            : TextFormField(
                              controller: controller.budgetController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'المبلغ المالي (ج)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey[200]!,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColor.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[15],
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
