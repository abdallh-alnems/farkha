import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/age_dropdown.dart';
import '../../../logic/controller/tools_controller/darkness_levels_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tools_result_card.dart';

class DarknessLevelsView extends StatelessWidget {
  const DarknessLevelsView({super.key});

  @override
  Widget build(BuildContext context) {
    final DarknessLevelsController controller = Get.put(
      DarknessLevelsController(),
    );

    logToolPageViewOnce(
      widgetType: DarknessLevelsView,
      toolName: 'ساعات الإظلام',
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final darknessBg = isDark
        ? Colors.blue.withValues(alpha: 0.2)
        : Colors.blue.shade50;
    final darknessBorder = isDark
        ? Colors.blue.withValues(alpha: 0.5)
        : Colors.blue.shade200;
    final darknessTitle = isDark ? Colors.blue.shade300 : Colors.blue.shade800;
    final darknessValue = isDark ? Colors.blue.shade200 : Colors.blue.shade700;

    final lightBg =
        isDark ? Colors.orange.withValues(alpha: 0.2) : Colors.orange.shade50;
    final lightBorder = isDark
        ? Colors.orange.withValues(alpha: 0.5)
        : Colors.orange.shade200;
    final lightTitle =
        isDark ? Colors.orange.shade300 : Colors.orange.shade800;
    final lightValue =
        isDark ? Colors.orange.shade200 : Colors.orange.shade700;

    return Scaffold(
      appBar: const CustomAppBar(text: 'ساعات الاظلام', favoriteToolName: 'ساعات الاظلام'),
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
                    AgeDropdown(
                      key: ValueKey(controller.selectedDay.value),
                      selectedAge: controller.selectedDay.value,
                      onAgeChanged: (value) => controller.setDay(value),
                      maxAge: controller.maxDay,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              const AdNativeWidget(),
              SizedBox(height: 12.h),
              Obx(() {
                final darknessHours = controller.darkness;
                final lightHours = controller.light;
                final hasValidDay =
                    controller.selectedDay.value != null &&
                    darknessHours != null &&
                    lightHours != null;

                return hasValidDay
                    ? Row(
                        children: [
                          Expanded(
                            child: ToolsResultCard(
                              title: 'ساعات الإظلام',
                              value:
                                  '${controller.darknessHoursFormatted} ساعة',
                              backgroundColor: darknessBg,
                              borderColor: darknessBorder,
                              titleColor: darknessTitle,
                              valueColor: darknessValue,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: ToolsResultCard(
                              title: 'ساعات الإضاءة',
                              value: '${controller.lightHoursFormatted} ساعة',
                              backgroundColor: lightBg,
                              borderColor: lightBorder,
                              titleColor: lightTitle,
                              valueColor: lightValue,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink();
              }),
              SizedBox(height: 14.h),
              const NotesCard(
                notes: [
                  'يتم تطبيق الإظلام تدريجياً حسب عمر الطائر.',
                  'أقصى مدة للظلام ساعتين في المرة الواحدة الباقي من ساعات الإظلام يقسم على باقي اليوم',
                  'الاظلام عملية مهمة جدا في  النمو',
                ],
              ),
              const RelatedArticlesSection(
                relatedArticleIds: [9],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
