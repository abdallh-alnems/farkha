import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/three_input_fields.dart';
import '../../../core/shared/tools/tool_input_card.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/total_revenue_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tools_button.dart';

class TotalRevenueScreen extends StatelessWidget {
  TotalRevenueScreen({super.key});
  final TotalRevenueController controller = Get.put(TotalRevenueController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onCalculatePressed() {
    if (_formKey.currentState?.validate() != true) return;
    controller.calculate();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: TotalRevenueScreen, toolId: 22);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color resultColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Scaffold(
      appBar: const CustomAppBar(text: 'اجمالي الايرادات', favoriteToolName: 'اجمالي الايرادات'),
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
                    firstLabel: 'عدد الطيور',
                    secondLabel: 'متوسط الوزن',
                    thirdLabel: 'سعر الكيلو',
                    secondSuffix: 'كجم',
                    thirdSuffix: 'جنيه',
                    onFirstChanged: controller.updateBirdsCount,
                    onSecondChanged: controller.updateAverageWeight,
                    onThirdChanged: controller.updatePricePerKg,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              const AdNativeWidget(),
              SizedBox(height: 12.h),
              ToolsButton(
                text: 'احسب الإيرادات',
                onPressed: _onCalculatePressed,
              ),
              SizedBox(height: 14.h),
              Obx(() {
                final formattedRevenue = controller.getFormattedRevenue();
                if (formattedRevenue.isEmpty) return const SizedBox.shrink();

                return ToolResultCard(
                  title: 'إجمالي الإيرادات',
                  value: '$formattedRevenue جنيه',
                  resultColor: resultColor,
                );
              }),
              SizedBox(height: 16.h),
              const NotesCard(
                notes: [
                  'يتم حساب الإيرادات بناءً على عدد الطيور ومتوسط الوزن وسعر الكيلو.',
                  'الإيرادات = عدد الطيور × متوسط الوزن × سعر الكيلو.',
                  'يجب التأكد من دقة البيانات المدخلة للحصول على نتائج صحيحة.',
                ],
              ),
              SizedBox(height: 16.h),
              const RelatedArticlesSection(relatedArticleIds: [20]),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
