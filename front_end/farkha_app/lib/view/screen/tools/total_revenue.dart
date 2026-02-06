import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/three_input_fields.dart';
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
    logToolPageViewOnce(
      widgetType: TotalRevenueScreen,
      toolName: 'إجمالي الإيرادات',
    );

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
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
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? AppColors.darkSurfaceElevatedColor
                          : AppColors.lightSurfaceColor,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color:
                        isDark
                            ? AppColors.darkOutlineColor.withValues(alpha: 0.5)
                            : AppColors.lightOutlineColor.withValues(
                              alpha: 0.3,
                            ),
                  ),
                  boxShadow:
                      isDark
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
                        'إجمالي الإيرادات',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.85),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '$formattedRevenue جنيه',
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
