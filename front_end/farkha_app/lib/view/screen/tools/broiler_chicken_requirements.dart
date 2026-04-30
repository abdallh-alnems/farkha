import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/chicken_age_count_input.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tools/broiler_chicken_requirements/items_broiler_chicken_requirements.dart';
import '../../widget/tools/related_articles_section.dart';

class BroilerChickenRequirementsScreen extends StatelessWidget {
  BroilerChickenRequirementsScreen({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final BroilerController controller =
        Get.isRegistered<BroilerController>()
            ? Get.find<BroilerController>()
            : Get.put(BroilerController());

    logToolPageViewOnce(widgetType: BroilerChickenRequirementsScreen, toolId: 13);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: 'متطلبات فراخ التسمين', favoriteToolName: 'متطلبات فراخ التسمين'),
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                child: Form(
                  key: _formKey,
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
                                ? AppColors.darkOutlineColor.withValues(
                                  alpha: 0.5,
                                )
                                : AppColors.lightOutlineColor.withValues(
                                  alpha: 0.3,
                                ),
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
                        child: ChickenAgeCountInput(
                          key: ValueKey(controller.selectedChickenAge.value),
                          controller: controller.chickensCountController,
                          selectedAge:
                              (controller.selectedChickenAge.value as num?)
                                  ?.toInt(),
                          onAgeChanged: (newValue) {
                            controller.selectedChickenAge.value = newValue;
                          },
                          countSuffix: 'فرخ',
                          useInnerForm: false,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      const AdNativeWidget(),
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() != true) {
                              return;
                            }
                            FocusScope.of(context).unfocus();
                            controller.onPressed();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            elevation: isDark ? 0 : 2,
                          ),
                          child: Text(
                            'متطلبات فراخ التسمين',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      const ItemsBroilerChickenRequirements(),
                      SizedBox(height: 16.h),
                      const RelatedArticlesSection(
                        relatedArticleIds: [15, 11],
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
