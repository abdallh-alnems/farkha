import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/age_dropdown.dart';
import '../../../logic/controller/tools_controller/vaccination_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tools/related_articles_section.dart';

class VaccinationSchedule extends StatelessWidget {
  const VaccinationSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VaccinationController());

    logToolPageViewOnce(
      widgetType: VaccinationSchedule,
      toolName: 'جدول التحصينات',
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Scaffold(
      appBar: const CustomAppBar(text: 'جدول التحصينات', favoriteToolName: 'جدول التحصينات'),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AgeDropdown(
                      key: ValueKey(controller.currentAge.value),
                      selectedAge:
                          controller.currentAge.value == 0
                              ? null
                              : controller.currentAge.value,
                      onAgeChanged: controller.setCurrentAge,
                      maxAge: 30,
                      hint: 'اختر العمر',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              const AdNativeWidget(),
              SizedBox(height: 12.h),
              Obx(() {
                if (controller.currentAge.value == 0) {
                  return const SizedBox.shrink();
                }

                final currentVaccination = controller.currentVaccination.value;
                final nextVaccination = controller.nextVaccination.value;

                return Column(
                  children: [
                    _buildVaccinationCard(
                      context: context,
                      isDark: isDark,
                      colorScheme: colorScheme,
                      title:
                          'التحصين الحالي (عمر ${currentVaccination?.age ?? '-'} يوم)',
                      vaccineName: currentVaccination?.vaccineName,
                      notes: currentVaccination?.notes,
                      isEmpty: currentVaccination == null,
                      emptyMessage: 'لا يوجد تحصين لهذا العمر',
                      color: primaryColor,
                      icon: Icons.today,
                    ),
                    SizedBox(height: 12.h),
                    _buildVaccinationCard(
                      context: context,
                      isDark: isDark,
                      colorScheme: colorScheme,
                      title:
                          'التحصين القادم (عمر ${nextVaccination?.age ?? '-'} يوم)',
                      vaccineName: nextVaccination?.vaccineName,
                      notes: nextVaccination?.notes,
                      isEmpty: nextVaccination == null,
                      emptyMessage: 'لا يوجد تحصين قادم',
                      color: Colors.green,
                      icon: Icons.schedule,
                    ),
                  ],
                );
              }),
              SizedBox(height: 14.h),
              const RelatedArticlesSection(relatedArticleIds: [17]),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildVaccinationCard({
    required BuildContext context,
    required bool isDark,
    required ColorScheme colorScheme,
    required String title,
    String? vaccineName,
    String? notes,
    required bool isEmpty,
    required String emptyMessage,
    required Color color,
    required IconData icon,
  }) {
    final cardColor =
        isEmpty
            ? (isDark
                ? Colors.grey.withValues(alpha: 0.2)
                : Colors.grey.shade100)
            : color.withValues(alpha: isDark ? 0.2 : 0.1);
    final borderColor =
        isEmpty
            ? (isDark
                ? Colors.grey.withValues(alpha: 0.5)
                : Colors.grey.shade400)
            : color.withValues(alpha: 0.6);
    final textColor =
        isEmpty
            ? (isDark ? Colors.grey.shade400 : Colors.grey.shade700)
            : color;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow:
            isDark
                ? null
                : [
                  BoxShadow(
                    color: (isEmpty ? Colors.grey : color).withValues(
                      alpha: 0.1,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child:
          isEmpty
              ? Row(
                children: [
                  Icon(icon, color: textColor, size: 22.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      emptyMessage,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: textColor, size: 22.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    vaccineName ?? '',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.9),
                    ),
                  ),
                  if (notes != null && notes.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      notes,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
    );
  }
}
