import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../logic/controller/tools_controller/feed_cost_per_kilo_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../../core/shared/input_fields/three_input_fields.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tools_button.dart';

class FeedCostPerKiloScreen extends StatelessWidget {
  FeedCostPerKiloScreen({super.key});
  final FeedCostPerKiloController controller = Get.put(
    FeedCostPerKiloController(),
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onCalculatePressed() {
    if (_formKey.currentState?.validate() != true) return;
    controller.calculateFeedCostPerKilo();
  }

  Widget _buildResultRow(
    BuildContext context, {
    required String title,
    required String value,
    required Color resultColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(
      widgetType: FeedCostPerKiloScreen,
      toolName: 'تكلفة العلف لكل كيلو وزن',
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resultColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Scaffold(
      appBar: const CustomAppBar(text: 'تكلفة العلف لكل كيلو وزن', favoriteToolName: 'تكلفة العلف لكل كيلو وزن'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceElevatedColor
                      : AppColors.lightSurfaceColor,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkOutlineColor.withValues(alpha: 0.5)
                        : AppColors.lightOutlineColor.withValues(alpha: 0.3),
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Form(
                  key: _formKey,
                  child: ThreeInputFields(
                    firstLabel: 'العلف المستهلك بالطن',
                    secondLabel: 'الوزن الكلي للقطيع بالطن',
                    thirdLabel: 'سعر طن العلف',
                    firstSuffix: 'طن',
                    secondSuffix: 'طن',
                    thirdSuffix: 'جنيه',
                    onFirstChanged: (value) {
                      controller.totalFeedConsumed.value =
                          double.tryParse(value) ?? 0.0;
                      controller.resetCalculation();
                    },
                    onSecondChanged: (value) {
                      controller.totalWeightSold.value =
                          double.tryParse(value) ?? 0.0;
                      controller.resetCalculation();
                    },
                    onThirdChanged: (value) {
                      controller.feedPricePerTon.value =
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
                text: 'احسب تكلفة العلف لكل كيلو',
                onPressed: _onCalculatePressed,
              ),
              SizedBox(height: 14.h),
              Obx(() {
                final hasCalculated = controller.hasCalculated.value;
                if (!hasCalculated) return const SizedBox.shrink();

                return Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        resultColor.withValues(alpha: isDark ? 0.22 : 0.1),
                        resultColor.withValues(alpha: isDark ? 0.12 : 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: resultColor.withValues(alpha: 0.45),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildResultRow(
                        context,
                        title: 'تكلفة العلف لكل كيلو وزن',
                        value:
                            '${formatDecimal(controller.feedCostPerKilo.value)} جنيه',
                        resultColor: resultColor,
                      ),
                      Divider(
                        color: resultColor.withValues(alpha: 0.3),
                        height: 1,
                        thickness: 1,
                      ),
                      _buildResultRow(
                        context,
                        title: 'إجمالي تكلفة العلف',
                        value:
                            '${formatDecimal(controller.totalFeedConsumed.value * controller.feedPricePerTon.value, decimals: 0)} جنيه',
                        resultColor: resultColor,
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 16.h),
              const RelatedArticlesSection(
                relatedArticleIds: [12],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
