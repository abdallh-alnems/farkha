import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/three_input_fields.dart';
import '../../../core/shared/tools/tool_input_card.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/bird_net_profit_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tools_button.dart';

class BirdNetProfitScreen extends StatefulWidget {
  const BirdNetProfitScreen({super.key});

  @override
  State<BirdNetProfitScreen> createState() => _BirdNetProfitScreenState();
}

class _BirdNetProfitScreenState extends State<BirdNetProfitScreen> {
  final BirdNetProfitController controller = Get.put(BirdNetProfitController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool showResult = false;
  double? lastValidResult;

  void _onCalculatePressed() {
    if (_formKey.currentState?.validate() != true) return;
    controller.calculateNetProfit();
    setState(() {
      showResult = true;
      lastValidResult = controller.netProfit.value;
    });
  }

  void _resetResult() {
    setState(() {
      showResult = false;
      lastValidResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: BirdNetProfitScreen, toolId: 18);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color resultColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Scaffold(
      appBar: const CustomAppBar(text: 'الربح الصافي للطائر', favoriteToolName: 'الربح الصافي للطائر'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ToolInputCard(
                child: Form(
                  key: _formKey,
                  child: ThreeInputFields(
                    firstLabel: 'إجمالي مبلغ البيع',
                    secondLabel: 'إجمالي التكاليف',
                    thirdLabel: 'عدد الطيور المباعة',
                    firstSuffix: 'جنيه',
                    secondSuffix: 'جنيه',
                    onFirstChanged: (value) {
                      controller.totalSale.value =
                          double.tryParse(value) ?? 0.0;
                      _resetResult();
                    },
                    onSecondChanged: (value) {
                      controller.totalCost.value =
                          double.tryParse(value) ?? 0.0;
                      _resetResult();
                    },
                    onThirdChanged: (value) {
                      controller.soldBirds.value = int.tryParse(value) ?? 0;
                      _resetResult();
                    },
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              const AdNativeWidget(),
              SizedBox(height: 12.h),
              ToolsButton(
                text: 'احسب الربح الصافي للطائر',
                onPressed: _onCalculatePressed,
              ),
              SizedBox(height: 14.h),
              if (showResult && lastValidResult != null)
                ToolResultCard(
                  title: 'الربح الصافي للطائر',
                  value: '${formatDecimal(lastValidResult!)} جنيه',
                  resultColor: resultColor,
                ),
              SizedBox(height: 16.h),
              const RelatedArticlesSection(
                relatedArticleIds: [20],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
