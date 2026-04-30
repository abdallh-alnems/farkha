import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../core/shared/tools/tool_input_card.dart';
import '../../../core/shared/tools/tool_result_card.dart';
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
    logToolPageViewOnce(widgetType: BirdProductionCostScreen, toolId: 15);

    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    ToolInputCard(
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

                      return ToolResultCard(
                        title: 'تكلفة إنتاج الفرخ',
                        value: '${formatDecimal(value)} جنيه',
                        resultColor: resultColor,
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
