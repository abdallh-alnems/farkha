import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/chicken_age_count_input.dart';
import '../../../core/shared/tools/tool_input_card.dart';
import '../../../logic/controller/tools_controller/water_consumption_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tools_button.dart';

class WaterConsumption extends StatelessWidget {
  const WaterConsumption({super.key});

  @override
  Widget build(BuildContext context) {
    final WaterConsumptionController controller = Get.put(
      WaterConsumptionController(),
    );

    logToolPageViewOnce(widgetType: WaterConsumption, toolId: 23);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final resultColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Scaffold(
      appBar: const CustomAppBar(
        text: 'استهلاك الماء',
        favoriteToolName: 'استهلاك الماء',
      ),
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
                text: 'احسب استهلاك الماء',
                onPressed: () => controller.calculateWaterConsumption(),
              ),
              SizedBox(height: 14.h),
              Obx(() {
                final daily = controller.resultDaily.value;
                final weekly = controller.resultWeekly.value;
                final toEnd = controller.resultToEndOfCycle.value;
                if (daily.isEmpty) return const SizedBox.shrink();

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'استهلاك الماء',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.85),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _ResultRow(
                        label: 'اليومي',
                        value: daily,
                        resultColor: resultColor,
                        fontSize: 18.sp,
                      ),
                      SizedBox(height: 6.h),
                      _ResultRow(
                        label: 'الأسبوعي',
                        value: weekly,
                        resultColor: resultColor,
                        fontSize: 18.sp,
                      ),
                      SizedBox(height: 6.h),
                      _ResultRow(
                        label: 'حتى نهاية الدورة',
                        value: toEnd,
                        resultColor: resultColor,
                        fontSize: 18.sp,
                        smallSuffix: '(٣٥ يوم)',
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 14.h),
              const RelatedArticlesSection(relatedArticleIds: []),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    required this.resultColor,
    required this.fontSize,
    this.smallSuffix,
  });

  final String label;
  final String value;
  final Color resultColor;
  final double fontSize;
  final String? smallSuffix;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: resultColor,
              ),
            ),
            if (smallSuffix != null) ...[
              Text(
                ' $smallSuffix',
                style: TextStyle(
                  fontSize: fontSize * 0.78,
                  fontWeight: FontWeight.w500,
                  color: resultColor.withValues(alpha: 0.85),
                ),
              ),
            ],
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: resultColor,
          ),
        ),
      ],
    );
  }
}
