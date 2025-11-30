import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constant/theme/colors.dart';
import '../../../../core/shared/snackbar_message.dart';
import '../../../../logic/controller/tools_controller/feasibility_study_controller.dart';
import '../../input_fields/input_field.dart';
import '../../input_fields/three_input_fields.dart';
import '../../tutorial/feasibility_tutorial.dart';
import '../tools_button.dart';

class InputsSection extends StatelessWidget {
  const InputsSection({super.key, required this.formKey});

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    final FeasibilityController controller = Get.find<FeasibilityController>();

    return Obx(() {
      // إظهار المدخلات إذا كانت مفعلة
      if (controller.showInputs.value) {
        return Column(
          children: [
            const SizedBox(height: 5),
            // Toggle Switches Row - Combined
            Container(
              child: Row(
                children: [
                  // First Toggle: Normal/Professional Mode
                  Expanded(
                    child: Container(
                      key: FeasibilityTutorial.toggleModeKey,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              child: Obx(
                                () => Text(
                                  'عادي',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        !controller.isProfessionalMode.value
                                            ? Colors.grey[800]
                                            : Colors.grey[500],
                                  ),
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
                                activeThumbColor: AppColors.primaryColor,
                                activeTrackColor: AppColors.primaryColor
                                    .withValues(alpha: 0.3),
                                inactiveThumbColor: AppColors.primaryColor,
                                inactiveTrackColor: AppColors.primaryColor
                                    .withValues(alpha: 0.3),
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
                                thumbColor: WidgetStateProperty.all(
                                  AppColors.primaryColor,
                                ),
                                trackColor: WidgetStateProperty.all(
                                  AppColors.primaryColor.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Obx(
                                () => Text(
                                  'احترافي',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        controller.isProfessionalMode.value
                                            ? Colors.grey[800]
                                            : Colors.grey[500],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // Second Toggle: Chicken Count/Financial Amount
                  Expanded(
                    child: Container(
                      key: FeasibilityTutorial.defaultValuesKey,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              child: Obx(
                                () => Text(
                                  'عدد الفراخ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        controller.isChickenCountMode.value
                                            ? Colors.grey[800]
                                            : Colors.grey[500],
                                  ),
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
                                activeThumbColor: AppColors.primaryColor,
                                activeTrackColor: AppColors.primaryColor
                                    .withValues(alpha: 0.3),
                                inactiveThumbColor: AppColors.primaryColor,
                                inactiveTrackColor: AppColors.primaryColor
                                    .withValues(alpha: 0.3),
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
                                thumbColor: WidgetStateProperty.all(
                                  AppColors.primaryColor,
                                ),
                                trackColor: WidgetStateProperty.all(
                                  AppColors.primaryColor.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Obx(
                                () => Text(
                                  'مبلغ مالي',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        !controller.isChickenCountMode.value
                                            ? Colors.grey[800]
                                            : Colors.grey[500],
                                  ),
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
            ),
            const SizedBox(height: 21),

            // الأسعار title with بورصة button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الأسعار',
                  key: FeasibilityTutorial.chickenPriceKey,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.9)
                        : Colors.grey[800],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: FeasibilityTutorial.stockButtonKey,
                    onTap: () => controller.fetchFeasibilityData(),
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
                        'متوسط البورصة',
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

            // أسعار الدجاج - ثابتة في كلا الوضعين
            Row(
              children: [
                Expanded(
                  child: InputField(
                    label: 'اللحم الأبيض',
                    controller: controller.chickenSalePriceController,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: InputField(
                    label: 'كتكوت الأبيض',
                    controller: controller.chickPriceController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // أسعار العلف - يختلف حسب الوضع
            Obx(
              () =>
                  controller.isProfessionalMode.value
                      ? // الوضع الاحترافي: 3 مربعات منفصلة
                      ThreeInputFields(
                        firstLabel: 'بادي (طن)',
                        secondLabel: 'نامي (طن)',
                        thirdLabel: 'ناهي (طن)',
                        firstController: controller.badiPriceController,
                        secondController: controller.namiPriceController,
                        thirdController: controller.nahiPriceController,
                      )
                      : // الوضع العادي: مربع واحد لمتوسط سعر العلف
                      InputField(
                        label: 'متوسط العلف (طن)',
                        controller: controller.averageFeedPriceController,
                      ),
            ),
            const SizedBox(height: 19),

            // القيم الافتراضية title with زر
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المدخلات',
                    key: FeasibilityTutorial.defaultValuesTitleKey,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.9)
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
                            ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: InputField(
                    label: 'وزن الفرخ',
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
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: InputField(
                    label: 'النثريات (ج)',
                    controller: controller.overheadController,
                    suffixText: 'ج',
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
                text: "احسب دراسة الجدوي",
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
    if (!formKey.currentState!.validate()) {
      return;
    }

    // التحقق من أن الأسعار مملوءة
    if (controller.isProfessionalMode.value) {
      // في الوضع الاحترافي، تحقق من الأسعار الثلاثة
      final badiPrice = int.tryParse(controller.badiPriceController.text);
      if (badiPrice == null || badiPrice < 0) {
        _showError(context, 'يرجى إدخال سعر صحيح للبادي');
        return;
      }

      final namiPrice = int.tryParse(controller.namiPriceController.text);
      if (namiPrice == null || namiPrice < 0) {
        _showError(context, 'يرجى إدخال سعر صحيح للنامي');
        return;
      }

      final nahiPrice = int.tryParse(controller.nahiPriceController.text);
      if (nahiPrice == null || nahiPrice < 0) {
        _showError(context, 'يرجى إدخال سعر صحيح للناهي');
        return;
      }
    } else {
      // في الوضع العادي، تحقق من متوسط سعر العلف فقط
      final averageFeedPrice = int.tryParse(
        controller.averageFeedPriceController.text,
      );
      if (averageFeedPrice == null || averageFeedPrice < 0) {
        _showError(context, 'يرجى إدخال سعر صحيح لمتوسط العلف');
        return;
      }
    }

    FocusScope.of(context).unfocus();
    controller.calculateFeasibility();
  }

  void _showError(BuildContext context, String message) {
    SnackbarMessage.show(context, message, icon: Icons.error);
  }

  void _setDefaultValues(FeasibilityController controller) {
    // تعيين القيم الافتراضية
    controller.defaultWeightController.text = '2.5';
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
