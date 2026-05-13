import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_helpers.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/input_field.dart';
import '../../../logic/controller/tools_controller/bird_production_cost_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tools_button.dart';

class BirdProductionCostScreen extends StatelessWidget {
  BirdProductionCostScreen({super.key});

  final BirdProductionCostController controller =
      Get.put(BirdProductionCostController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onCalculatePressed() {
    if (_formKey.currentState?.validate() != true) return;
    controller.calculateCostPerBird();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: BirdProductionCostScreen, toolId: 15);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(
        text: 'تكلفة انتاج الفرخ',
        favoriteToolName: 'تكلفة انتاج الفرخ',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeaderCard(colorScheme: colorScheme, isDark: isDark),
                SizedBox(height: 16.h),
                _InputSection(controller: controller),
                SizedBox(height: 16.h),
                ToolsButton(
                  text: 'احسب تكلفة إنتاج الفرخ',
                  onPressed: _onCalculatePressed,
                ),
                SizedBox(height: 8.h),
                _ResultSection(controller: controller),
                SizedBox(height: 14.h),
                const AdNativeWidget(),
                SizedBox(height: 14.h),
                const RelatedArticlesSection(relatedArticleIds: [12, 20]),
                SizedBox(height: 80.h),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final bool isDark;

  const _HeaderCard({required this.colorScheme, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            AppColors.primaryColor.withValues(alpha: isDark ? 0.25 : 0.12),
            AppColors.accentColor.withValues(alpha: isDark ? 0.15 : 0.06),
          ],
        ),
        borderRadius: AppDimens.borderXl,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: AppDimens.borderMd,
            ),
            child: Icon(
              Icons.agriculture_outlined,
              size: 28.sp,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تكلفة إنتاج الفرخ',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'أدخل إجمالي التكاليف وعدد الفراخ لحساب تكلفة كل فرخ',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InputSection extends StatelessWidget {
  final BirdProductionCostController controller;

  const _InputSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppDimens.borderLg,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.4),
        ),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : [AppElevation.shadow(opacity: 0.06)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: Row(
              children: [
                Icon(
                  Icons.edit_note_outlined,
                  size: 20.sp,
                  color: colorScheme.primary,
                ),
                SizedBox(width: 6.w),
                Text(
                  'بيانات الحساب',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: InputField(
                  label: 'إجمالي التكاليف',
                  suffixText: 'جنيه',
                  onChanged: (value) =>
                      controller.totalCosts.value =
                          tryParseNum(value) ?? 0.0,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: InputField(
                  label: 'عدد الفراخ',
                  suffixText: 'فرخ',
                  onChanged: (value) =>
                      controller.liveBirds.value =
                          tryParseInt(value) ?? 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  final BirdProductionCostController controller;

  const _ResultSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final value = controller.costPerBird.value;
      if (value <= 0) return const SizedBox.shrink();

      return AnimatedSize(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutQuart,
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.only(top: 6.h),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                getToolResultColor(context).withValues(alpha: isDark ? 0.22 : 0.1),
                getToolResultColor(context).withValues(alpha: isDark ? 0.10 : 0.04),
              ],
            ),
            borderRadius: AppDimens.borderXl,
            border: Border.all(
              color:
                  getToolResultColor(context).withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calculate_outlined,
                    size: 20.sp,
                    color: getToolResultColor(context),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'تكلفة إنتاج الفرخ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                '${formatDecimal(value)} جنيه',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  color: getToolResultColor(context),
                  height: 1.2,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: getToolResultColor(context).withValues(alpha: 0.12),
                  borderRadius: AppDimens.borderXl,
                ),
                child: Text(
                  'لكل فرخ',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: getToolResultColor(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
