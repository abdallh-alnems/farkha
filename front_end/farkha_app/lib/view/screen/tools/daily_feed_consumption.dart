import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../core/functions/tool_helpers.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/chicken_age_count_input.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/daily_feed_consumption_controller.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tool_page_scaffold.dart';

class DailyFeedConsumption extends StatelessWidget {
  const DailyFeedConsumption({super.key});

  @override
  Widget build(BuildContext context) {
    final DailyFeedConsumptionController controller =
        Get.put(DailyFeedConsumptionController());

    logToolPageViewOnce(widgetType: DailyFeedConsumption, toolId: 4);

    return ToolPageScaffold(
      title: 'استهلاك العلف اليومي',
      inputChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FeedHeaderIllustration(),
          SizedBox(height: 16.h),
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
      buttonText: 'احسب الاستهلاك اليومي',
      onButtonPressed: () => controller.calculateDailyFeedConsumption(),
      footerSections: [
        Obx(() {
          final result = controller.result.value;
          if (result.isEmpty) return const SizedBox.shrink();

          return Column(
            children: [
              ToolResultCard(
                title: 'استهلاك العلف اليومي',
                value: result,
                resultColor: getToolResultColor(context),
              ),
              SizedBox(height: 12.h),
              _FeedInsightChip(
                age: controller.selectedAge.value,
                birdCount: _parseBirdCount(controller.textController.text),
              ),
            ],
          );
        }),
        SizedBox(height: 14.h),
        const RelatedArticlesSection(relatedArticleIds: [12]),
      ],
    );
  }

  int? _parseBirdCount(String text) {
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }
}

class _FeedHeaderIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primaryColor.withValues(alpha: isDark ? 0.18 : 0.08),
            AppColors.accentColor.withValues(alpha: isDark ? 0.12 : 0.05),
          ],
        ),
        borderRadius: AppDimens.borderMd,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: AppDimens.borderMd,
            ),
            child: Icon(
              Icons.grain_outlined,
              size: 22.sp,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حاسبة الاستهلاك اليومي',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'احسب كمية العلف المطلوبة يوميًا حسب عمر وعدد الطيور',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedInsightChip extends StatelessWidget {
  final int? age;
  final int? birdCount;

  const _FeedInsightChip({this.age, this.birdCount});

  @override
  Widget build(BuildContext context) {
    if (age == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String insightText;
    if (age! <= 7) {
      insightText = 'مرحلة البداية — استهلاك فرخ واحد منخفض';
    } else if (age! <= 21) {
      insightText = 'مرحلة النمو — الاستهلاك يزداد بسرعة';
    } else if (age! <= 35) {
      insightText = 'مرحلة التسمين — استهلاك علف مرتفع';
    } else {
      insightText = 'مرحلة النضج — الاستهلاك شبه ثابت';
    }

    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 14.w,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: AppDimens.borderSm,
        border: Border.all(
          color: AppColors.secondaryColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 18.sp,
            color: AppColors.secondaryColor,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              insightText,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.75),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
