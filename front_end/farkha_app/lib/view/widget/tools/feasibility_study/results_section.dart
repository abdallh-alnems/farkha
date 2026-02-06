import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/class/handling_data.dart';
import '../../../../core/constant/theme/colors.dart';
import '../../../../logic/controller/tools_controller/feasibility_study_controller.dart';
import 'feasibility_widgets.dart';

class ResultsSection extends StatelessWidget {
  const ResultsSection({super.key, this.resultsKey});

  final GlobalKey? resultsKey;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FeasibilityController>();
    return Obx(() {
      if (controller.showResults.value) {
        return Column(
          key: resultsKey,
          children: [
            // رابط تعديل المدخلات فوق النتائج
            if (!controller.showInputs.value)
              Builder(
                builder: (context) {
                  final colorScheme = Theme.of(context).colorScheme;
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.toggleInputsVisibility(),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? colorScheme.primary.withValues(
                                          alpha: 0.15,
                                        )
                                        : AppColors.primaryColor.withValues(
                                          alpha: 0.1,
                                        ),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color:
                                      isDark
                                          ? colorScheme.primary.withValues(
                                            alpha: 0.4,
                                          )
                                          : AppColors.primaryColor.withValues(
                                            alpha: 0.3,
                                          ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color:
                                        isDark
                                            ? colorScheme.primary
                                            : AppColors.primaryColor,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'تعديل مدخلات',
                                    style: TextStyle(
                                      color:
                                          isDark
                                              ? colorScheme.primary
                                              : AppColors.primaryColor,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _shareResults(controller),
                            borderRadius: BorderRadius.circular(8.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? colorScheme.primary.withValues(
                                          alpha: 0.15,
                                        )
                                        : AppColors.primaryColor.withValues(
                                          alpha: 0.1,
                                        ),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color:
                                      isDark
                                          ? colorScheme.primary.withValues(
                                            alpha: 0.4,
                                          )
                                          : AppColors.primaryColor.withValues(
                                            alpha: 0.3,
                                          ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.share,
                                    color:
                                        isDark
                                            ? colorScheme.primary
                                            : AppColors.primaryColor,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'مشاركة',
                                    style: TextStyle(
                                      color:
                                          isDark
                                              ? colorScheme.primary
                                              : AppColors.primaryColor,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            HandlingDataView(
              statusRequest: controller.statusRequest,
              widget: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  children: [
                    // Costs Section
                    FeasibilityWidgets.buildModernSection(
                      context,
                      'التكاليف',
                      Icons.account_balance_wallet,
                      Colors.orange[600]!,
                      [
                        // إظهار عدد الفراخ فقط في وضع دراسة بالميزانية
                        if (!controller.isChickenCountMode.value)
                          FeasibilityWidgets.buildResultCard(
                            context,
                            title: 'عدد الفراخ',
                            value: controller.chickenCountText.value,
                            icon: Icons.pets,
                            color: AppColors.primaryColor,
                          ),
                        FeasibilityWidgets.buildResultCard(
                          context,
                          title: 'النافق',
                          value: controller.mortalityRateText.value,
                          icon: Icons.warning,
                          color: AppColors.primaryColor,
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
                          icon: Icons.shopping_cart,
                          color: AppColors.primaryColor,
                        ),
                        FeasibilityWidgets.buildResultCard(
                          context,
                          title: 'تكلفة العلف',
                          value: controller.feedCostText.value,
                          icon: Icons.grain,
                          color: AppColors.primaryColor,
                        ),
                        FeasibilityWidgets.buildResultCard(
                          context,
                          title: 'النثريات',
                          value: controller.overheadCostText.value,
                          icon: Icons.miscellaneous_services,
                          color: AppColors.primaryColor,
                          helpText:
                              'مصاريف إضافية تشمل الأدوية، الكهرباء، العمالة، والتشغيل لكل فرخ.',
                        ),
                        FeasibilityWidgets.buildResultCard(
                          context,
                          title: 'تكلفة الفرخ الواحد',
                          value: controller.costPerChickenText.value,
                          icon: Icons.pest_control,
                          color: AppColors.primaryColor,
                        ),
                        FeasibilityWidgets.buildResultCard(
                          context,
                          title: 'تكلفة الكيلو',
                          value: controller.costPerKgText.value,
                          icon: Icons.scale,
                          color: AppColors.primaryColor,
                        ),
                        FeasibilityWidgets.buildResultCard(
                          context,
                          title: 'التكلفة الإجمالية',
                          value: controller.totalCostText.value,
                          icon: Icons.calculate,
                          color: AppColors.primaryColor,
                        ),
                        FeasibilityWidgets.buildCostDistributionBar(
                          context: context,
                          chickenCost: controller.totalChickenCostRaw.value,
                          feedCost: controller.totalFeedCostRaw.value,
                          overheadCost: controller.totalOverheadCostRaw.value,
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Sales Section
                    FeasibilityWidgets.buildModernSection(
                      context,
                      'المبيعات',
                      Icons.trending_up,
                      Colors.green[600]!,
                      [
                        FeasibilityWidgets.buildResultCard(
                          context,
                          title: 'الكيلوجرامات المنتجة',
                          value: controller.totalKgProducedText.value,
                          icon: Icons.scale,
                          color: AppColors.primaryColor,
                        ),
                        FeasibilityWidgets.buildResultCard(
                          context,
                          title: 'إجمالي المبيعات',
                          value: controller.totalSalesText.value,
                          icon: Icons.attach_money,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Profits Section
                    FeasibilityWidgets.buildModernSection(
                      context,
                      'الأرباح',
                      Icons.monetization_on,
                      Colors.amber[600]!,
                      [
                        FeasibilityWidgets.buildResultCard(
                          context,
                          title: 'صافي الأرباح',
                          value:
                              controller.profitMarginText.value.isNotEmpty &&
                                      controller.profitMarginText.value != '-'
                                  ? '${controller.profitText.value} (${controller.profitMarginText.value})'
                                  : controller.profitText.value,
                          icon: Icons.emoji_events,
                          color: AppColors.primaryColor,
                          valueColor:
                              controller.isProfitNegative.value
                                  ? Colors.red
                                  : null,
                          subtitle:
                              controller.isProfitNegative.value
                                  ? 'المشروع غير مجدٍ بالأسعار الحالية'
                                  : null,
                        ),
                        FeasibilityWidgets.buildResultCard(
                          context,
                          title: 'الربح لكل فرخ',
                          value: controller.profitPerChickenText.value,
                          icon: Icons.trending_up,
                          color: AppColors.primaryColor,
                          valueColor:
                              controller.isProfitNegative.value
                                  ? Colors.red
                                  : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  void _shareResults(FeasibilityController controller) {
    final text = controller.buildShareText();
    SharePlus.instance.share(
      ShareParams(text: text, subject: 'دراسة جدوى - تطبيق فَرْخة'),
    );
  }
}
