import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/class/handling_data.dart';
import '../../../../core/constant/theme/color.dart';
import '../../../../logic/controller/tools_controller/feasibility_study_controller.dart';
import 'feasibility_widgets.dart';

class ResultsSection extends StatelessWidget {
  const ResultsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeasibilityController>(
      builder: (controller) {
        if (controller.showResults.value) {
          return HandlingDataView(
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
                          AppColor.primaryColor,
                        ),
                      FeasibilityWidgets.buildResultCard(
                        context,
                        'النافق',
                        controller.mortalityRateText.value,
                        Icons.warning,
                        AppColor.primaryColor,
                      ),
                      FeasibilityWidgets.buildResultCard(
                        context,
                        'سعر الكتاكيت',
                        controller.chickenCostText.value,
                        Icons.shopping_cart,
                        AppColor.primaryColor,
                      ),
                      FeasibilityWidgets.buildResultCard(
                        context,
                        'تكلفة العلف',
                        controller.feedCostText.value,
                        Icons.grain,
                        AppColor.primaryColor,
                      ),
                      FeasibilityWidgets.buildResultCard(
                        context,
                        'النثريات',
                        controller.overheadCostText.value,
                        Icons.miscellaneous_services,
                        AppColor.primaryColor,
                      ),
                      FeasibilityWidgets.buildResultCard(
                        context,
                        'التكلفة الإجمالية',
                        controller.totalCostText.value,
                        Icons.calculate,
                        AppColor.primaryColor,
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
                        AppColor.primaryColor,
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
                        AppColor.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
