import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/class/status_request.dart';
import '../../../../core/constant/theme/color.dart';
import '../../../../core/package/snackbar_message.dart';
import '../../../../logic/controller/tools_controller/feasibility_study_controller.dart';
import '../tools_button.dart';

class InputsSection extends StatelessWidget {
  const InputsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final FeasibilityController controller = Get.find<FeasibilityController>();

    return Column(
      children: [
        const SizedBox(height: 5),
        // Inputs section
        Row(
          children: [
            Text(
              'بيانات الدراسة',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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

        const SizedBox(height: 15),

        // Inputs with loading state
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
                                // الأسعار title with بورصة button
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'الأسعار',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap:
                                          () =>
                                              controller.fetchFeasibilityData(),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue[200]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          'متوسط اسعار البورصة',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),

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

                                const SizedBox(height: 19),

                                // Toggle Switch between الأسعار and المعايير الأساسية
                                Row(
                                  children: [
                                    Expanded(
                                      child: Obx(
                                        () => Text(
                                          'عدد الفراخ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                controller
                                                        .isChickenCountMode
                                                        .value
                                                    ? Colors.grey[800]
                                                    : Colors.grey[500],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Obx(
                                      () => Transform.scale(
                                        scale: 1.0,
                                        child: Switch(
                                          value:
                                              !controller
                                                  .isChickenCountMode
                                                  .value,
                                          onChanged: (value) {
                                            controller.toggleCalculationMode();
                                          },
                                          activeColor: AppColor.primaryColor,
                                          activeTrackColor: AppColor
                                              .primaryColor
                                              .withOpacity(0.3),
                                          inactiveThumbColor:
                                              AppColor.primaryColor,
                                          inactiveTrackColor: AppColor
                                              .primaryColor
                                              .withOpacity(0.3),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          overlayColor: WidgetStateProperty.all(
                                            Colors.transparent,
                                          ),
                                          splashRadius: 0,
                                          trackOutlineColor:
                                              WidgetStateProperty.all(
                                                Colors.transparent,
                                              ),
                                          trackOutlineWidth:
                                              WidgetStateProperty.all(0),
                                          thumbColor: WidgetStateProperty.all(
                                            AppColor.primaryColor,
                                          ),
                                          trackColor: WidgetStateProperty.all(
                                            AppColor.primaryColor.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Obx(
                                        () => Text(
                                          'مبلغ مالي',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                !controller
                                                        .isChickenCountMode
                                                        .value
                                                    ? Colors.grey[800]
                                                    : Colors.grey[500],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 19),

                                // Default Values Section
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'المعايير الأساسية',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _loadDefaultStandards(),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10.w,
                                              vertical: 4.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green[50],
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: Colors.green[200]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              'القيم الافتراضية',
                                              style: TextStyle(
                                                fontSize: 9.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.green[700],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),

                                    // First Row: Weight and Input (count/budget)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                controller
                                                    .defaultWeightController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'الوزن',
                                              hintText: '2.5',
                                              suffixText: 'كجم لكل فرخ',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                  color: Colors.blue,
                                                  width: 2,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Obx(
                                            () =>
                                                controller
                                                        .isChickenCountMode
                                                        .value
                                                    ? TextFormField(
                                                      controller:
                                                          controller
                                                              .countController,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration: InputDecoration(
                                                        labelText: 'عدد الفراخ',
                                                        border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          borderSide: BorderSide(
                                                            color:
                                                                Colors
                                                                    .grey[300]!,
                                                            width: 1.5,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              borderSide:
                                                                  const BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .blue,
                                                                    width: 2,
                                                                  ),
                                                            ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        contentPadding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 8,
                                                            ),
                                                      ),
                                                    )
                                                    : TextFormField(
                                                      controller:
                                                          controller
                                                              .budgetController,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration: InputDecoration(
                                                        labelText:
                                                            'المبلغ المالي (ج)',
                                                        border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          borderSide: BorderSide(
                                                            color:
                                                                Colors
                                                                    .grey[300]!,
                                                            width: 1.5,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              borderSide:
                                                                  const BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .blue,
                                                                    width: 2,
                                                                  ),
                                                            ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        contentPadding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 8,
                                                            ),
                                                      ),
                                                    ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 10.h),

                                    // Second Row: Mortality Rate and Overhead Expenses
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                controller
                                                    .mortalityRateController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'معدل النافق',
                                              hintText: '5',
                                              suffixText: '%',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                  color: Colors.blue,
                                                  width: 2,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                controller.overheadController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'النثريات',
                                              hintText: '10',
                                              suffixText: 'ج لكل فرخ',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                  color: Colors.blue,
                                                  width: 2,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 10.h),

                                    // Feed Ratios Row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                controller.badiRatioController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'البادي',
                                              hintText: '0.5',
                                              suffixText: 'كجم',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                  color: Colors.blue,
                                                  width: 2,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                controller.namiRatioController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'النامي',
                                              hintText: '1.2',
                                              suffixText: 'كجم',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                  color: Colors.blue,
                                                  width: 2,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                controller.nahiRatioController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'الناهي',
                                              hintText: '1.8',
                                              suffixText: 'كجم',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                  color: Colors.blue,
                                                  width: 2,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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

  void _loadDefaultStandards() {
    final FeasibilityController controller = Get.find<FeasibilityController>();

    // Load default values into fields
    controller.defaultWeightController.text =
        controller.defaultWeight.value.toString();
    controller.mortalityRateController.text =
        controller.mortalityRate.value.toInt().toString();
    controller.overheadController.text =
        controller.overheadPerChicken.value.toInt().toString();
    controller.badiRatioController.text =
        controller.badiFeedRatio.value.toString();
    controller.namiRatioController.text =
        controller.namiFeedRatio.value.toString();
    controller.nahiRatioController.text =
        controller.nahiFeedRatio.value.toString();
  }
}
