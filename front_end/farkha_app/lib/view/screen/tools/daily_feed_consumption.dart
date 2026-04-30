import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/chicken_age_count_input.dart';
import '../../../core/shared/tools/tool_input_card.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/daily_feed_consumption_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tools_button.dart';

class DailyFeedConsumption extends StatelessWidget {
  const DailyFeedConsumption({super.key});

  @override
  Widget build(BuildContext context) {
    final DailyFeedConsumptionController controller = Get.put(
      DailyFeedConsumptionController(),
    );

    logToolPageViewOnce(widgetType: DailyFeedConsumption, toolId: 4);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resultColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Scaffold(
      appBar: const CustomAppBar(text: 'استهلاك العلف اليومي', favoriteToolName: 'استهلاك العلف اليومي'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ToolInputCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChickenAgeCountInput(
                      controller: controller.textController,
                      selectedAge: controller.selectedAge.value,
                      onAgeChanged: (value) {
                        controller.selectedAge.value = value;
                      },
                      validateCount: false,
                      countSuffix: 'فرخ',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              const AdNativeWidget(),
              SizedBox(height: 12.h),
              ToolsButton(
                text: 'احسب الاستهلاك اليومي',
                onPressed: () => controller.calculateDailyFeedConsumption(),
              ),
              SizedBox(height: 14.h),
              Obx(() {
                final result = controller.result.value;
                if (result.isEmpty) return const SizedBox.shrink();

                return ToolResultCard(
                  title: 'استهلاك العلف اليومي',
                  value: result,
                  resultColor: resultColor,
                );
              }),
              SizedBox(height: 14.h),
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
