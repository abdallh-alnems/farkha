import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../core/shared/tools/tool_input_card.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/return_on_investment_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tools_button.dart';

class ReturnOnInvestment extends StatelessWidget {
  ReturnOnInvestment({super.key});
  final ReturnOnInvestmentController controller = Get.put(
    ReturnOnInvestmentController(),
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onCalculatePressed() {
    if (_formKey.currentState?.validate() != true) return;
    final investment = controller.investmentCost.value;
    final totalSale = controller.totalSale.value;
    final actualProfit = totalSale - investment;
    controller.netProfit.value = actualProfit;
    controller.calculateROI();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: ReturnOnInvestment, toolId: 19);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resultColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Scaffold(
      appBar: const CustomAppBar(text: 'العائد على الاستثمار', favoriteToolName: 'العائد على الاستثمار'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ToolInputCard(
                child: Form(
                  key: _formKey,
                  child: TwoInputFields(
                    firstLabel: 'إجمالي مبلغ البيع',
                    secondLabel: 'تكلفة الدورة',
                    firstSuffix: 'جنيه',
                    secondSuffix: 'جنيه',
                    onFirstChanged: (value) {
                      controller.totalSale.value =
                          double.tryParse(value) ?? 0.0;
                      controller.resetCalculation();
                    },
                    onSecondChanged: (value) {
                      controller.investmentCost.value =
                          double.tryParse(value) ?? 0.0;
                      controller.resetCalculation();
                    },
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              const AdNativeWidget(),
              SizedBox(height: 12.h),
              ToolsButton(
                text: 'احسب العائد على الاستثمار',
                onPressed: _onCalculatePressed,
              ),
              SizedBox(height: 14.h),
              Obx(() {
                final value = controller.roi.value;
                final actualProfit = controller.netProfit.value;
                final hasCalculated = controller.hasCalculated.value;
                if (!hasCalculated) return const SizedBox.shrink();

                return ToolResultCard(
                  title: 'العائد على الاستثمار',
                  value: '${actualProfit.toInt()} جنيه (%${formatDecimal(value)})',
                  resultColor: resultColor,
                );
              }),
              SizedBox(height: 16.h),
              const RelatedArticlesSection(
                relatedArticleIds: [20],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
