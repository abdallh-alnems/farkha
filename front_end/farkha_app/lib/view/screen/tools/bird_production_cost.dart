import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../logic/controller/tools_controller/bird_production_cost_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tools_button.dart';

class BirdProductionCostScreen extends StatelessWidget {
  BirdProductionCostScreen({super.key});
  final BirdProductionCostController controller = Get.put(
    BirdProductionCostController(),
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onCalculatePressed() {
    if (_formKey.currentState?.validate() != true) return;
    controller.calculateCostPerBird();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(
      widgetType: BirdProductionCostScreen,
      toolName: 'تكلفة إنتاج الفرخ',
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final resultColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Scaffold(
      appBar: const CustomAppBar(text: 'تكلفة انتاج الفرخ', favoriteToolName: 'تكلفة انتاج الفرخ'),
      body: SafeArea(
        child: Column(
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
                        child: TwoInputFields(
                          firstLabel: 'إجمالي التكاليف',
                          secondLabel: 'عدد الفراخ',
                          firstSuffix: 'جنيه',
                          secondSuffix: 'فرخ',
                          onFirstChanged: (value) =>
                              controller.totalCosts.value =
                                  double.tryParse(value) ?? 0.0,
                          onSecondChanged: (value) =>
                              controller.liveBirds.value =
                                  int.tryParse(value) ?? 0,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    const AdNativeWidget(),
                    SizedBox(height: 12.h),
                    ToolsButton(
                      text: 'احسب تكلفة إنتاج الفرخ',
                      onPressed: _onCalculatePressed,
                    ),
                    SizedBox(height: 14.h),
                    Obx(() {
                      final value = controller.costPerBird.value;
                      if (value <= 0) return const SizedBox.shrink();

                      return Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        padding: EdgeInsets.all(18.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              resultColor.withValues(
                                alpha: isDark ? 0.22 : 0.1,
                              ),
                              resultColor.withValues(
                                alpha: isDark ? 0.12 : 0.05,
                              ),
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
                              'تكلفة إنتاج الفرخ',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface.withValues(alpha: 0.85),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              '${formatDecimal(value)} جنيه',
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold,
                                color: resultColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const RelatedArticlesSection(
                      relatedArticleIds: [12, 20],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
