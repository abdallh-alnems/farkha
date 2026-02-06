import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/chicken_age_count_input.dart';
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

    logToolPageViewOnce(
      widgetType: DailyFeedConsumption,
      toolName: 'استهلاك العلف اليومي',
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
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
                      Text(
                        'استهلاك العلف اليومي',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.85),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        result,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                    ],
                  ),
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
