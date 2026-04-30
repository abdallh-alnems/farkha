import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/three_input_fields.dart';
import '../../../core/shared/tools/tool_input_card.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/feed_cost_per_bird_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tools_button.dart';

class FeedCostPerBirdScreen extends StatelessWidget {
  FeedCostPerBirdScreen({super.key});
  final FeedCostPerBirdController controller = Get.put(
    FeedCostPerBirdController(),
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onCalculatePressed() {
    if (_formKey.currentState?.validate() != true) return;
    controller.calculateFeedCostPerBird();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: FeedCostPerBirdScreen, toolId: 16);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color resultColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Scaffold(
      appBar: const CustomAppBar(text: 'تكلفة العلف لكل طائر', favoriteToolName: 'تكلفة العلف لكل طائر'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ToolInputCard(
                child: Form(
                  key: _formKey,
                  child: ThreeInputFields(
                    firstLabel: 'كمية العلف (بالطن)',
                    secondLabel: 'سعر طن العلف',
                    thirdLabel: 'عدد الطيور',
                    firstSuffix: 'طن',
                    secondSuffix: 'جنيه',
                    onFirstChanged: (value) {
                      controller.totalFeedQuantity.value =
                          double.tryParse(value) ?? 0.0;
                      controller.resetCalculation();
                    },
                    onSecondChanged: (value) {
                      controller.feedPricePerTon.value =
                          double.tryParse(value) ?? 0.0;
                      controller.resetCalculation();
                    },
                    onThirdChanged: (value) {
                      controller.numberOfBirds.value =
                          int.tryParse(value) ?? 0;
                      controller.resetCalculation();
                    },
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              const AdNativeWidget(),
              SizedBox(height: 12.h),
              ToolsButton(
                text: 'احسب تكلفة العلف لكل طائر',
                onPressed: _onCalculatePressed,
              ),
              SizedBox(height: 14.h),
              Obx(() {
                final hasCalculated = controller.hasCalculated.value;
                if (!hasCalculated) return const SizedBox.shrink();

                return ToolResultCard(
                  title: 'تكلفة العلف لكل طائر',
                  value: '${controller.getFormattedResult()} جنيه',
                  resultColor: resultColor,
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
