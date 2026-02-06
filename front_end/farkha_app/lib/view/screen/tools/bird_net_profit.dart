import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/three_input_fields.dart';
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
    logToolPageViewOnce(
      widgetType: BirdNetProfitScreen,
      toolName: 'الربح الصافي للطائر',
    );

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
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
                Container(
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
                        'الربح الصافي للطائر',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.85),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '${formatDecimal(lastValidResult!)} جنيه',
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                    ],
                  ),
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
