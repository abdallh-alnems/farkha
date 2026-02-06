import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/class/status_request.dart';
import '../../../../core/constant/theme/colors.dart';
import '../../../../logic/controller/tools_controller/feasibility_study_controller.dart';
import '../../../../core/shared/input_fields/input_field.dart';
import '../../../../core/shared/input_fields/three_input_fields.dart';
import '../../tutorial/feasibility_tutorial.dart';
import '../tools_button.dart';

class InputsSection extends StatelessWidget {
  const InputsSection({
    super.key,
    required this.formKey,
    this.onAfterCalculate,
  });

  final GlobalKey<FormState> formKey;
  final VoidCallback? onAfterCalculate;

  @override
  Widget build(BuildContext context) {
    final FeasibilityController controller = Get.find<FeasibilityController>();

    return Obx(() {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final primaryColor =
          isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

      // إظهار المدخلات إذا كانت مفعلة
      if (controller.showInputs.value) {
        return Column(
          children: [
            const SizedBox(height: 5),
            // Toggle Switches Row - Combined
            Row(
              children: [
                // First Toggle: Normal/Professional Mode
                Expanded(
                  child: Container(
                    key: FeasibilityTutorial.toggleModeKey,
                    child: Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => Text(
                              'عادي',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color:
                                    !controller.isProfessionalMode.value
                                        ? (isDark
                                            ? Colors.white
                                            : Colors.grey[800])
                                        : (isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[500]),
                              ),
                            ),
                          ),
                        ),
                        Obx(
                          () => Transform.scale(
                            scale: 0.9,
                            child: Switch(
                              value: controller.isProfessionalMode.value,
                              onChanged: (value) {
                                controller.toggleProfessionalMode();
                              },
                              activeThumbColor: primaryColor,
                              activeTrackColor: primaryColor.withValues(
                                alpha: 0.3,
                              ),
                              inactiveThumbColor: primaryColor.withValues(
                                alpha: 0.7,
                              ),
                              inactiveTrackColor: primaryColor.withValues(
                                alpha: 0.3,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              overlayColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                              splashRadius: 0,
                              trackOutlineColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                              trackOutlineWidth: WidgetStateProperty.all(0),
                              thumbColor: WidgetStateProperty.all(primaryColor),
                              trackColor: WidgetStateProperty.all(
                                primaryColor.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Obx(
                            () => Text(
                              'احترافي',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color:
                                    controller.isProfessionalMode.value
                                        ? (isDark
                                            ? Colors.white
                                            : Colors.grey[800])
                                        : (isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[500]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 15.w),

                // Second Toggle: Chicken Count/Financial Amount
                Expanded(
                  child: Container(
                    key: FeasibilityTutorial.defaultValuesKey,
                    child: Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => Text(
                              'عدد الفراخ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color:
                                    controller.isChickenCountMode.value
                                        ? (isDark
                                            ? Colors.white
                                            : Colors.grey[800])
                                        : (isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[500]),
                              ),
                            ),
                          ),
                        ),
                        Obx(
                          () => Transform.scale(
                            scale: 0.9,
                            child: Switch(
                              value: !controller.isChickenCountMode.value,
                              onChanged: (value) {
                                controller.toggleCalculationMode();
                              },
                              activeThumbColor: primaryColor,
                              activeTrackColor: primaryColor.withValues(
                                alpha: 0.3,
                              ),
                              inactiveThumbColor: primaryColor.withValues(
                                alpha: 0.7,
                              ),
                              inactiveTrackColor: primaryColor.withValues(
                                alpha: 0.3,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              overlayColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                              splashRadius: 0,
                              trackOutlineColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                              trackOutlineWidth: WidgetStateProperty.all(0),
                              thumbColor: WidgetStateProperty.all(primaryColor),
                              trackColor: WidgetStateProperty.all(
                                primaryColor.withValues(alpha: 0.3),
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
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color:
                                    !controller.isChickenCountMode.value
                                        ? (isDark
                                            ? Colors.white
                                            : Colors.grey[800])
                                        : (isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[500]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 21),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الأسعار',
                  key: FeasibilityTutorial.chickenPriceKey,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.9)
                            : Colors.grey[800],
                  ),
                ),
                Obx(() {
                  final isLoading =
                      controller.pricesStatusRequest.value ==
                      StatusRequest.loading;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: FeasibilityTutorial.stockButtonKey,
                      onTap:
                          isLoading
                              ? null
                              : () => controller.fetchFeasibilityData(),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isLoading
                                  ? AppColors.primaryColor.withValues(
                                    alpha: 0.6,
                                  )
                                  : AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child:
                            isLoading
                                ? SizedBox(
                                  width: 18.w,
                                  height: 18.h,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Text(
                                  'متوسط البورصة',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: InputField(
                    label: 'اللحم الأبيض',
                    controller: controller.chickenSalePriceController,
                    suffixText: 'ج',
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: InputField(
                    label: 'كتكوت الأبيض',
                    controller: controller.chickPriceController,
                    suffixText: 'ج',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Obx(
              () =>
                  controller.isProfessionalMode.value
                      ? ThreeInputFields(
                        firstLabel: 'بادي بالطن',
                        secondLabel: 'نامي بالطن',
                        thirdLabel: 'ناهي بالطن',
                        firstController: controller.badiPriceController,
                        secondController: controller.namiPriceController,
                        thirdController: controller.nahiPriceController,
                        firstSuffix: 'جنيه',
                        secondSuffix: 'جنيه',
                        thirdSuffix: 'جنيه',
                      )
                      : InputField(
                        label: 'متوسط العلف بالطن',
                        controller: controller.averageFeedPriceController,
                        suffixText: 'جنيه',
                      ),
            ),
            const SizedBox(height: 19),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المدخلات',
                  key: FeasibilityTutorial.defaultValuesTitleKey,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.9)
                            : Colors.grey[800],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: FeasibilityTutorial.defaultValuesButtonKey,
                    onTap: () => _setDefaultValues(controller),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'المدخلات الافتراضية',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // عدد الفراخ أو المبلغ المالي
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () =>
                        controller.isChickenCountMode.value
                            ? InputField(
                              label: 'عدد الفراخ',
                              controller: controller.countController,
                            )
                            : InputField(
                              label: 'المبلغ المالي (ج)',
                              controller: controller.budgetController,
                              suffixText: 'ج',
                            ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: InputField(
                    label: 'وزن الفرخ الواحد',
                    controller: controller.defaultWeightController,
                    suffixText: 'كجم',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: InputField(
                    label: 'معدل النافق (%)',
                    controller: controller.mortalityRateController,
                    suffixText: '%',
                    allowZero: true,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: InputField(
                    label: 'النثريات (ج)',
                    controller: controller.overheadController,
                    suffixText: 'ج',
                    allowZero: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 19),

            // Feed Ratios - يختلف حسب الوضع
            Obx(
              () =>
                  controller.isProfessionalMode.value
                      ? // الوضع الاحترافي: 3 مربعات منفصلة
                      ThreeInputFields(
                        firstLabel: 'البادي',
                        secondLabel: 'النامي',
                        thirdLabel: 'الناهي',
                        firstController: controller.badiRatioController,
                        secondController: controller.namiRatioController,
                        thirdController: controller.nahiRatioController,
                        firstHint: '0.5',
                        secondHint: '1.2',
                        thirdHint: '1.8',
                        firstSuffix: 'كجم',
                        secondSuffix: 'كجم',
                        thirdSuffix: 'كجم',
                      )
                      : // الوضع العادي: مربع واحد لمتوسط نسبة العلف
                      InputField(
                        label: 'العلف لكل فرخ',
                        controller: controller.averageFeedRatioController,
                        suffixText: 'كجم',
                      ),
            ),
            const SizedBox(height: 19),

            // زر الحساب
            Container(
              key: FeasibilityTutorial.calculateButtonKey,
              child: ToolsButton(
                text: 'احسب دراسة الجدوي',
                onPressed: () => _onCalculatePressed(context),
              ),
            ),
            const SizedBox(height: 17),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  void _onCalculatePressed(BuildContext context) {
    final FeasibilityController controller = Get.find<FeasibilityController>();

    // التحقق من صحة البيانات
    if (formKey.currentState?.validate() != true) {
      return;
    }

    // التحقق من الأسعار الصفرية
    final chickenPrice =
        int.tryParse(controller.chickenSalePriceController.text) ?? 0;
    final chickPrice = int.tryParse(controller.chickPriceController.text) ?? 0;
    final feedPrice =
        controller.isProfessionalMode.value
            ? ((int.tryParse(controller.badiPriceController.text) ?? 0) +
                    (int.tryParse(controller.namiPriceController.text) ?? 0) +
                    (int.tryParse(controller.nahiPriceController.text) ?? 0)) /
                3
            : (int.tryParse(controller.averageFeedPriceController.text) ?? 0)
                .toDouble();

    final hasZeroPrice =
        chickenPrice == 0 || chickPrice == 0 || feedPrice.round() == 0;

    if (hasZeroPrice) {
      _showZeroPricesDialog(context, controller, onAfterCalculate);
      return;
    }

    controller.calculateFeasibility();
    onAfterCalculate?.call();
  }

  void _showZeroPricesDialog(
    BuildContext context,
    FeasibilityController controller,
    VoidCallback? onAfterCalculate,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog<void>(
      AlertDialog(
        backgroundColor:
            isDark ? AppColors.darkSurfaceColor : AppColors.lightSurfaceColor,
        title: Text(
          'تحذير',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18.sp,
          ),
        ),
        content: Text(
          'يبدو أن بعض الأسعار صفرية. لم يتم تحميل أسعار البورصة بعد؟ '
          'اضغط على متوسط البورصة للحصول على الأسعار الحالية.',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[700],
                fontSize: 14.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back<void>();
              controller.calculateFeasibility();
              onAfterCalculate?.call();
            },
            child: Text(
              'متابعة بالأسعار الحالية',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setDefaultValues(FeasibilityController controller) {
    // تعيين القيم الافتراضية
    controller.defaultWeightController.text = '2.1';
    controller.mortalityRateController.text = '5';
    controller.overheadController.text = '10';

    if (controller.isProfessionalMode.value) {
      // في الوضع الاحترافي، استخدم القيم الافتراضية الأصلية
      controller.badiRatioController.text = '0.5';
      controller.namiRatioController.text = '1.2';
      controller.nahiRatioController.text = '1.8';
    } else {
      // في الوضع العادي، استخدم القيمة الافتراضية 3.5
      controller.averageFeedRatioController.text = '3.5';
    }
  }
}
