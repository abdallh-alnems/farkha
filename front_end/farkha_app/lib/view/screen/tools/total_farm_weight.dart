import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/tools/tool_input_card.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/total_farm_weight_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tools_button.dart';

class TotalFarmWeightScreen extends StatelessWidget {
  TotalFarmWeightScreen({super.key});
  final TotalFarmWeightController controller = Get.put(
    TotalFarmWeightController(),
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: TotalFarmWeightScreen, toolId: 21);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resultColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Scaffold(
      appBar: const CustomAppBar(text: 'الوزن الاجمالي', favoriteToolName: 'الوزن الاجمالي'),
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
                    firstLabel: 'عدد الطيور',
                    secondLabel: 'متوسط الوزن للفرخ',
                    firstSuffix: 'طائر',
                    secondSuffix: 'كجم',
                    onFirstChanged: (val) {
                      controller.birdsCount.value = val;
                      controller.totalWeight.value = 0.0;
                    },
                    onSecondChanged: (val) {
                      controller.birdWeight.value = val;
                      controller.totalWeight.value = 0.0;
                    },
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              const AdNativeWidget(),
              SizedBox(height: 12.h),
              ToolsButton(
                text: 'احسب الوزن الإجمالي',
                onPressed: () {
                  if (_formKey.currentState?.validate() != true) return;
                  controller.calculate();
                },
              ),
              SizedBox(height: 14.h),
              Obx(() {
                final totalWeight = controller.totalWeight.value;
                if (totalWeight <= 0) return const SizedBox.shrink();

                return ToolResultCard(
                  title: 'الوزن الإجمالي للقطيع',
                  value: '${formatDecimal(totalWeight, decimals: 0)} كيلو جرام',
                  resultColor: resultColor,
                );
              }),
              SizedBox(height: 16.h),
              const NotesCard(
                notes: [
                  'لحساب الوزن الكلي للقطيع: وزّن 10 فراخ عشوائيًا، احسب متوسط الوزن (قسمة على 10)، ثم اضربه في عدد الطيور.',
                ],
              ),
              SizedBox(height: 16.h),
              const RelatedArticlesSection(
                relatedArticleIds: [13, 8],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
