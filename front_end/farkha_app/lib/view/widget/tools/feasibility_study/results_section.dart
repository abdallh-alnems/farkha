import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/class/handling_data.dart';
import '../../../../core/constant/theme/colors.dart';
import '../../../../logic/controller/tools_controller/feasibility_study_controller.dart';
import 'feasibility_widgets.dart';

class ResultsSection extends StatelessWidget {
  const ResultsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FeasibilityController>();
    return Obx(() {
      if (controller.showResults.value) {
        return Column(
          children: [
            // رابط تعديل المدخلات فوق النتائج
            if (!controller.showInputs.value)
              Builder(
                builder: (context) {
                  final colorScheme = Theme.of(context).colorScheme;
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: GestureDetector(
                      onTap: () => controller.toggleInputsVisibility(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? colorScheme.primary.withOpacity(0.15)
                              : AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isDark
                                ? colorScheme.primary.withOpacity(0.4)
                                : AppColors.primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit,
                              color: isDark
                                  ? colorScheme.primary
                                  : AppColors.primaryColor,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'تعديل مدخلات دراسة الجدوي',
                              style: TextStyle(
                                color: isDark
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
                            'عدد الفراخ',
                            controller.chickenCountText.value,
                            Icons.pets,
                            AppColors.primaryColor,
                          ),
                        FeasibilityWidgets.buildResultCard(
                          context,
                          'النافق',
                          controller.mortalityRateText.value,
                          Icons.warning,
                          AppColors.primaryColor,
                        ),
                        FeasibilityWidgets.buildResultCard(
                          context,
                          'سعر الكتاكيت',
                          controller.chickenCostText.value,
                          Icons.shopping_cart,
                          AppColors.primaryColor,
                        ),
                        FeasibilityWidgets.buildResultCard(
                          context,
                          'تكلفة العلف',
                          controller.feedCostText.value,
                          Icons.grain,
                          AppColors.primaryColor,
                        ),
                        FeasibilityWidgets.buildResultCard(
                          context,
                          'النثريات',
                          controller.overheadCostText.value,
                          Icons.miscellaneous_services,
                          AppColors.primaryColor,
                        ),
                        FeasibilityWidgets.buildResultCard(
                          context,
                          'التكلفة الإجمالية',
                          controller.totalCostText.value,
                          Icons.calculate,
                          AppColors.primaryColor,
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
                          'إجمالي المبيعات',
                          controller.totalSalesText.value,
                          Icons.attach_money,
                          AppColors.primaryColor,
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
                          'صافي الأرباح',
                          controller.profitText.value,
                          Icons.emoji_events,
                          AppColors.primaryColor,
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
}
