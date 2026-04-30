import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../core/shared/tools/tool_input_card.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/mortality_rate_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tools_button.dart';

class MortalityRateScreen extends StatelessWidget {
  MortalityRateScreen({super.key});
  final MortalityRateController controller = Get.put(MortalityRateController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onCalculatePressed() {
    if (_formKey.currentState?.validate() != true) return;
    controller.calculateMortalityRate();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: MortalityRateScreen, toolId: 20);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color resultColor = isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Scaffold(
      appBar: const CustomAppBar(text: 'نسبة النفوق', favoriteToolName: 'نسبة النفوق'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ToolInputCard(
                child: Form(
                  key: _formKey,
                  child: TwoInputFields(
                    firstLabel: 'عدد الفراخ الاولي',
                    secondLabel: 'عدد النافق',
                    secondAllowZero: true,
                    onFirstChanged: (value) => controller.initialCount.value = int.tryParse(value) ?? 0,
                    onSecondChanged: (value) => controller.deaths.value = int.tryParse(value) ?? 0,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              const AdNativeWidget(),
              SizedBox(height: 12.h),
              ToolsButton(text: 'احسب نسبة النفوق', onPressed: _onCalculatePressed),
              SizedBox(height: 14.h),
              Obx(() {
                final value = controller.mortalityRate.value;
                if (value <= 0) return const SizedBox.shrink();

                return ToolResultCard(
                  title: 'نسبة النفوق',
                  value: '${formatDecimal(value)}%',
                  resultColor: resultColor,
                );
              }),
              SizedBox(height: 16.h),
              const RelatedArticlesSection(relatedArticleIds: [2, 18]),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
