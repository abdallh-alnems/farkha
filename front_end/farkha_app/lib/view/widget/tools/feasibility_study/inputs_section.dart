import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constant/strings/app_strings.dart';
import '../../../../core/constant/theme/theme.dart';
import '../../../../core/functions/number_format.dart';
import '../../../../logic/controller/tools_controller/feasibility_study_controller.dart';
import '../tools_button.dart';
import 'input_fields.dart';

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
    final FeasibilityController controller =
        Get.find<FeasibilityController>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (!controller.showInputs.value) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModeToggleCard(
            controller: controller,
            isDark: isDark,
            colorScheme: colorScheme,
          ),
          SizedBox(height: 20.h),
          _buildSectionHeader(
            context,
            title: 'الأسعار',
            icon: Icons.payments_outlined,
            trailing: StockButton(controller: controller),
          ),
          SizedBox(height: 10.h),
          _buildInputsCard(
            context,
            isDark,
            colorScheme,
            children: [
              PricesInputFields(controller: controller),
            ],
          ),
          SizedBox(height: 20.h),
          _buildSectionHeader(
            context,
            title: 'المدخلات',
            icon: Icons.tune,
            trailing: DefaultValuesButton(
              onTap: () => _setDefaultValues(controller),
            ),
          ),
          SizedBox(height: 10.h),
          _buildInputsCard(
            context,
            isDark,
            colorScheme,
            children: [
              ParamsInputFields(controller: controller),
            ],
          ),
          SizedBox(height: 20.h),
          ToolsButton(
            text: 'احسب دراسة الجدوى',
            onPressed: () => _onCalculatePressed(context),
          ),
          SizedBox(height: 12.h),
        ],
      );
    });
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
    Key? key,
    Widget? trailing,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      key: key,
      padding: EdgeInsetsDirectional.only(start: 4.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              size: 18.sp,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                height: 1.3,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildInputsCard(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme, {
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevatedColor
            : colorScheme.surface,
        borderRadius:
            BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineColor
                  .withValues(alpha: 0.4)
              : AppColors.lightOutlineColor
                  .withValues(alpha: 0.6),
        ),
        boxShadow: isDark
            ? null
            : [
                AppElevation.shadow(
                  opacity: 0.05,
                  blurRadius: 10,
                ),
              ],
      ),
      child: Column(children: children),
    );
  }

  void _onCalculatePressed(BuildContext context) {
    final FeasibilityController controller =
        Get.find<FeasibilityController>();

    if (formKey.currentState?.validate() != true) {
      return;
    }

    final chickPrice =
        tryParseInt(controller.chickPriceController.text) ?? 0;
    final feedPrice =
        controller.isProfessionalMode.value
            ? ((tryParseInt(controller.badiPriceController.text) ??
                        0) +
                    (tryParseInt(controller.namiPriceController.text) ??
                        0) +
                    (tryParseInt(controller.nahiPriceController.text) ??
                        0)) /
                3
            : (tryParseInt(controller.averageFeedPriceController.text) ??
                    0)
                .toDouble();

    final hasZeroPrice =
        chickPrice == 0 || feedPrice.round() == 0;

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
    final colorScheme = Theme.of(context).colorScheme;

    Get.dialog<void>(
      AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppDimens.radiusLg),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppColors.warningColor, size: 24.sp),
            SizedBox(width: 10.w),
            Text(
              'تحذير',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
        content: Text(
          'يبدو أن بعض الأسعار صفرية. لم يتم تحميل أسعار البورصة بعد؟ '
          'اضغط على متوسط البورصة للحصول على الأسعار الحالية.',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.8),
            fontSize: 14.sp,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(
                color:
                    colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14.sp,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Get.back<void>();
              controller.calculateFeasibility();
              onAfterCalculate?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusSm),
              ),
            ),
            child: Text(
              'متابعة',
              style: TextStyle(
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
    controller.defaultWeightController.text = '2.1';
    controller.mortalityRateController.text = '5';
    controller.overheadController.text = '10';

    if (controller.isProfessionalMode.value) {
      controller.badiRatioController.text = '0.5';
      controller.namiRatioController.text = '1.2';
      controller.nahiRatioController.text = '1.8';
    } else {
      controller.averageFeedRatioController.text = '3.5';
    }
  }
}
