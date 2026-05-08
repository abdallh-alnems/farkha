import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_helpers.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/mortality_rate_controller.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tool_page_scaffold.dart';

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

    return ToolPageScaffold(
      title: 'نسبة النفوق',
      inputChild: Form(
        key: _formKey,
        child: TwoInputFields(
          firstLabel: 'عدد الفراخ الاولي',
          secondLabel: 'عدد النافق',
          secondAllowZero: true,
          onFirstChanged: (value) => controller.initialCount.value = int.tryParse(value) ?? 0,
          onSecondChanged: (value) => controller.deaths.value = int.tryParse(value) ?? 0,
        ),
      ),
      buttonText: 'احسب نسبة النفوق',
      onButtonPressed: _onCalculatePressed,
      footerSections: [
        Obx(() {
          final value = controller.mortalityRate.value;
          if (value <= 0) return const SizedBox.shrink();

          return ToolResultCard(
            title: 'نسبة النفوق',
            value: '${formatDecimal(value)}%',
            resultColor: getToolResultColor(context),
          );
        }),
        SizedBox(height: 16.h),
        const RelatedArticlesSection(relatedArticleIds: [2, 18]),
      ],
    );
  }
}
