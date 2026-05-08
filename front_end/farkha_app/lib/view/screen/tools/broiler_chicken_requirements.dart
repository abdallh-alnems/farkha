import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/theme.dart';
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

    logToolPageViewOnce(
      widgetType: BroilerChickenRequirementsScreen,
      toolId: 13,
    );

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(
            text: 'متطلبات فراخ التسمين',
            favoriteToolName: 'متطلبات فراخ التسمين',
          ),
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  8.h,
                  AppSpacing.screenH,
                  16.h,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeaderCard(context, colorScheme, isDark),
                      SizedBox(height: 16.h),
                      _buildInputSection(context, controller, colorScheme, isDark),
                      SizedBox(height: 14.h),
                      const AdNativeWidget(),
                      SizedBox(height: 14.h),
                      _buildCalculateButton(context, colorScheme, controller),
                      SizedBox(height: 20.h),
                      const ItemsBroilerChickenRequirements(),
                      SizedBox(height: 20.h),
                      const RelatedArticlesSection(relatedArticleIds: [15, 11]),
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

  Widget _buildHeaderCard(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.1),
            colorScheme.tertiary.withValues(alpha: isDark ? 0.12 : 0.06),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: AppDimens.borderLg,
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: AppDimens.borderMd,
            ),
            child: Icon(
              Icons.calculate_outlined,
              color: colorScheme.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حاسبة المتطلبات',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'حدد العمر والعدد لمعرفة الاحتياجات',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(
    BuildContext context,
    BroilerController controller,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevatedColor
            : AppColors.lightSurfaceColor,
        borderRadius: AppDimens.borderLg,
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineColor.withValues(alpha: 0.5)
              : AppColors.lightOutlineColor.withValues(alpha: 0.4),
        ),
        boxShadow: isDark
            ? null
            : [AppElevation.shadow(opacity: 0.06)],
      ),
      child: ChickenAgeCountInput(
        key: ValueKey(controller.selectedChickenAge.value),
        controller: controller.chickensCountController,
        selectedAge:
            (controller.selectedChickenAge.value as num?)?.toInt(),
        onAgeChanged: (newValue) {
          controller.selectedChickenAge.value = newValue;
        },
        countSuffix: 'فرخ',
        useInnerForm: false,
      ),
    );
  }

  Widget _buildCalculateButton(
    BuildContext context,
    ColorScheme colorScheme,
    BroilerController controller,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState?.validate() != true) return;
          FocusScope.of(context).unfocus();
          controller.onPressed();
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimens.borderMd,
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'احسب المتطلبات',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
