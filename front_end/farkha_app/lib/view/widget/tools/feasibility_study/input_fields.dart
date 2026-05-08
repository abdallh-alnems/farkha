import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/class/status_request.dart';
import '../../../../core/constant/theme/theme.dart';
import '../../../../logic/controller/tools_controller/feasibility_study_controller.dart';
import '../../../../core/shared/input_fields/input_field.dart';
import '../../../../core/shared/input_fields/three_input_fields.dart';
import '../../tutorial/feasibility_tutorial.dart';

class ModeToggleCard extends StatelessWidget {
  final FeasibilityController controller;
  final bool isDark;
  final ColorScheme colorScheme;

  const ModeToggleCard({
    super.key,
    required this.controller,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevatedColor
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineColor.withValues(alpha: 0.4)
              : AppColors.lightOutlineColor.withValues(alpha: 0.6),
        ),
        boxShadow: isDark
            ? null
            : [
                AppElevation.shadow(
                  opacity: 0.06,
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TogglePill(
              containerKey: FeasibilityTutorial.toggleModeKey,
              isDark: isDark,
              colorScheme: colorScheme,
              optionLeft: 'عادي',
              optionRight: 'احترافي',
              isRightSelected:
                  controller.isProfessionalMode.value,
              onChanged: () => controller.toggleProfessionalMode(),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TogglePill(
              containerKey: FeasibilityTutorial.defaultValuesKey,
              isDark: isDark,
              colorScheme: colorScheme,
              optionLeft: 'عدد الفراخ',
              optionRight: 'مبلغ مالي',
              isRightSelected:
                  !controller.isChickenCountMode.value,
              onChanged: () =>
                  controller.toggleCalculationMode(),
            ),
          ),
        ],
      ),
    );
  }
}

class TogglePill extends StatelessWidget {
  final Key? containerKey;
  final bool isDark;
  final ColorScheme colorScheme;
  final String optionLeft;
  final String optionRight;
  final bool isRightSelected;
  final VoidCallback onChanged;

  const TogglePill({
    super.key,
    this.containerKey,
    required this.isDark,
    required this.colorScheme,
    required this.optionLeft,
    required this.optionRight,
    required this.isRightSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: containerKey,
      padding:
          EdgeInsets.symmetric(vertical: 3.h, horizontal: 3.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceColor
            : colorScheme.outline.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: isRightSelected ? onChanged : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: !isRightSelected
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  optionLeft,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: !isRightSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: !isRightSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface
                            .withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: !isRightSelected ? onChanged : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isRightSelected
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  optionRight,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: isRightSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isRightSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface
                            .withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PricesInputFields extends StatelessWidget {
  final FeasibilityController controller;

  const PricesInputFields({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InputField(
                label: 'اللحم الأبيض',
                controller: controller.chickenSalePriceController,
                suffixText: 'ج',
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: InputField(
                label: 'كتكوت الأبيض',
                controller: controller.chickPriceController,
                suffixText: 'ج',
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Obx(
          () => controller.isProfessionalMode.value
              ? ThreeInputFields(
                  firstLabel: 'بادي بالطن',
                  secondLabel: 'نامي بالطن',
                  thirdLabel: 'ناهي بالطن',
                  firstController:
                      controller.badiPriceController,
                  secondController:
                      controller.namiPriceController,
                  thirdController:
                      controller.nahiPriceController,
                  firstSuffix: 'جنيه',
                  secondSuffix: 'جنيه',
                  thirdSuffix: 'جنيه',
                )
              : InputField(
                  label: 'متوسط العلف بالطن',
                  controller:
                      controller.averageFeedPriceController,
                  suffixText: 'جنيه',
                ),
        ),
      ],
    );
  }
}

class StockButton extends StatelessWidget {
  final FeasibilityController controller;

  const StockButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading =
          controller.pricesStatusRequest.value ==
              StatusRequest.loading;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          key: FeasibilityTutorial.stockButtonKey,
          onTap: isLoading
              ? null
              : () => controller.fetchFeasibilityData(),
          borderRadius:
              BorderRadius.circular(AppDimens.radiusSm),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: 14.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: isLoading
                  ? AppColors.accentColor
                      .withValues(alpha: 0.7)
                  : AppColors.accentColor,
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: isLoading
                ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 14.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        'متوسط البورصة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
    });
  }
}

class DefaultValuesButton extends StatelessWidget {
  final VoidCallback onTap;

  const DefaultValuesButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: FeasibilityTutorial.defaultValuesButtonKey,
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(AppDimens.radiusSm),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 14.w, vertical: 7.h),
          decoration: BoxDecoration(
            color:
                colorScheme.primary.withValues(alpha: 0.1),
            borderRadius:
                BorderRadius.circular(AppDimens.radiusSm),
            border: Border.all(
              color:
                  colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_fix_high,
                size: 14.sp,
                color: colorScheme.primary,
              ),
              SizedBox(width: 5.w),
              Text(
                'المدخلات الافتراضية',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ParamsInputFields extends StatelessWidget {
  final FeasibilityController controller;

  const ParamsInputFields({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(
                () => controller.isChickenCountMode.value
                    ? InputField(
                        label: 'عدد الفراخ',
                        controller: controller.countController,
                      )
                    : InputField(
                        label: 'المبلغ المالي (ج)',
                        controller:
                            controller.budgetController,
                        suffixText: 'ج',
                      ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: InputField(
                label: 'وزن الفرخ الواحد',
                controller:
                    controller.defaultWeightController,
                suffixText: 'كجم',
                hintText: 'مثال: 2.1',
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: InputField(
                label: 'معدل النافق (%)',
                controller:
                    controller.mortalityRateController,
                suffixText: '%',
                allowZero: true,
              ),
            ),
            SizedBox(width: 10.w),
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
        SizedBox(height: 10.h),
        Obx(
          () => controller.isProfessionalMode.value
              ? ThreeInputFields(
                  firstLabel: 'البادي',
                  secondLabel: 'النامي',
                  thirdLabel: 'الناهي',
                  firstController:
                      controller.badiRatioController,
                  secondController:
                      controller.namiRatioController,
                  thirdController:
                      controller.nahiRatioController,
                  firstHint: '0.5',
                  secondHint: '1.2',
                  thirdHint: '1.8',
                  firstSuffix: 'كجم',
                  secondSuffix: 'كجم',
                  thirdSuffix: 'كجم',
                )
              : InputField(
                  label: 'العلف لكل فرخ',
                  controller:
                      controller.averageFeedRatioController,
                  suffixText: 'كجم',
                  hintText: 'مثال: 3.5',
                ),
        ),
      ],
    );
  }
}
