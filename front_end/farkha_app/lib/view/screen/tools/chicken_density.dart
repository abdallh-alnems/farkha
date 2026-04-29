import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/input_field.dart';
import '../../../logic/controller/tools_controller/chicken_density_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tools_button.dart';

class ChickenDensity extends StatelessWidget {
  const ChickenDensity({super.key});

  @override
  Widget build(BuildContext context) {
    final ChickenDensityController controller = Get.put(
      ChickenDensityController(),
    );

    logToolPageViewOnce(widgetType: ChickenDensity, toolId: 3);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final resultColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Scaffold(
      appBar: const CustomAppBar(text: 'كثافة الفراخ', favoriteToolName: 'كثافة الفراخ'),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() {
                            return DropdownButtonFormField<String>(
                              initialValue: controller.selectedAgeCategory.value,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'اختر الأسبوع',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12.h,
                                  horizontal: 12.w,
                                ),
                              ),
                              dropdownColor: colorScheme.surface,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 16.sp,
                              ),
                              items: [
                                'الاسبوع الاول',
                                'الاسبوع الثاني',
                                'الاسبوع الثالث',
                                'الاسبوع الرابع',
                                'الاسبوع الخامس',
                              ].map((week) {
                                return DropdownMenuItem<String>(
                                  value: week,
                                  child: Text(
                                    week,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  controller.selectedAgeCategory.value = value;
                                }
                              },
                            );
                          }),
                        ),
                        SizedBox(width: 11.w),
                        Expanded(
                          child: InputField(
                            label: 'عدد الفراخ',
                            controller: controller.chickenCountTextController,
                            suffixText: 'فرخ',
                            enableValidation: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              const AdNativeWidget(),
              SizedBox(height: 12.h),
              ToolsButton(
                text: 'احسب الكثافة',
                onPressed: () => controller.calculateAreas(),
              ),
              SizedBox(height: 14.h),
              Obx(() {
                if (!controller.shouldDisplayResults.value) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildResultSection(
                      context,
                      isDark: isDark,
                      colorScheme: colorScheme,
                      resultColor: resultColor,
                      title: 'مساحة التربية الأرضي',
                      items: [
                        controller.currentAgeGroundAreaResult.value,
                        controller.totalGroundAreaResult.value,
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _buildResultSection(
                      context,
                      isDark: isDark,
                      colorScheme: colorScheme,
                      resultColor: resultColor,
                      title: 'مساحة البطاريات',
                      items: [
                        controller.batteryCageAreaResult.value,
                      ],
                    ),
                  ],
                );
              }),
              SizedBox(height: 14.h),
              const RelatedArticlesSection(
                relatedArticleIds: [4],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildResultSection(
    BuildContext context, {
    required bool isDark,
    required ColorScheme colorScheme,
    required Color resultColor,
    required String title,
    required List<String> items,
  }) {
    return Container(
      margin: EdgeInsets.zero,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 12.h),
          ...items.asMap().entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.key < items.length - 1 ? 8.h : 0,
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.85),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
