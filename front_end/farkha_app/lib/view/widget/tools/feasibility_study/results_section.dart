import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/class/handling_data.dart';
import '../../../../core/constant/theme/theme.dart';
import '../../../../logic/controller/tools_controller/feasibility_study_controller.dart';
import 'feasibility_widgets.dart';

class ResultsSection extends StatelessWidget {
  const ResultsSection({super.key, this.resultsKey});

  final GlobalKey? resultsKey;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FeasibilityController>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (!controller.showResults.value) {
        return const SizedBox.shrink();
      }

      return Column(
        key: resultsKey,
        children: [
          if (!controller.showInputs.value)
            _buildActionBar(context, controller, colorScheme, isDark),
          HandlingDataView(
            statusRequest: controller.statusRequest,
            widget: Column(
              children: [
                FeasibilityWidgets.buildModernSection(
                  context,
                  'التكاليف',
                  Icons.account_balance_wallet_outlined,
                  AppColors.accentColor,
                  [
                    if (!controller.isChickenCountMode.value)
                      FeasibilityWidgets.buildResultCard(
                        context,
                        title: 'عدد الفراخ',
                        value: controller.chickenCountText.value,
                        icon: Icons.pets,
                        color: colorScheme.primary,
                      ),
                    FeasibilityWidgets.buildResultCard(
                      context,
                      title: 'النافق',
                      value: controller.mortalityRateText.value,
                      icon: Icons.warning_amber_rounded,
                      color: colorScheme.primary,
                      helpText:
                          'يُحسب عدد النافق من نسبة النافق المدخلة × عدد الفراخ.\n\n'
                          'التكلفة المعروضة تشمل:\n'
                          '• سعر الكتاكيت النافقة\n'
                          '• 50% من تكلفة العلف (لأن الفرخ استهلك جزءاً قبل النفوق)\n'
                          '• النثريات الخاصة بهم',
                    ),
                    FeasibilityWidgets.buildResultCard(
                      context,
                      title: 'سعر الكتاكيت',
                      value: controller.chickenCostText.value,
                      icon: Icons.shopping_cart_outlined,
                      color: colorScheme.primary,
                    ),
                    FeasibilityWidgets.buildResultCard(
                      context,
                      title: 'تكلفة العلف',
                      value: controller.feedCostText.value,
                      icon: Icons.grain,
                      color: colorScheme.primary,
                    ),
                    FeasibilityWidgets.buildResultCard(
                      context,
                      title: 'النثريات',
                      value: controller.overheadCostText.value,
                      icon: Icons.miscellaneous_services_outlined,
                      color: colorScheme.primary,
                      helpText:
                          'مصاريف إضافية تشمل الأدوية، الكهرباء، العمالة، والتشغيل لكل فرخ.',
                    ),
                    FeasibilityWidgets.buildResultCard(
                      context,
                      title: 'تكلفة الفرخ الواحد',
                      value: controller.costPerChickenText.value,
                      icon: Icons.pest_control_outlined,
                      color: colorScheme.primary,
                    ),
                    FeasibilityWidgets.buildResultCard(
                      context,
                      title: 'تكلفة الكيلو',
                      value: controller.costPerKgText.value,
                      icon: Icons.scale_outlined,
                      color: colorScheme.primary,
                    ),
                    FeasibilityWidgets.buildResultCard(
                      context,
                      title: 'التكلفة الإجمالية',
                      value: controller.totalCostText.value,
                      icon: Icons.calculate_outlined,
                      color: colorScheme.primary,
                    ),
                    FeasibilityWidgets.buildResultCard(
                      context,
                      title: 'الكيلوجرامات المنتجة',
                      value: controller.totalKgProducedText.value,
                      icon: Icons.scale_outlined,
                      color: colorScheme.primary,
                    ),
                    FeasibilityWidgets.buildCostDistributionBar(
                      context: context,
                      chickenCost: controller.totalChickenCostRaw.value,
                      feedCost: controller.totalFeedCostRaw.value,
                      overheadCost: controller.totalOverheadCostRaw.value,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildActionBar(
    BuildContext context,
    FeasibilityController controller,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Expanded(
            child: _buildActionChip(
              context: context,
              icon: Icons.edit_outlined,
              label: 'تعديل مدخلات',
              onTap: () => controller.toggleInputsVisibility(),
              colorScheme: colorScheme,
              isDark: isDark,
              isPrimary: true,
            ),
          ),
          SizedBox(width: 10.w),
          _buildActionChip(
            context: context,
            icon: Icons.ios_share,
            label: 'مشاركة',
            onTap: () => _showShareSheet(context, controller),
            colorScheme: colorScheme,
            isDark: isDark,
            isPrimary: false,
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required bool isDark,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: isPrimary
                ? colorScheme.primary
                : colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: isPrimary
                ? null
                : Border.all(
                    color: colorScheme.primary.withValues(
                      alpha: isDark ? 0.4 : 0.3,
                    ),
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isPrimary
                    ? colorScheme.onPrimary
                    : colorScheme.primary,
                size: 17.sp,
              ),
              SizedBox(width: 7.w),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary
                      ? colorScheme.onPrimary
                      : colorScheme.primary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context, FeasibilityController controller) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'مشاركة دراسة الجدوى',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'اختر صيغة التصدير',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 20.h),
              _buildShareOption(
                sheetContext: sheetContext,
                context: context,
                icon: Icons.text_snippet_outlined,
                label: 'بيانات نصية',
                description: 'مشاركة كنص عادي',
                color: colorScheme.primary,
                isDark: isDark,
                colorScheme: colorScheme,
                onTap: () {
                  Navigator.pop(sheetContext);
                  controller.shareAsText();
                },
              ),
              SizedBox(height: 10.h),
              _buildShareOption(
                sheetContext: sheetContext,
                context: context,
                icon: Icons.picture_as_pdf_outlined,
                label: 'PDF',
                description: 'تقرير منسق كملف PDF',
                color: AppColors.accentColor,
                isDark: isDark,
                colorScheme: colorScheme,
                onTap: () {
                  Navigator.pop(sheetContext);
                  controller.shareAsPdf();
                },
              ),
              SizedBox(height: 10.h),
              _buildShareOption(
                sheetContext: sheetContext,
                context: context,
                icon: Icons.table_chart_outlined,
                label: 'Excel',
                description: 'جدول بيانات Excel',
                color: AppColors.primaryColor,
                isDark: isDark,
                colorScheme: colorScheme,
                onTap: () {
                  Navigator.pop(sheetContext);
                  controller.shareAsExcel();
                },
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required BuildContext sheetContext,
    required BuildContext context,
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required bool isDark,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.1 : 0.06),
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.3 : 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: color, size: 22.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_back_ios_new,
                size: 16.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
