import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_page_view.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
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
                    children: [
                      Text(
                        'الوزن الإجمالي للقطيع',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.85),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '${formatDecimal(totalWeight, decimals: 0)} كيلو جرام',
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
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
