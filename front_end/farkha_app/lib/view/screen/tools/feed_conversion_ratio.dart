import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_helpers.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/tools/tool_input_card.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/feed_conversion_ratio_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tools_button.dart';

class FeedConversionRatio extends StatefulWidget {
  FeedConversionRatio({super.key});
  final FcrController controller = Get.put(FcrController());

  @override
  State<FeedConversionRatio> createState() => _FeedConversionRatioState();
}

class _FeedConversionRatioState extends State<FeedConversionRatio> {
  final _formKey = GlobalKey<FormState>();

  void _onCalculatePressed() {
    if (_formKey.currentState?.validate() != true) return;
    widget.controller.calculateFCR();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: FeedConversionRatio, toolId: 1);

    return Scaffold(
      appBar: const CustomAppBar(text: 'معامل التحويل الغذائي', favoriteToolName: 'معامل التحويل الغذائي'),
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
                    TwoInputFields(
                      formKey: _formKey,
                      firstLabel: 'العلف المستهلك',
                      secondLabel: 'الوزن الحالي',
                      firstController:
                          widget.controller.feedConsumedController,
                      secondController:
                          widget.controller.currentWeightController,
                      firstSuffix: 'كجم',
                      secondSuffix: 'كجم',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              const AdNativeWidget(),
              SizedBox(height: 12.h),
              ToolsButton(text: 'احسب الآن', onPressed: _onCalculatePressed),
              SizedBox(height: 14.h),
              Obx(() {
                final value = widget.controller.fcr.value;
                final quality = widget.controller.getFcrQuality();
                if (value <= 0) return const SizedBox.shrink();

                final resultColor = getQualityColor(quality);
                final label = getQualityLabel(quality);

                return ToolResultCard(
                  title: 'معامل التحويل (FCR)',
                  value: formatDecimal(value, decimals: 2),
                  resultColor: resultColor,
                  badgeLabel: label,
                );
              }),
              const NotesCard(
                notes: [
                  'معامل التحويل = العلف المستهلك ÷ الوزن المكتسب',
                  'معامل التحويل أقل من 1.6 يعتبر ممتاز',
                  'معامل التحويل من 1.6 إلى 1.8 يعتبر جيد',
                  'معامل التحويل أكثر من 1.9 يحتاج تحسين',
                  'يتم حساب معامل التحويل في نهاية دورة التربية',
                ],
              ),
              SizedBox(height: 12.h),
              _buildRangesCard(context),
              SizedBox(height: 14.h),
              const RelatedArticlesSection(relatedArticleIds: [19, 12]),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildRangesCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color:
            isDark
                ? AppColors.darkSurfaceElevatedColor
                : AppColors.lightSurfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color:
              isDark
                  ? AppColors.darkOutlineColor.withValues(alpha: 0.5)
                  : AppColors.lightOutlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.green, size: 18.sp),
              SizedBox(width: 6.w),
              Text(
                'النسب المرجعية',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildRangeRow(
            Icons.check_circle,
            Colors.green,
            '1.4 – 1.6',
            'ممتاز',
          ),
          SizedBox(height: 4.h),
          _buildRangeRow(Icons.check_circle, Colors.orange, '1.6 – 1.8', 'جيد'),
          SizedBox(height: 4.h),
          _buildRangeRow(
            Icons.warning_amber,
            Colors.amber,
            '1.8 – 1.9',
            'مقبول',
          ),
          SizedBox(height: 4.h),
          _buildRangeRow(Icons.error_outline, Colors.red, '> 1.9', 'ضعيف'),
        ],
      ),
    );
  }

  Widget _buildRangeRow(
    IconData icon,
    Color color,
    String range,
    String label,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: color),
        SizedBox(width: 8.w),
        Text(
          '$range ($label)',
          style: TextStyle(fontSize: 13.sp, color: colorScheme.onSurface),
        ),
      ],
    );
  }
}
