import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/input_field.dart';
import '../../../logic/controller/tools_controller/total_feed_consumption_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tools_button.dart';

class TotalFeedConsumption extends StatefulWidget {
  const TotalFeedConsumption({super.key});

  @override
  State<TotalFeedConsumption> createState() => _TotalFeedConsumptionState();
}

class _TotalFeedConsumptionState extends State<TotalFeedConsumption> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onCalculatePressed() {
    if (_formKey.currentState?.validate() != true) return;
    Get.find<TotalFeedConsumptionController>().calculateTotalFeedConsumption();
  }

  @override
  Widget build(BuildContext context) {
    final TotalFeedConsumptionController controller = Get.put(
      TotalFeedConsumptionController(),
    );

    logToolPageViewOnce(
      widgetType: TotalFeedConsumption,
      toolName: 'استهلاك العلف الكلي',
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final resultColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Scaffold(
      appBar: const CustomAppBar(text: 'استهلاك العلف الكلي', favoriteToolName: 'استهلاك العلف الكلي'),
      body: Column(
        children: [
          Expanded(
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
                      child: InputField(
                        label: 'عدد الفراخ',
                        controller: controller.textController,
                        suffixText: 'فرخ',
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  const AdNativeWidget(),
                  SizedBox(height: 12.h),
                  ToolsButton(
                    text: 'احسب الاستهلاك الكلي',
                    onPressed: _onCalculatePressed,
                  ),
                  SizedBox(height: 14.h),
                  Obx(() {
                    final total = controller.totalResult.value;
                    if (total <= 0) return const SizedBox.shrink();

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
                            'استهلاك ${controller.chickenCount.value} فرخ للعلف طوال الدورة',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface.withValues(alpha: 0.85),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _ResultRow(
                            label: 'العلف البادي',
                            value: controller.badiResult.value,
                            colorScheme: colorScheme,
                            resultColor: resultColor,
                          ),
                          SizedBox(height: 8.h),
                          _ResultRow(
                            label: 'العلف النامي',
                            value: controller.namiResult.value,
                            colorScheme: colorScheme,
                            resultColor: resultColor,
                          ),
                          SizedBox(height: 8.h),
                          _ResultRow(
                            label: 'العلف الناهي',
                            value: controller.nahiResult.value,
                            colorScheme: colorScheme,
                            resultColor: resultColor,
                          ),
                          SizedBox(height: 12.h),
                          Divider(
                            color: resultColor.withValues(alpha: 0.4),
                            thickness: 1.2,
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'الاستهلاك الكلي',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '${formatDecimal(controller.totalResult.value, decimals: 0)} كيلو',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: resultColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  const NotesCard(
                    notes: [
                      'بادي: 0.5 كجم لكل فرخ',
                      'نامي: 1.2 كجم لكل فرخ',
                      'ناهي: 1.8 كجم لكل فرخ',
                      'الإجمالي: 3.5 كجم لكل فرخ في الدورة الكاملة',
                    ],
                  ),
                  const RelatedArticlesSection(
                    relatedArticleIds: [12],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    required this.colorScheme,
    required this.resultColor,
  });

  final String label;
  final double value;
  final ColorScheme colorScheme;
  final Color resultColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.85),
          ),
        ),
        Text(
          '${formatDecimal(value, decimals: 0)} كيلو',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: resultColor,
          ),
        ),
      ],
    );
  }
}
